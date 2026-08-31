# Operations

## Validate configuration

```bash
sudo hostinger-ddns test
```

## Compare DNS with public IPv4

```bash
sudo hostinger-ddns check
```

## Force synchronization

```bash
sudo hostinger-ddns update
```

## Inspect timer

```bash
systemctl list-timers hostinger-ddns.timer
sudo hostinger-ddns status
```

## Logs

```bash
sudo journalctl -u hostinger-ddns.service -n 100 --no-pager
sudo journalctl -u hostinger-ddns.service -f
```

## Local state

```bash
sudo cat /var/lib/hostinger-ddns/state
```

The local state is only an optimization. A full Hostinger API verification is forced after `FORCE_VERIFY_SECONDS`.
