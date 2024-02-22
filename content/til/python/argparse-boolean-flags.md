---
title: "Argparse - Boolean Flags"
date: 2023-07-12
lastmod: 2023-07-12
draft: false
toc: true
tags:
- python
- argparse
---

The standard UX for boolean flags in command-line tools is to include the flag
when `True` and exclude it when `False` like so:

```bash
# verbose
$ ./foo.py --verbose

# no verbose
$ ./foo.py
```

The naive method to implement this with `argparse` would be to use
`add_argument` with the `type=bool` keyword argument. This fails as Python
expects a string argument for this boolean flag, resulting in strange behaviour.

```python
import argparse
parser = argparse.ArgumentParser()
parser.add_argument("--verbose", type=bool)
args = parser.parse_args()
print(args.verbose)
```

```bash
$ ./foo.py --verbose
False
$ ./foo.py --verbose="true"
True
$ ./foo.py --verbose="false"
True
```

This is because all non-empty strings are [truthy]({{< relref
"til/python/truthy-and-falsy" >}}) while all empty strings are falsy. Besides,
the above interface is cumbersome for boolean flags.

## Solution

The correct way to implement boolean flags with `argparse` is to use the
`action` argument instead. We can opt to use the `store_true` and `store_false`
actions like so:

```python
import argparse
parser = argparse.ArgumentParser()
parser.add_argument("--verbose", action="store_true")
args = parser.parse_args()
print(args.verbose)
```

```bash
$ ./foo.py --verbose
True
$ ./foo.py
False
```

Or we can use the `argparse.BooleanOptionalAction` action which implements the
same interface but automatically adds support for inverse boolean flags:

```python
import argparse
parser = argparse.ArgumentParser()
parser.add_argument("--verbose", action=argparse.BooleanOptionalAction)
args = parser.parse_args()
print(args.verbose)
```

```bash
$ ./foo.py -h
usage: main.py [-h] [--verbose | --no-verbose ]
```

## References
- [Python docs - argparse](https://docs.python.org/3/library/argparse.html)
