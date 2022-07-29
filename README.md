# Source
This repo contains the source code for my
[kencx.github.io](https://kencx.github.io) built by Hugo

This is a modified Jekyll theme [Dark
Reader](https://github.com/sharadcodes/jekyll-theme-dark-reader) that was ported
over to Hugo

Commits pushed to this repository are deployed to `kencx/kencx.github.io`
automatically. Refer to [this
article](https://www.mytechramblings.com/posts/create-a-website-with-hugo-and-gh/)
for reference on deployment with Hugo and Github Pages.

## New content
To quickly create new content, use the following `hugo new` commands.

For posts:
```bash
$ hugo new posts/[title].md
```

For note of existing category:
```bash
$ hugo new notes/[category]/[title].md
```

For notes of new category:
```bash
$ hugo new --kind note-bundle notes/[category]
```

## TODO
- scroll to top
- toc
- Mobile support - icons, navbar wrap
