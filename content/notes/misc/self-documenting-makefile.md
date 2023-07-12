---
title: "Self-Documenting Makefile"
date: 2023-07-12
lastmod: 2023-07-12
draft: false
toc: false
tags:
- misc
- makefile
- snippet
---

Two examples of custom `help` targets:

```make
.PHONY: help

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
    sort | \
    awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

install: ## install dependencies
	...
```

```make
.PHONY: help

help:
	@echo 'Usage:'
	@sed -n 's/^##//p' ${MAKEFILE_LIST} | column -t -s ':' | sed -e 's/^/ /'

## install: install dependencies
install:
	...
```

Both can be used to print a helpful `help` menu for available Makefile targets.
