---
title: "Automating my Resume"
date: 2023-08-21
lastmod: 2024-01-22
draft: true
toc: true
tags:
- automation
- resume
- pandoc
---

{{< details "Summary" >}}
I discuss how I automated the generation of my resume in multiple formats (`.pdf,
.html, .docx`)
{{< /details >}}

{{< details "Edit" >}}
This post was previously written on 2023-08-21. I have since rewritten it on
2024-03-01 as I felt that the original was unclear and lacking.
{{< /details >}}

Recently, I had began job hunting and began the process of updating my resume.
In the midst of procrastination, I came across
[jsonresume](https://jsonresume.org/), which gave me the idea of automating the
generation of my resume. I wasn't the first to have this idea and these projects
have been an immense help in guiding me as I navigated the deep rabbit hole into
[pandoc](https://pandoc.org/).

## Process

All resume data will be defined in a JSON schema as defined by jsonresume. This
provides a version-controlled, declarative and machine-readable document that
will be consumed by the Pandoc.

I aim to build my resume in three formats: pdf, html and docx. These formats
will be built with Pandoc automatically with GitHub Actions when there is any
change to the JSON input. All formats should be identical in content and design
(the tricky part) and an added bonus would be if they all came from the same
template.

## Pandoc

Pandoc can be used to generate dynamic documents with
[templates](https://pandoc.org/MANUAL.html#templates) and
[variables](https://pandoc.org/MANUAL.html#interpolated-variables) provided via
a [metadata file](https://pandoc.org/MANUAL.html#option--metadata-file). In our
use case, we will be passing our resume content to Pandoc templates via a JSON
file with jsonresume's schema:

```goat
              +-->  Latex template --->  PDF
 json        /
content ----+
             \
              +-->  Markdown template --->  Intermediate Markdown --->  HTML
```

### LaTeX to PDF

This method was the most straightforward as I simply turned my existing LaTeX
document into a template:

```bash
$ pandoc --defaults defaults.yml \
    --template templates/resume.pandoc.tex \
    --metadata-file=schema.json \
    --output=outputs/resume.pdf README.md
```

### Markdown to HTML

This was a bit more challenging. Firstly, I tried to generate HTML from the
LaTeX template above, but the results were undesirable without writing custom
Pandoc filters. Next, I turned to converting Markdown to HTML, which I
found to be more flexible as it allowed for more control over the generated
elements.

However, I also wanted to recreate the LaTeX layout with HTML tables. While
Pandoc does support 4 different types of Markdown tables, none support all the
features I required (colspan, column-specific alightment and multiline rows).

I found that [RST-style list
tables](https://docutils.sourceforge.io/docs/ref/rst/directives.html#list-table)
supported all these features, but they were unsupported in native Pandoc.
Fortunately, I discovered a [Lua
filter](https://github.com/pandoc-ext/list-table) that allowed their use in
Pandoc Markdown.

As an example, here is a `Experience` section of the Markdown resume template in
the form of a RST-style list table and Pandoc variables:

```markdown
$for(work)$
:::{.list-table aligns=l,r header-rows=0}
   * - **$it.name$**
     - **$it.startDate$ — $it.endDate$**

   * - $it.position$
     - $it.location$

   * - []{colspan=2}
   <ul>
$for(it.highlights)$
     <li>$it$</li>
$endfor$
   </ul>
:::
$endfor$
```

- The list tables must be wrapped in Pandoc's [fenced
  divs](https://pandoc.org/MANUAL#extension-fenced_divs), represented by `:::`
- We also nest HTML lists (`<ul>` and `<li>`) within the final list table row
  and allow them to span both columns with `[]{colspan=2}`. These correspond to
  the entry's list of points.

This method requires two steps:

1. Build an intermediate Markdown file with the metadata variables
2. Converting the intermediate Markdown into our final HTML file

```bash
$ pandoc --defaults defaults.yml \
    --template templates/resume.pandoc.md \
    --metadata-file=schema.json \
    --output=outputs/intermediate.md README.md

$ pandoc --defaults defaults.yml \
    --output=outputs/resume.html outputs/intermediate.md
```

Pairing this with [latex.css](https://latex.vercel.app/) and some custom style
tweaks, the result is a fully-responsive, print-friendly HTML resume that's
identical to the HTML version.

## Screenshots

Both methods generated resumes that are very similar, barring some differences
in font size and margins.

{{< figure src="resume.png" caption="HTML (left) and PDF (right)" >}}

{{< alert type="note" >}}
Comparing them made me realize how cluttered the HTML version looks relative to
its counterpart. Tweaking the font size to allow for some whitespace would greatly
improve this.
{{< /alert >}}

The HTML is hosted on [resume.cheo.dev](https://resume.cheo.dev), which also
offers the PDF version for download. I avoided including my mobile number on
these online versions (for privacy and spam reasons), but I do include it when I
send them in for job applications. If you would like my unredacted resume, drop
me an email.

## Build Script

While building Pandoc documents are as simple as running the relevant commands,
I decided to make the build process more robust by writing a build script in
Python with [pypandoc](https://github.com/JessicaTegner/pypandoc) and
containerizing it with
[Docker](https://github.com/kencx/resume/blob/master/Dockerfile). The same could
be replicated with a local Pandoc installation and a `Makefile`.

## CI/CD

Finally, Github Actions runs the entire pipeline:

```yml
name: Build
on:
  push:
    branches: [master]
  pull_request:

jobs:
  build:
    runs-on: ubuntu-latest
    permissions:
      contents: write
    steps:
      - name: Checkout codebase
        uses: actions/checkout@v3

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2

      - name: Build custom Pandoc Docker image
        uses: docker/build-push-action@v4
        with:
          context: .
          file: Dockerfile
          load: true
          tags: kencx/pandoc:latest
          cache-from: type=gha
          cache-to: type=gha,mode=max

      - name: Build sample resume
        run: docker compose run --rm pandoc

      - name: Deploy sample resume to GitHub Pages
        run: |
          git worktree add gh-pages
          git config user.name "Deploy from CI"
          git config user.email ""

          cd gh-pages
          # Delete the ref to avoid keeping history.
          git update-ref -d refs/heads/gh-pages
          rm -rf *
          mv ../static ../outputs/resume.* .
          mv resume.html index.html
          git add .
          git commit -m "Deploy $GITHUB_SHA to gh-pages"
          git push --force --set-upstream origin gh-pages

      - name: Build resume
        run: docker compose run --rm pandoc --metadata custom.json

      - name: SCP files to server
        uses: appleboy/scp-action@v0.1.4
        with:
          host: ${{ secrets.HOST }}
          username: ${{ secrets.USERNAME }}
          key: ${{ secrets.KEY }}
          port: ${{ secrets.PORT }}
          source: "outputs/resume.*,static"
          target: /home/${{ secrets.USERNAME }}/resume
          strip_components: 1
          overwrite: true
```

This workflow builds two resumes: a [sample one](https://kencx.github.io/resume)
hosted on Github Pages as a demo and my [actual resume](https://resume.cheo.dev)
on my webserver.

The sample was just to test that this actually works, but I
decided to keep it in.

## Future

There's still much to do but I really have to continue finding a job, so here's
what is missing or could be improved still:

- Support docx generation
- Use LaTeX to generate HTML resume or use HTML to generate PDF resume

## References

- [pandoc](https://pandoc.org/)
- [How I create and manage my CV using Markdown & Pandoc](https://chainsawonatireswing.com/2013/05/28/how-i-create-manage-my-cv-using-markdown-pandoc/)
- [jacksenechal/resume](https://github.com/jacksenechal/resume)
- [samijuvonen/pandoc_resume_template](https://github.com/samijuvonen/pandoc_resume_template)
