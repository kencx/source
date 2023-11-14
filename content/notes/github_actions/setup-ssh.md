---
title: "Setup SSH"
date: 2023-11-15
lastmod: 2023-11-15
draft: false
toc: false
tags:
- github_actions
- ssh
---

To setup SSH, we need to:
- Create the `~/.ssh` directory
- Create the private key file with the proper permissions `0600`
- Save the host permanently as a known host to prevent being prompted with `ssh-keyscan`

```yml
name: setup ssh

on:
  push:
    branches:
	  - "master"

jobs:
  run:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup SSH
        shell: bash
        run: |
          eval $(ssh-agent -s)
          install -m 600 -D /dev/null ~/.ssh/id_ed25519
          echo "${{secrets.SSH_KEY}}" > ~/.ssh/id_ed25519
          ssh-keyscan -t rsa,dsa,ecdsa,ed25519 ${{secrets.SSH_HOST}} >> ~/.ssh/known_hosts
```

### Running SSH-Action
To execute remote SSH commands, we can opt to use the [appleboy/ssh-action](https://github.com/appleboy/ssh-action) action as well:

```yml
name: remote ssh command
on: [push]
jobs:

  build:
    runs-on: ubuntu-latest
    steps:
	  - name: executing remote ssh commands using ssh key
	    uses: appleboy/ssh-action@v1.0.0
	    with:
	      host: ${{ secrets.HOST }}
	      username: ${{ secrets.USERNAME }}
	      key: ${{ secrets.KEY }}
	      port: ${{ secrets.PORT }}
	      script: |
		    whoami
		    ls -al
```

There is also the [appleboy/scp-action](https://github.com/appleboy/scp-action) action.

## References
- [Github Actions - How to deploy to remote server using SSH](https://stackoverflow.com/questions/60477061/github-actions-how-to-deploy-to-remote-server-using-ssh)
