+++
title = "Notes on GitLab CI/CD templating"
date = "2026-10-20"
updated = 2026-10-20

[taxonomies]
tags = [ "gitlab", "ci/cd" ]

[extra]
toc = true
+++

## CI/CD templates

- Try not to nest templates for more than 4-5 levels. It can be difficult to
  ascertain which layer of the job's template is defining a specific key.
- Templates should not contain `rules` blocks. unless you're defining a shared
  `rules` template for multiple jobs. These should be specified in the actual
  job block.

### Templates repository structure

I recommend the following structure for a shared templates repository

```
.
├─ templates
├─ jobs
│   └─ MAIN.gitlab-ci.yml
└─ helpers
```

- Base template files go into `templates/`. These include stuff like
  `.build-docker-image` or `.secret-detection-scan`
- Base template files should NOT depend on each other, i.e. they should not have
  any `include` for files in the same `templates/` folder. Doing so can easily
  create cyclic dependencies.
- If there is a need to create templates that depend on multiple base templates,
  put them in `jobs/`. These are for secondary templates that consume base
  templates.
- Partial templates are those that only define partial keys like `script` or
  `variables` that are common to multiple jobs. They do not contain any `stage`
  or `image` keys, and thus cannot be used as a standalone template. These
  partial templates go into `helpers`.

### A shared MAIN.gitlab-ci.yml

In the above structure, I also defined a `jobs/MAIN.gitlab-ci.yml`. This file
contains the following:

```yml
stages:
- lint
- test
- build
- scan
- approval
- deploy

include:
- templates/lint.yml
- templates/test.yml
- templates/build.yml
- templates/scan.yml
- templates/approval.yml
- templates/deploy.yml
```

When working in a multi-repo project, I often have multiple repositories consuming the
same templates repository with the same `stages` and `include` keys. This file
helps to consolidate such common configuration into one place so that we only
have to define this in all project repositories `.gitlab-ci.yml`:

```yml
include:
  - project: "my-group/cicd-templates"
    ref: main
    file: jobs/MAIN.gitlab-ci.yml
```

This file is also useful to define any shared jobs that will be the same in all
repositories (eg. `secret_detection` and `semgrep-sast` scans)

## Needs and dependencies

- Don't use `needs` unless an explicit DAG is required between jobs. Assigning
  appropriate stages to jobs is sufficient to let jobs wait for those in earlier
  stages. Using `needs` makes refactoring the pipeline more difficult as the
  renaming or removal of a job can cause dependency errors in downstream jobs
- Use `dependencies` to download artifacts from parent jobs instead of `needs`.
- Use `artifacts: false` with `needs` if the dependent job doesn't need to
  download any artifacts
- Use `dependencies: []` for jobs that don't need to consume any artifacts. When
  `dependencies` is not defined at all, ALL jobs in earlier stages are
  considered dependent and the job will fetch ALL their artifacts. This can
  considerably slow down the job and consume unnecessary bandwidth.

## Know when to use parallel:matrix

- If you have 2 matrix jobs with `parallel:matrix` defined, it is not possible
  to do a 1-to-1 matching of artifacts. For example, in the `push` and `deploy`
  jobs, I may have the following matrix jobs:

  ```
  push
    push-A
    push-B
    push-C

  deploy
    deploy-A
    deploy-B
    deploy-C
  ```

  And I want `deploy-A` to fetch the artifacts of `push-A`. For this case, it is
  not possible to define dependencies without depending on the entire `push` job. However, doing `dependencies: push` will download artifacts from all matrix jobs, which can detrimental if there are many child jobs with large artifacts. In these cases, I find it easier to define separate push and deploy jobs for A, B and C, so that they can consume artifacts from each other easily.

- It is currently not possible to customize the name of a matrix job. The name
  will default to `<job-name>[<var-1>,<var-2>,<var-3>]` which can be unwieldy
  when there are many `parallel:matrix` variables.

## Manual jobs

When using `when: manual` to define manual jobs, the location of the key
determines the type of manual job created:

- If defined outside `rules`, the job will default to `allow_failure: true`,
  making it fully optional. In this case, the pipeline can succeed - subsequent
  jobs can continue to run - if the manual job is not run or fails.
- If defined inside `rules`, the job defaults to `allow_failure: false`, making
  it blocking. The pipeline will stop at the stage where the job is defined. The
  blocking manual job must be run for the rest of the pipeline to proceed.

## Speeding up jobs

- Use `GIT_STRATEGY: none` for jobs that don't need to clone the entire
  repository to run.
- Use `artifacts: false` with `needs` if the dependent job doesn't need to
  download any artifacts, as mentioned [previously](#needs-and-dependencies)
- Use `dependencies: []` for jobs that don't consume any artifacts, as mentioned
  [previously](#needs-and-dependencies)

## Artifacts and reports

- GitLab supports a [multitude of artifact report
  types](https://docs.gitlab.com/ci/yaml/artifacts_reports/) that can be
  consumed and be used to display information in merge requests or dashboards

## Terraform

WIP

## References
