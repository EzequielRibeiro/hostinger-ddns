# Changelog

## 1.1.0 - 2026-08-30

- Added `hostinger-ddns verify` to compare the public IPv4 with Hostinger API, authoritative DNS, Cloudflare, Google, Quad9 and the local resolver.
- Added `hostinger-ddns verify --update` to force an update when a divergence is detected and then repeat verification.
- Added `hostinger-ddns update --force` to bypass the local cache and force writing the current public IPv4 to Hostinger.
- Installer now installs `dnsutils` for authoritative/public DNS verification.

## 1.0.0 - 2026-08-30

- Initial public release.
- Dynamic IPv4 update for `controller.capivaradsm.com.br` using Hostinger DNS API.
- Local state cache to avoid unnecessary API calls.
- Forced DNS revalidation every 24 hours by default.
- systemd service and timer.
- Installer and uninstaller.
- ShellCheck CI.
- Token kept outside the repository.
