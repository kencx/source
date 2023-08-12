---
title: "pip-tools Workflow with Makefile"
date: 2023-07-12
lastmod: 2023-07-12
draft: false
toc: false
tags:
- python
- pip-tools
- makefile
- snippets
---

```make
.PHONY: all check clean

objects = $(wildcard *.in)
outputs := $(objects:.in=.txt)
all: $(outputs)

%.txt: %.in
	pip-compile --verbose --generate-hashes --output-file $@ $<

dev-requirements.txt: requirements.txt

check:
	@if ! command -v pip-compile > /dev/null; then echo "pip-tools not installed!"; fi

clean: check
	- rm *.txt
```

`objects` is a list containing all `.in` files. `outputs` is a list made of one
`.txt` filename for each `.in` file in the `objects` list.

The target `all` is used to build all `.txt` files. It has no commands of its
own - it depends on all `.txt` files being built, which is fulfilled by the next
target `%.txt: %.in`.

The target `%.txt: %.in` will build a `.txt` file if it's older than its
corresponding `.in` or does not exist.

- The `--output-file $@` flag specifies the name of the output file
- `$<` is the corresponding `.in` input file

The target `dev-requirements.txt: requirements.txt` tells `make` about the
dependency between the requirements files. This ensures `dev-requirements.txt`
is updated whenever `dev-requirements.in` or `requirements.txt` have been
updated.

{{< alert type="note" >}}
If you don't like typing `make dev-requirements.txt`, you can add an additional
target `dev`:

```make
dev: dev-requirements.txt
```
{{< /alert >}}

```bash
# build all requirements files
$ make all

# update particular file
$ make dev-requirements.txt

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
