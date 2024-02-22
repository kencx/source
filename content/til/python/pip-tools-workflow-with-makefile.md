---
title: "pip-tools Workflow with Makefile"
date: 2023-07-12
lastmod: 2023-07-12
draft: false
toc: true
tags:
- python
- pip-tools
- makefile
- snippets
---

## TLDR

```make
.PHONY: all dev check clean

objects = $(wildcard *.in)
outputs := $(objects:.in=.txt)
all: $(outputs)

%.txt: %.in
	pip-compile --verbose --generate-hashes --output-file $@ $<

dev-requirements.txt: requirements.txt
dev: dev-requirements.txt

check:
	@if ! command -v pip-compile > /dev/null; then echo "pip-tools not installed!"; fi

clean: check
	- rm *.txt
```

## Build requirements.txt file

```make
%.txt: %.in
	pip-compile --verbose --generate-hashes --output-file $@ $<
```

This target will build a `.txt` file with `pip-compile` if it is
older than the corresponding `.in` or if it does not exist.

- The `--output-file $@` flag specifies the name of the output `.txt` file where
  `$@` represents the target name
- `$<` represents the corresponding `.in` input file

For example, this target will create the `requirements.txt` file from a
`requirements.in` file.

## Dev-Only Dependencies

```make
dev-requirements.txt: requirements.txt
dev: dev-requirements.txt
```

This first target creates a dependency between the two requirements files. It
ensures `dev-requirements.txt` is updated whenever `dev-requirements.in` or
`requirements.txt` have been updated.

The second target is a shortcut so we can run `make dev` instead of `make
dev-requirements.txt`.

## Build all files

```make
objects = $(wildcard *.in)
outputs := $(objects:.in=.txt)
all: $(outputs)
```

Finally, we can define the `all` target to build all `*.txt` files by creating
two variables `objects` and `outputs`:

- `objects` is a list containing all `*.in` files.
- `outputs` is a list of `*.txt` files for each `*.in` file in `objects`

`all` depends on the list of `*.txt` files in `outputs`, which is fulfilled by
the previously discussed `%.txt: %.in` target. Thus, running `make all` will
build all `*.in` files into their corresponding `*.txt` files with
`pip-compile`.

## Workflow

```bash
# build all requirements files
$ make all

# update particular file
$ make dev

# force update file
$ touch requirements.in
$ make requirements.txt

# add dependency
$ echo [package] >> requirements.in
$ make all
```

## References
- [pip-tools documentation](https://pip-tools.readthedocs.io/en/latest/)
- [pip-tools workflow for Makefile](https://jamescooke.info/a-successful-pip-tools-workflow-for-managing-python-package-requirements.html)
