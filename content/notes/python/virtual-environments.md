---
title: "Virtual Environments"
date: 2023-07-07
lastmod: 2023-07-07
draft: false
toc: true
tags:
- python
---

A Python virtual environment is a group of executables and directories that run
an isolated Python environment. The
[venv](https://docs.python.org/3.10/library/venv.html) (or `virtualenv`)
module creates an isolated, self-contained directory that contains symlinks to
our installed Python executables.

```bash
# create new venv with name foo
$ python -m venv foo

# activate venv
$ . foo/bin/activate

# deactivate venv
$ deactivate
```

{{< alert type="note" >}}
For Windows systems, the command is `.venv\Scripts\activate.bat`.
{{< /alert >}}

Packages should never be installed into the global Python environment as this
can and will lead to dependency version conflicts. They should be installed in
Python virtual environments instead.

## What goes into a venv?

```bash
venv/
|- bin/
|  |- activate
|  |- python -> /usr/bin/python
|  |- pip
|- lib/
|  |- site-packages/
|- include/
|- share/
|- pyvenv.cfg
```

- `bin/` (or `Scripts\` on Windows) contains the executables of the virtual
  environment, including the Python interpreter (symlinked to the global binary),
  `pip` and `activate` script.
- `lib/site-packages/` contains all external packages to be used within the
  virtual environment. By default, it comes pre-installed with `pip` and
  `setuptools`.
- `include/` (or `Include\` on Windows) is an empty folder that Python will use
  to include C header files for packages that might depend on C extensions.
- `pyvenv.cfg` contains several variables that Python uses to determine the
  interpreter and `site-packages` to use in the virtual environment. The virtual
  environment symlinks to the Python binary located at the same path under the
  `home` key. This file must be present for a virtual environment to work.

```cfg
# pyvenv.cfg
home = /usr/local/bin
include-system-site-packages = false
version = 3.10.2
```

## How do venvs work?

When a venv is activated, it performs three critical actions:

1. Sets the `VIRTUAL_ENV` variable to the root directory of your virtual
   environment.
2. Modifies the `PYTHONPATH` by prepending the location of the venv's Python
   executable to your `PATH`. This allows the shell to invoke the internal
   versions of `pip` and Python.
3. Adds venv name to your command prompt (eg. `(venv)`)

### Modifying PYTHONPATH

To see the difference, we compare the output of `sys.path` which shows the
default path locations for the Python installation.

Outside virtual environment:

```python
>>> import sys
>>> from pprint import pp
>>> pp(sys.path)
['',
 '/usr/lib/python39.zip',
 '/usr/lib/python3.9',
 '/usr/lib/python3.9/lib-dynload',
 '~/.local/lib/python3.9/site-packages',
 '/usr/local/lib/python3.9/dist-packages',
 '/usr/lib/python3/dist-packages']
```

Inside virtual environment:

```python
(venv) >>> import sys
(venv) >>> from pprint import pp
(venv) >>> pp(sys.path)
['',
 '/usr/lib/python39.zip',
 '/usr/lib/python3.9',
 '/usr/lib/python3.9/lib-dynload',
 '~/foo/.venv/lib/python3.9/site-packages']
```


- Outside the virtual environment, we see the user's `site-packages` at
  `~/.local/lib/`
- Inside, the `site-packages` path is replaced with that in the `.venv` virtual
  environment

This means the you cannot access any modules from your global Python
installation within the virtual environment. Optionally, you can get read-only
access by [giving the virtual environment access]({{< ref
"#give-venvs-access-to-system-site-packages" >}}).

{{< alert type="note" >}}
You can even use the virtual environment without activating it by simply calling
the virtual environment's Python interpreter with its absolute path. You can
test this by including the above `pp(sys.path)` in a file and running it with
`~/foo/.venv/bin/python path.py`.
{{< /alert >}}

## Customizing venvs

### Change Command Prompt

While you can change the name of a venv on creation, you can also pass a desired
name with the `--prompt` flag on creation:

```bash
$ python -m venv venv --prompt="dev-venv"

$ . venv/bin/activate
(dev-env)$
```

### Recreate existing venvs

When `venv` finds an existing virtual environment with the same name in the same
directory, it does not notify you that there is an existing venv and does not
overwrite it with a new one, i.e. it does nothing.

If you wish to overwrite or clear an existing virtual environment, you must pass
the `--clear` flag:

```bash
$ python -m venv venv
$ . venv/bin/activate
(venv) $ pip install requests
(venv) $ deactivate

$ python -m venv venv --clear
$ . venv/bin/activate
(venv) $ pip list # does not have requests installed
```

### Give venvs access to system site packages

You can give your venv access to your machine's `site-packages`
directory with the `--system-site-packages` flag when creating the environment:

```bash
$ python -m venv .venv --system-site-packages
```

This sets the `include-system-site-packages` in `pyvenv.cfg` to `true` and
allows the venv to use any external packages installed globally.
This only works one way and the system cannot source any new packages in your
venv's `site-packages`.

### Update pip

Oftentimes when creating a new venv, you might encounter the following message:

```
WARNING: You are using pip version 21.2.4; however, version 22.0.4 is available.
You should consider upgrading via the
'/path/to/venv/python -m pip install --upgrade pip' command.
```

This occurs because `venv` uses `ensurepip` to bootstrap pip into the virtual
environment. `ensurepip` does not connect to the Internet, but instead uses a
`pip` wheel that comes bundled with each new Python release. Therefore, the
bundled `pip` has a different update cycle than the independent `pip` project.

To prevent this from occurring, specify the `--upgrade-deps` flag:

```bash
$ python -m venv venv --upgrade-deps
```

## Managing venvs

There are two common locations for creating your virtual environments:

1. Inside the project's folder
2. In a centralized directory

In the project folder approach, the venv is created in the root folder of the
project and lives side-by-side with the code. You can activate your venv quickly
and you know which venv belongs to which project.

```bash
project/
|- venv/
|- src/
```

In the centralized directory approach, you keep **all** your virtual
environments in a single, centralized location. You can inspect all your venvs
in one place and manage them appropriately. However, it would be difficult to
activate them quickly.

```
venvs/
|- dev/
|- prod/
```

# References

- [Python Virtual Environments - A Primer](https://realpython.com/python-virtual-environments-a-primer/)
