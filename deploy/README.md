# Oracle deployment

This directory runs the free, self-hosted n8n Community edition on the existing Oracle ARM server. It joins the dashboard's Docker network; the dashboard's Caddy proxy serves `https://n8n.hisse-analizi.duckdns.org`.

The server's `deploy/.env` contains a randomly generated `N8N_ENCRYPTION_KEY`. Keep it private and backed up: losing it makes saved credentials unreadable. The `n8n_data` Docker volume holds the SQLite database and other n8n state. Neither the volume nor `.env` is tracked by Git.

Run or update from this directory with `docker compose up -d`. The image is pinned to `1.123.83`, compatible with the workflow's n8n v1 requirement. Review a newer version and take a backup before changing the pin.

The `backup.sh` script makes a consistent SQLite backup plus an encryption-key copy in `~/backups/n8n`, verifies database integrity, and keeps 14 days of local backups. The encryption key is also copied to the Mac at `~/.config/hisse-n8n/encryption-key`.

The workflow is imported but inactive. After the n8n owner creates their account, they must add a Google Gemini credential and an SMTP credential, replace `sender@example.com` and `recipient@example.com` in the `Configuration` node, run one manual test, then activate the workflow. It is scheduled for 10:00 Europe/Istanbul. The dashboard's Caddy proxy has an additional gateway password, stored on the Mac at `~/.config/hisse-n8n/gateway-password`.
