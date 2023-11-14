---
title: "Run Ansible Playbook"
date: 2023-11-15
lastmod: 2023-11-15
draft: false
toc: false
tags:
- ansible
- github_actions
---

Before running the playbook, we must [setup SSH]({{< relref "notes/github_actions/setup-ssh" >}}) in the actions runner:

```yml
name: ansible playbook

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

      - name: Run playbook
        shell: bash
        run: |
          service ssh status
          ansible-playbook --private-key /home/runner/.ssh/id_ed25519 -i ${{secrets.SSH_HOST}}, main.yml
```

The inventory can be passed as:
- A string with secrets (remember the `,` at the end)
- A committed file in the repository
- A dynamic inventory

## References
- [How to run Ansible playbook from Github Actions](https://stackoverflow.com/questions/74048180/how-to-run-ansible-playbook-from-github-actions-without-using-external-action)
- [Github Actions - How to deploy to remote server using SSH](https://stackoverflow.com/questions/60477061/github-actions-how-to-deploy-to-remote-server-using-ssh)
