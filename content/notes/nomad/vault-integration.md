---
title: "Vault Integration"
date: 2023-07-15
lastmod: 2023-07-15
draft: false
toc: true
tags:
- nomad
- vault
---

Nomad can integrate with [Hashicorp
Vault](https://www.hashicorp.com/products/vault) to access secrets.

This requires Nomad to be provided a periodic Vault token with permissions to
create from a token role. Nomad servers will renew this token automatically.
Nomad clients do not need to be provided the token. The
[documentation](https://developer.hashicorp.com/nomad/docs/integrations/vault-integration)
provides detailed steps towards the setup.

An overview of the steps are as follows:

1. Create a `nomad_cluster` policy used by Nomad to create and manage tokens.
2. Create a Vault token role that Nomad will use to manage Vault tokens.
3. Configure Nomad to use the created token role.
4. Give Nomad servers a periodic token with the `nomad_cluster` policy
   previously.

When Nomad is given the periodic token, it automatically handles the token's
renewal. However, there can exist a case where Nomad is forced to restart
*after* the original token has expired. Although the token had been renewed, the
new tokens were never written to disk (because they are only available in
memory), and Nomad would have no available Vault token when it restarts.

## Automatic Vault Token Retrieval

For Nomad to fetch its own Vault token on startup, we use a helper script:

```bash
#!/usr/bin/env bash
# nomad-startup.sh

NOMAD_TOKEN="$(VAULT_ADDR=http://localhost:8200 \
    VAULT_TOKEN=[token] \
    vault write -field=token auth/token/create-orphan \
    "policies=nomad_cluster" \
    "period=72h")"

VAULT_TOKEN="$NOMAD_TOKEN" /usr/bin/nomad agent -dev -config /etc/nomad.d &
```

And pass it into the systemd file `nomad.service` with the `forking` type, which
starts Nomad as the main process of the script. This is required for reliable
signal handling.

```text
[Unit]
Description=Nomad
Wants=network-online.target
After=network-online.target vault.service

[Service]
Type=forking
ExecStart=/opt/nomad/data/nomad-startup.sh
```

There is still one major problem with this method - we need an already existing Vault token
to create this token.

### Authenticating to Vault

We can use Vault's certificate auth method to fetch the Vault token to be used
in the startup script.

{{< alert type="note" >}}
Certificate authentication requires Vault to be started with TLS.
{{< /alert >}}

```bash
$ vault write auth/cert/certs/nomad_startup \
	certificate=@/opt/nomad/tls/nomad_startup.crt \
	'token_policies=nomad_startup, nomad_cluster' \
	token_ttl=86400
```

This role is created with two policies:
- The existing `nomad_cluster` policy so that any tokens it creates can have
  access to the same policy
- A new `nomad_startup` policy:

```text
path "auth/token/create-orphan" {
  capabilities = ["create", "update", "sudo"]
}
```

- The `sudo` capability is required for the `create-orphan` path.

Finally, we use this cert auth method to authenticate to Vault and create a
token when Nomad is started:

```bash
#!/usr/bin/env bash
ADDR=https://localhost:8200

TOKEN="$(VAULT_ADDR=$ADDR vault login --token-only -method=cert \
    -client-cert=/opt/nomad/tls/nomad_startup.crt \
    -client-cert=/opt/nomad/tls/nomad_startup_key.pem)"

NOMAD_TOKEN="$(VAULT_ADDR=$ADDR VAULT_TOKEN=$TOKEN \
	vault write -field=token auth/token/create-orphan \
    "policies=nomad_cluster" \
    "period=72h")"

VAULT_TOKEN="$NOMAD_TOKEN" /usr/bin/nomad agent -config {{ nomad_config_dir }} &
```

## Alternatives
There are some alternatives to this convoluted method:

- In Vault 1.14, Vault agent has a new [Process Supervisor
  Mode](https://developer.hashicorp.com/vault/docs/agent-and-proxy/agent/process-supervisor)
  that can be used to run a command with secrets from Vault.
- There are [plans](https://github.com/hashicorp/nomad/issues/15617) to
  streamline the Vault Integration process by removing the need for Vault tokens
  completely. Instead, Nomad would be able to authenticate to Vault with the JWT
  Auth method.

## References
- [Nomad docs - Vault integration](https://developer.hashicorp.com/nomad/docs/integrations/vault-integration)
- [Nomad docs - Vault stanza](https://developer.hashicorp.com/nomad/docs/configuration/vault)
- [Nomad docs - Vault block in jobspec](https://developer.hashicorp.com/nomad/docs/job-specification/vault)
- [Hashicorp - template Block](https://developer.hashicorp.com/nomad/docs/job-specification/template#vault-kv-api-v2)
