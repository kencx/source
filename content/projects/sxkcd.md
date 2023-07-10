---
title: "sxkcd"
date: 2022-07-01T09:55:25+08:00
lastmod:
weight: 3
draft: false
repo_url: https://github.com/kencx/sxkcd
post_url:
tools:
- Go
- Redis
- Svelte(-kit)
- Docker
---

A real-time full-text [XKCD](https://xkcd.com) search engine that supports an extensive
query syntax, and comic number and date filtering. Redis is used as a document indexer
and database to provide very quick search results. The webapp is hosted on Hetzner at
[sxkcd.lol](https://sxkcd.lol)
