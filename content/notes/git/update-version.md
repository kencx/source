---
title: "Update Version Number"
date: 2022-04-24T00:51:45+08:00
lastmod: 2022-04-24T00:51:45+08:00
draft: false
toc: false
---

This simple bash function increments a version number based on [semantic versioning](https://semver.org/).

```bash
#!/bin/bash

increment_version() {
  local delim=.
  local array=($(echo "$1" | tr "$delim" '\n'))
  array[$2]=$((array[$2]+1))

  if [[ $2 -lt 2 ]]; then
	  array[2]=0
  fi
  if [[ $2 -lt 1 ]]; then
	  array[1]=0
  fi

  echo $(local IFS="$delim"; echo "${array[*]}")
}
```

```bash
$ increment_version 1.2.0 0
2.0.0
$ increment_version 1.2.0 1
1.3.0
$ increment_version 1.2.0 2
1.2.1
```

Pair this function with `grep` and `sed` to update the version number in
files.

```bash
# read version number from file
REGEX="(\d+\.)?(\d+\.)?(\*|\d+)$"
VERSION="$(grep -oP "$REGEX" "$1")"

NEW_VERSION=$(increment_version "$VERSION" "$2")

# write to new version number to file
sed -i -E "s/$VERSION/$NEW_VERSION/" "$1"
echo "$NEW_VERSION"
```

Finally, run the script with git tag in a Makefile

```Makefile
tag:
	$(eval VER=$(shell ./bin/inc_version galaxy.yml $(c)))
	git add galaxy.yml && git commit -m "chore: update to version $(VER)"
	git tag -a $(VER)
```

Running `make tag c=num` does the following:
1. Update the version number in `galaxy.yml`
2. Add and commit the change in `galaxy.yml`
3. Create a new tag with the new version number

>Note: This command should be run when all other changes have been committed.

Is this whole setup really necessary? Not really but I was lazy.

Is this more complicated than it needs to be? Probably, and its most likely
susceptible to bugs.

Does it fulfil my needs? Yes.
