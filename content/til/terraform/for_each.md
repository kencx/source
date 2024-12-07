---
title: "for_each Patterns"
date: 2024-12-08
lastmod: 2024-12-08
draft: false
toc: true
---

## List of strings

```hcl
locals {
  servers = [
      "vm-1",
      "vm-2",
      "vm-3"
  ]
}

resource "example" "this" {
  for_each = toset(local.servers)

  name = each.key
}
```

## List of objects

```hcl
locals {
  servers = [
    {
      name = "vm-1"
      ip = "10.0.0.5"
    }
  ]
}

resource "example" "this" {
  for_each = {
    for i, vm in local.servers : vm.name => vm
  }

  name = each.value.name
  ip_address = each.value.ip
}
```

## Cartesian product of two lists

```hcl
locals {
  domains = [
    "https://google.com",
    "https://example.com"
  ]
  paths = [
	"/foo",
	"/bar",
	"/bax"
  ]
}

resource "example" "this" {
  urls = [for url in setproduct(locals.domains, locals.paths) : join("", url)]
}
```

## Conditional

```hcl
resource "example" "this" {
  for_each   = var.create_example ? [] : [1]
  name       = ...
  ip_address = ...
}
```

## References
- [How to for_each through list of objects in
  Terraform](https://stackoverflow.com/questions/58594506/how-to-for-each-through-a-listobjects-in-terraform-0-12)
