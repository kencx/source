+++
title = "The difference between optional and blocking manual jobs in GitLab CI"
date = "2026-03-10"
updated = 2026-03-31

[taxonomies]
tags = ["gitlab", "ci/cd"]
+++

To create an optional job in GitLab CI, add `when: manual` to the job
configuration. Note that the location of `when: manual` determines the type of
manual job created:

- If defined outside `rules`, the job will default to `allow_failure: true`,
  making it optional. In this case, the pipeline can succeed - subsequent jobs
  can continue to run - if the manual job is not run or fails.
- If defined inside `rules`, the job defaults to `allow_failure: false`, making
  it blocking. The pipeline will stop at the stage where the job is defined. The
  blocking manual job must be run for the rest of the pipeline to proceed.

## References
- [GitLab - Job Control](https://docs.gitlab.com/ci/jobs/job_control/#types-of-manual-jobs)
