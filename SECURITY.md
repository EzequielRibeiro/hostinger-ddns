# Security

## Secrets

Never commit a real Hostinger API token to this repository.

The runtime token belongs only in:

```text
/etc/hostinger-ddns/token
```

Recommended permissions:

```bash
sudo chmod 600 /etc/hostinger-ddns/token
```

If a token is accidentally committed, revoke it immediately in Hostinger and create a replacement before removing it from Git history.

## Reporting a vulnerability

Please open a private security advisory in GitHub when available instead of publishing credentials or exploit details in a public issue.
