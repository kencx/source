---
title: "Box Packaging"
date: 2023-01-25
lastmod: 2023-01-25
draft: false
toc: true
tags:
- vagrant
---

There are three components to packaging a Vagrant box:

1. Box File (mandatory)
2. Box Catalog Metadata
3. Box Information

```text
├─ bionic64_libvirt.box (tgz archive) (1)
|   ├─ ubuntu.img
|   ├─ metadata.json
|   └─ Vagrantfile
├─ catalog.json                       (2)
└─ info.json                          (3)
```

## Box File

1. The box file is a compressed archives (`tar, tar.gz, zip`) that may contain
anything, depending on its provider. This file must exist.

2. Within the archive, Vagrant expects a single `metadata.json` file that is
unrelated to the [Box Catalog Metadata](#box-catalog-metadata) file.
`metadata.json` must contain the `provider` key to set the provider of the box:

```json
{
  "provider": "virtualbox"
}
```

If there is no or an invalid `metadata.json` file, Vagrant will throw an error when adding the box as it cannot verify the provider.

3. The box file can also be optionally packaged with a Vagrantfile.

## Box Catalog Metadata

The box catalog metadata file is only necessary to support box versioning and
updating. It is a JSON file that specifies the:
- Name of the box
- Description
- Available versions
- Available providers
- Local or remote URLs to box files

There can be multiple catalog metadata files in the same box package.

```json
{
  "name": "hashicorp/bionic64",
  "description": "This box contains Ubuntu 18.04 LTS 64-bit",
  "versions": [
    {
      "version": "0.1.0",
      "providers": [
        {
          "name": "virtualbox",
          "url": "https://foo.com/bionic64_2022_01_01_virtualbox.box",
          "checksum_type": "sha1",
          "checksum": "foo"
        }
      ]
    },
    {
      "version": "0.2.0",
      "providers": [
        {
          "name": "virtualbox",
          "url": "file:///~/boxes/bionic64_2022_02_01_virtualbox.box",
          "checksum_type": "sha1",
          "checksum": "bar"
        }
      ]
    }
  ]
}
```

This file can be passed directly to `vagrant box add`, via filepath or
remote URL, to install all listed box versions.

{{< alert type="warning" >}}
The `url` field [does not support](https://github.com/hashicorp/vagrant/issues/10719) relative paths to the box. Absolute paths must be provided, but `~` can be used for `$HOME`.
{{< /alert >}}

## Box Information

This is an optional `info.json` file that can provide additional information
about the box with `vagrant box list -i`.

There are no special keys or values, Vagrant will output any specified custom information:

```json
{
  "author": "johndoe",
  "homepage": "https://example.com"
}
```

## References
- [Vagrant - Box File Format](https://developer.hashicorp.com/vagrant/docs/boxes/format)
