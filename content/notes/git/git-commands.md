---
title: "Git Commands"
date: 2021-12-03T23:59:42+08:00
draft: false
toc: false
images:
---

## Amending a pushed commit
Modify the last commit with `--amend` if you:
- Forgot to add a modified file
- Want to amend the commit message

1. Perform and add all necessary changes.
```bash
$ git add changes.md
```

2. Amend the commit with
```bash
$ git commit --amend [--no-edit]
```
`--no-edit` is included if you do not wish to replace the commit message

3. If the amended commit has **already been pushed** to your remote, use
```bash
$ git push -f <remote-name> <branch_name>
```
Note: Ensure no other changes have been made by others before you push.

## Commit with message file
Prepare a git commit message in advance by writing to a file. When ready to
commit, pass it to git with
```bash
$ git commit -eF message.txt
```

## SSH keys
1. Generate a new [SSH key](/notes/ssh-cheatsheet) and add it to `ssh-agent`

2. Add the **public** key to Github under Settings > SSH and GPG keys

3. Test the SSH connection with Github with
```bash
$ ssh -vT git@github.com
```
To troubleshoot errors, refer [here](https://docs.github.com/en/authentication/troubleshooting-ssh/error-permission-denied-publickey).

4. Finally, ensure the repository's remote is set to SSH instead of HTTP
```bash
$ git remote set-url origin git@github.com:<username>/<repo>.git
```

## References
[ohshitgit](https://ohshitgit.com)
