---
title: "Automating my Resume"
date: 2023-08-21
lastmod: 2024-01-22
draft: false
toc: true
tags:
- automation
- resume
- pandoc
---

I recently started job hunting again and had to update my resume. As an excuse
to procrastinate sending out applications, I decided that this was the best time
to automate the generation of my resume: something I do perhaps once a year.

{{< figure src="https://imgs.xkcd.com/comics/is_it_worth_the_time.png" caption="relevant xkcd #1205" link="https://xkcd.com/1205" class="center" >}}

There's a [bunch](https://github.com/xitanggg/open-resume)
[of](https://github.com/AmruthPillai/Reactive-Resume)
[resume](https://github.com/topics/resume-builder) building sites out there,
mostly catered for people in Tech, but many involve creating an account on their
sites and using one of their templates. That's not really my thing.

I also have an existing resume in LaTeX, which I could just use to build a PDF
automatically with Github Actions, and call it a day, but there's no fun in
that. Instead, I wanted to over-engineer a full pipeline that automatically
builds a resume in three different formats:

1. pdf
2. html to host a static site (because why not?)
3. docx for the occasional recruiter that *only* accepts Word documents

All formats should be identical (in content and design) and bonus points if they
all come from a single template. To implement this, we turn to
[Pandoc](https://pandoc.org/) and [jsonresume](https://jsonresume.org/) which
consume a version-controlled, declarative and machine-readable schema and
outputs the formats above.

>The code for this project can be found at
>[kencx/resume](https://github.com/kencx/resume).

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

{{< alert type="note" >}}
Building `docx` files are more complex than I expected, and they are still a
WIP.
{{< /alert >}}

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

{{< figure src="/posts/images/resume.png" caption="HTML (left) and PDF (right)" >}}

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
