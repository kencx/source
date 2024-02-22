---
title: "Add custom SSH key pair"
date: 2023-02-02
lastmod: 2023-02-02
draft: false
toc: true
tags:
- vagrant
- ssh
---

When a new Vagrant machine is created, it generates a secure SSH key pair to
replace the existing [insecure key pair]({{< relref
"til/vagrant/base-box-specs#insecure-by-default" >}}) present in all boxes. In
some cases, we might wish to use our own custom key pair, which we can add via
provisioning.

### Overwrite Generated Key Pair

This method overwrites the generated, secure key pair that is generated on
`vagrant up` by default. The existing `/home/vagrant/.ssh/authorized_keys` is
overwritten with the given public key during provisioning.

```ruby
VAGRANT_COMMAND = ARGV[0]

Vagrant.configure("2") do |config|
	config.vm.provision "file", source: "/path/to/public/key", destination: "~/.ssh/authorized_keys"

	if VAGRANT_COMMAND == "ssh"
		config.ssh.private_key_path = "/path/to/private/key"
	end
end
```

The conditional block here is important. It allows Vagrant to create the guest
VM and default, secure key pair on the first `vagrant up`. It then lets Vagrant
use the custom key pair to perform `vagrant ssh`.

### Append Custom Key Pair

The alternative is to keep both generated and custom key pairs by not
overwriting the `authorized_keys` file. Instead of copying the custom public key
to `authorized_keys`, it is written to a temporary file which is appended to the
existing `authorized_keys` and later removed.

```ruby
VAGRANT_COMMAND = ARGV[0]

Vagrant.configure("2") do |config|
	config.vm.provision "file", source: "/path/to/public/key", destination: "~/.ssh/temp"

	$script = <<EOF
cat ~/.ssh/temp >> ~/.ssh/authorized_keys
rm ~/.ssh/temp
EOF

	config.vm.provision "shell" do |s|
		s.inline = $script
		s.privileged = false
	end

	if VAGRANT_COMMAND == "ssh"
		config.ssh.private_key_path = "/path/to/private/key"
	end
end
```

Similarly, a conditional block is used to allow for a successful provisioning
before the custom key pair is added.

### Adding Key Pair to Other User

We can extend either of the previous methods to add a key pair to another user,
instead of `vagrant`. This user must already exist in the box or must be created
with a `shell` provisioner.

```ruby
VAGRANT_COMMAND = ARGV[0]

Vagrant.configure("2") do |config|
	config.vm.provision "shell" do |s|
		s.path = "create_user.sh"
	end
	config.vm.provision "file", source: "/path/to/public/key", destination: "/home/foo/.ssh/authorized_keys"

	if VAGRANT_COMMAND == "ssh"
		config.ssh.username = "foo"
		config.ssh.private_key_path = "/path/to/private/key"
	end
end
```

The `create_user.sh` script should ensure the user's `.ssh` directory already
exists with the appropriate permissions.

## References

- [hashicorp/vagrant Github Issue - Automating authorized_keys in
  Vagrantfile](https://github.com/hashicorp/vagrant/issues/992)
- [hashicorp/vagrant Github Issue - Provision as different user than
  config.ssh.username](https://github.com/hashicorp/vagrant/issues/1753)
