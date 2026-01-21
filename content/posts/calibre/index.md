+++
title = "My problems with Calibre"
date = "2026-01-21"
updated = "2026-01-21"
draft = false

[taxonomies]
tags = ["calibre", "books"]

[extra]
toc = true
+++

[calibre](https://calibre-ebook.com/) is a great piece of software. It can
download and edit ebook metadata, convert ebooks between formats, perform
de-DRMing and has both an integrated ebook editor and reader. It has an
[extensive plugin
ecosystem](https://www.mobileread.com/forums/showthread.php?p=1362767#post1362767)
rooted in its [modular design
philosophy](https://manual.calibre-ebook.com/develop.html#design-philosophy),
and both a GUI and
[CLI](https://manual.calibre-ebook.com/generated/en/cli-index.html) for its
extensive features.

However, calibre is also lacking in many aspects. The one I'm most interested in is a
native API. While calibre does have a CLI with `calibredb` and the [calibre
Content server](https://manual.calibre-ebook.com/server.html) for listing and
viewing your library, there is no natively programmatic way of accessing your
calibre library without using its [Python
library](https://manual.calibre-ebook.com/develop.html#using-calibre-in-your-projects)
or installing (the extremely large) calibre binary on your devices.

This means that anyone that wishes to run scripts or build software around
calibre must use one of the following methods:

1. Use the calibre library and therefore be locked into using Python
2. Install the calibre binary and use `calibredb` and `calibre-debug` to access
   the calibre database
3. Access and modify the calibre sqlite database directly outside of the calibre
   software

Unfortunately, this feature won't be added to calibre any time sooner than
[AI](https://lwn.net/Articles/1049886/) is.

## Searching around

From my extensive searching, there are a few projects that try to tackle this
specific issue of exposing an API for language-agnostic access to the calibre
library. There is [calibre-web](https://github.com/janeczku/calibre-web),
[calibre-web-automated](https://github.com/crocodilestick/Calibre-Web-Automated)
and [Citadel](https://github.com/every-day-things/citadel), which are modern web
frontends to a calibre library, but none of them offer a API (REST, gRPC etc).
There are also applications that offer read-only access to a calibre library,
but I want something that allows for read-write access.

## calibre-rest

Eventually, I gave up my search and decided to write [my own API
server](https://github.com/kencx/calibre-rest). From the three methods above, I
wanted to see how feasible it was to manipulate the calibre database with
`calibredb` and its flags. For some (unknown) reason, I decided to write the
program in Python, BUT not use the Calibre Python library at all. This proof of
concept took me a weekend or two to write and I tried to implement 70% of
calibredb's functionality in a REST API, documented
[here](https://github.com/kencx/calibre-rest/blob/master/API.md).

If you're simply looking for a REST API for your calibre library, I believe this
POC would meet most of your needs. However, it does require the `calibredb` CLI
to be installed on the system hosting the API server, either locally or via
Docker. Unfortunately, this is a dealbreaker for me. Coupled with the fact that
`calibre-rest` is simply a server disguised as Python wrapper for a CLI tool, I
am choosing not to continue maintaining it. Currently, the project is tested
with calibre v6.21 only. Anyone is free to fork, test and maintain
`calibre-rest` for newer calibre versions.

## Manipulating the sqlite database

On happenstance, I also stumbled upon
[books](https://git.sr.ht/~ilikeorangutans/books/), which is written in Go and
Elm. It uses [sqlboiler](https://github.com/aarondl/sqlboiler) to generate CRUD
code in Go to access calibre's sqlite database. This implementation can be
easily extended to expose a REST API server, since we are manipulating the
calibre sqlite database directly.

Like `calibre-rest`, this method is closely dependent on changes made to
`calibre`, including the high risk that the database schema may change between
calibre versions. However, considering that calibre is widely used by many and
extensively tested, I do believe there will be little breaking changes that
drastically alter the database schema.

With the lack of other alternatives, and the added benefit that this method does
not lock you into a single programming language, this is looking to be the way
forward for me.

## Another POC soon...?

Generating boilerplate API code from a database schema is pretty common. From a
cursory search, there's [prisma](https://github.com/prisma/prisma),
[bob](https://github.com/stephenafamo/bob) and
[dbcore](https://github.com/eatonphil/dbcore), and I'm sure there are many more
in other languages.

I don't think I'll have a 2nd POC ready any time soon, with $WORK and all, but
I'll get around to it eventually... so look out for that I guess?
