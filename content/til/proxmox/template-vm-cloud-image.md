---
title: "Creating VMs from Cloud Images in Proxmox"
date: 2023-11-03
lastmod: 2023-11-03
draft: false
toc: true
tags:
- proxmox
- virtualization
- cloud-init
- terraform
- qemu
---

Unlike ISOs, Proxmox does not support the creation of VMs directly from imported
cloud images. Instead, cloud images must be turned into a template to be cloned
for subsequent use. This document details the steps involved in creating and
using cloud images in Proxmox with cloud-init.

## Download Cloud Images to Proxmox

Firstly, download your cloud image of choice. The Proxmox GUI does not
have native support for this, unlike ISOs and LXC container templates, so we can
opt to do this manually:

```bash
$ wget https://cloud.debian.org/images/cloud/bullseye/20231013-1532/debian-11-generic-amd64-20231013-1532.qcow2 -O [path/to/image]
```

or via the
[bpg/proxmox](https://registry.terraform.io/providers/bpg/proxmox/latest/docs)
Terraform provider which performs uploads using the Proxmox
API `/nodes/{node}/storage/{storage}/upload`
[endpoint](https://pve.proxmox.com/pve-docs/api-viewer/index.html#/nodes/{node}/storage/{storage}/upload):

```hcl
resource "proxmox_virtual_environment_file" "cloud_image" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = "pve"

  source_file {
    path      = var.image_url
    file_name = var.image_filename
  }
}
```

The `file_name` attribute is used to override the name of the uploaded file.
This is required when an unsupported extension is being uploaded (`.qcow2,
.raw`) as Proxmox only supports `.img` files in the ISO datastore.

{{< alert type="note" >}}
This resource downloads the source file locally before uploading it
to the Proxmox host. See the provider documentation for more information.
{{< /alert >}}

## Qemu-guest-agent

`qemu-guest-agent` is a [helper
daemon](https://pve.proxmox.com/wiki/Qemu-guest-agent), installed in the guest,
used to exchange information between the host and guest machines. When `agent=1`
is set for a VM (like below), Proxmox expects the daemon to be installed and
running inside the VM. Failing to do so will cause the `Shutdown` and `Reboot`
operations to timeout and fail.

Because cloud images do not usually have `qemu-guest-agent` installed, it is
usually recommended to disable it with `agent=0`. If necessary, we can install
it directly into the cloud image via `virt-customize`:

```bash
# on Proxmox host
$ apt install -y libguestfs-tools
$ virt-customize --install qemu-guest-agent -a [/path/to/image]
```

The above should be done **before** the VM template is created.

{{< alert type="note" >}}
Alternatively, we can avoid modifying the cloud image directly by installing the
agent via [Packer](#packer-proxmox-builder).
{{< /alert >}}

## Create VM Template from Cloud Image

Next, we need to create a new VM with the uploaded cloud image. Proxmox has [no
support](https://bugzilla.proxmox.com/show_bug.cgi?id=4141) for doing this with
the API, so we must do this with `qm`:

```bash
# Create the instance
$ qm create 9000 -name 'foo' \
    -memory 1024 \
    -cores 1 -sockets 1 \
    -net0 virtio,bridge=vmbr0

# Import the disk image to Proxmox storage
$ qm importdisk 9000 [path/to/image] local-lvm [-format qcow2/raw]

# Attach the disk via SCSI to the VM
$ qm set 9000 -scsihw virtio-scsi-pci -scsi0 local-lvm:vm-9000-disk-0

# Set the bootdisk to the imported disk
$ qm set 9000 -boot c -bootdisk scsi0

# Enable the Qemu agent (see qemu-guest-agent below)
$ qm set 9000 -agent 1

# Allow hotplugging of network, USB and disks
$ qm set 9000 -hotplug disk,network,usb

# Add a single vCPU (for now)
$ qm set 9000 -vcpus 1

# Set a second hard drive, using the inbuilt cloudinit drive
$ qm set 9000 -ide2 local-lvm:cloudinit

# Add a serial output and video output
$ qm set 9000 -serial0 socket -vga serial0

# Resize the primary boot disk (otherwise it will be around 2G by default)
$ qm resize 9000 scsi0 +3G

# Finally, convert the VM into a template
$ qm template 9000
```

It's recommended to turn this VM into a template. The above steps are
summarized in a Bash script
[here](https://github.com/kencx/homelab/blob/master/bin/import-cloud-image).

## Packer Proxmox Builder

This step is optional but recommended if you plan on configuring the
VM.

Packer's [Proxmox Clone
builder](https://developer.hashicorp.com/packer/integrations/hashicorp/proxmox/latest/components/builder/clone)
can create a VM template by cloning an existing one. At the same time, it can
run provisioners to bootstrap the template with common configuration, such as:

- Installing common packages (eg. Docker)
- Creating and configuring the default user
- Basic security hardening
- Installing and enabling `qemu-guest-agent` (as discussed above)

First, to only install and enable `qemu-guest-agent`, we use the following
`shell` provisioner:

```hcl
provisioner "shell" {
  execute_command = "{{ .Vars }} sudo -S -E sh -eux '{{ .Path }}'"
  inline = [
      # wait for cloud-init to complete
      "/usr/bin/cloud-init status --wait",
      # install and start qemu-guest-agent
      "apt update && apt install -y qemu-guest-agent ",
      "systemctl enable qemu-guest-agent.service",
      "systemctl start --no-block qemu-guest-agent.service",
  ]
  expect_disconnect = true
}
```

Next, if we want to configure the VM with Ansible, we require two additional
provisioners:

```hcl
# make user ssh-ready for Ansible
provisioner "shell" {
  execute_command = "{{ .Vars }} sudo -S -E sh -eux '{{ .Path }}'"
  inline = [
    "HOME_DIR=/home/${var.ssh_username}/.ssh",
    "mkdir -m 0700 -p $HOME_DIR",
    "echo '${local.ssh_public_key}' >> $HOME_DIR/authorized_keys",
    "chown -R ${var.ssh_username}:${var.ssh_username} $HOME_DIR",
    "chmod 0600 $HOME_DIR/authorized_keys",
    "SUDOERS_FILE=/etc/sudoers.d/80-packer-users",
    "echo '${var.ssh_username} ALL=(ALL) NOPASSWD: ALL' > $SUDOERS_FILE",
    "chmod 0440 $SUDOERS_FILE",
  ]
}

# inventory file is automatically generated by Packer
provisioner "ansible" {
  playbook_file = "../ansible/playbooks/common.yml"
  extra_arguments = [
    "--extra-vars",
    "user=${var.ssh_username}",
  ]
  user        = var.ssh_username
  galaxy_file = "../requirements.yml"
  ansible_env_vars = [
    "ANSIBLE_STDOUT_CALLBACK=yaml",
    "ANSIBLE_HOST_KEY_CHECKING=False",
  ]
  pause_before = "5s"
}
```

The first `shell` provisioner makes the VM available for Ansible via SSH. The
next `ansible` provisioner runs the given playbook.


## Clone VM

Finally, to use the template, we can clone and set custom cloud-init parameters like so:

```bash
$ qm clone 9000 [id] --name [name]
$ qm set [id] --sshkey ~/.ssh/id_ed25519.pub
$ qm set [id] --ipconfig0 ip=[ip],gw=[gateway]
$ qm start [id]
```

or we can do the same with Terraform.

## References
- [cloud-init Support - Proxmox Docs](https://pve.proxmox.com/wiki/Cloud-Init_Support)
- [cloud-init FAQ - Proxmox Docs](https://pve.proxmox.com/wiki/Cloud-Init_FAQ#Usage_in_Proxmox_VE)
- [matthewkalnins - Proxmox & cloud-init](https://matthewkalnins.com/posts/home-lab-setup-part-1-proxmox-cloud-init/)
- [chriswayg - Ubuntu & Debian Cloud Images in Proxmox](https://gist.github.com/chriswayg/b6421dcc69cb3b7e41f2998f1150e1df)
- [Linux VM Templates in Proxmox](https://www.apalrd.net/posts/2023/pve_cloud/)
- [Making Ubuntu 22.04 VM template for Proxmox and cloud-init](https://github.com/UntouchedWagons/Ubuntu-CloudInit-Docs)
