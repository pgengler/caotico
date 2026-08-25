# Deploying caotico

caotico is deployed as a Docker container using [Kamal 2](https://kamal-deploy.org). The image is pushed to `ghcr.io/pgengler/caotico` and deployed to the server `hyperion.pgengler.net`, where Kamal's reverse proxy handles SSL via Let's Encrypt for `pgengler.net`.

## Local prerequisites

Before you can deploy, your local machine needs the following:

- **Ruby 4.0.6** — match the version in `.ruby-version`. Use `asdf`, `rbenv`, or your preferred version manager.
- **Docker** — used by Kamal to build the production image. Install [Docker Desktop](https://www.docker.com/products/docker-desktop/) or Docker Engine for your platform.
- **Kamal 2** — install via `gem install kamal`, or use the bundled version with `bundle exec kamal` (the `kamal` gem is in the `Gemfile`).
- **GitHub Personal Access Token (PAT)** — create a classic PAT with `write:packages` scope at [github.com/settings/tokens](https://github.com/settings/tokens). This is used to authenticate to the `ghcr.io` container registry. You'll provide it as `KAMAL_REGISTRY_PASSWORD`.
- **`config/master.key`** — the Rails master key for decrypting production credentials. This file is gitignored and must be present on your local machine. It will be injected into the container as `RAILS_MASTER_KEY`.

## First-time remote server setup

These steps are performed once on the remote server (`hyperion.pgengler.net`).

### 1. SSH access

Ensure you can SSH into the server as the `pgengler-net` user (the SSH user configured in `config/deploy.yml`):

```bash
ssh pgengler-net@hyperion.pgengler.net
```

Add your public key to `~/.ssh/authorized_keys` for that user if it isn't already.

### 2. Install Docker

Kamal requires Docker Engine on the remote server. If the `pgengler-net` user has sudo access, `kamal setup` can install Docker automatically. Otherwise, install it manually:

```bash
# On the server, as a user with sudo:
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker pgengler-net
```

Log out and back in for the group change to take effect, then verify:

```bash
docker ps
```

### 3. Install and configure PostgreSQL

PostgreSQL runs on the host server (not as a Kamal accessory). Install it and create the database and role:

```bash
# Install PostgreSQL (Debian/Ubuntu)
sudo apt-get update
sudo apt-get install -y postgresql postgresql-contrib

# Create the database role and set a password
sudo -u postgres createuser caotico
sudo -u postgres psql -c "ALTER USER caotico WITH PASSWORD '<your-strong-password>';"
sudo -u postgres createdb -O caotico caotico_production
```

Make note of the password — you'll need it for `CAOTICO_DATABASE_PASSWORD`.

### 4. Allow the app container to reach PostgreSQL

The app runs inside a Docker container and needs to connect to PostgreSQL on the host. The easiest approach is to set a `DATABASE_URL` environment variable pointing at the host's gateway IP (typically `172.17.0.1` on default Docker networks):

```
DATABASE_URL=postgres://caotico:<password>@172.17.0.1:5432/caotico_production
```

Alternatively, ensure `pg_hba.conf` allows connections from the Docker network range and that PostgreSQL listens on the Docker bridge interface (not just `localhost`). You may need to set `listen_addresses = '*'` in `postgresql.conf` and add an appropriate `host` line in `pg_hba.conf`.

### 5. Firewall

Allow HTTP and HTTPS traffic:

```bash
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
```

Kamal's reverse proxy (running on the server) handles SSL certificate provisioning via Let's Encrypt and routes traffic to the app container on port 80.

## Configure secrets

Secrets are defined in `.kamal/secrets` and referenced from `config/deploy.yml`. Edit `.kamal/secrets` to provide the actual values:

```bash
# .kamal/secrets
KAMAL_REGISTRY_PASSWORD=<your-github-pat>
RAILS_MASTER_KEY=$(cat config/master.key)
CAOTICO_DATABASE_PASSWORD=<your-postgres-password>
```

> **Note:** `CAOTICO_DATABASE_PASSWORD` is referenced by `config/database.yml` but is **not currently listed** in `config/deploy.yml` under `env.secret`. You must add it before deploying. In `config/deploy.yml`, update the `env.secret` section:
>
> ```yaml
> env:
>   secret:
>     - RAILS_MASTER_KEY
>     - CAOTICO_DATABASE_PASSWORD
> ```
>
> If you're using `DATABASE_URL` instead (see step 4 above), add `DATABASE_URL` to `env.secret` and provide it in `.kamal/secrets` instead of (or in addition to) `CAOTICO_DATABASE_PASSWORD`.

## First deploy

Once the server is set up and secrets are configured, run the initial setup from your local machine:

```bash
kamal setup
```

This will:
1. Build the Docker image locally (for `amd64` architecture).
2. Push the image to `ghcr.io/pgengler/caotico`.
3. Pull the image onto the server and boot the container.
4. Run `db:prepare` (via `bin/docker-entrypoint`) to create/migrate the database.
5. Provision the Let's Encrypt SSL certificate for `pgengler.net`.
6. Start the reverse proxy and route traffic to the container.

### Verify the deploy

Check that the app is responding:

```bash
curl -I https://pgengler.net/up
```

You can also inspect the running container:

```bash
kamal app exec rails runner 'puts "app is up"'
kamal app logs
```

## Deploying new versions

For routine deploys after the initial setup:

```bash
kamal deploy
```

This builds a new image, pushes it, and performs a zero-downtime rollout on the server. The entrypoint script (`bin/docker-entrypoint`) automatically runs `db:prepare` on boot, so database migrations are applied as part of every deploy — no manual migration step is needed.

### Rolling back

If a deploy goes wrong, roll back to the previous version:

```bash
kamal app rollback
```

### Useful commands

| Command | Description |
|---|---|
| `kamal app logs` | Tail the Rails app logs |
| `kamal app exec <cmd>` | Run a command inside the app container |
| `kamal app exec bash` | Get an interactive shell in the container |
| `kamal proxy reboot` | Restart the reverse proxy |
| `kamal audit` | Show deploy history |

## Notes and troubleshooting

- **Asset bridging:** `config/deploy.yml` sets `asset_path: /app/public/assets`, which tells Kamal to bridge fingerprinted assets (JS, CSS) between the old and new versions during rollout. This prevents 404 errors for in-flight requests that reference the previous version's assets.

- **Automatic migrations:** `bin/docker-entrypoint` runs `rails db:prepare` on every container boot. This creates the database if it doesn't exist and runs any pending migrations. There is no need to run migrations manually.

- **Rotating the registry PAT:** Generate a new GitHub PAT, update `KAMAL_REGISTRY_PASSWORD` in `.kamal/secrets`, and run `kamal deploy`. The new token is used for the next image push.

- **Rotating the master key:** If you regenerate `config/master.key` (and re-encrypt credentials), update `RAILS_MASTER_KEY` in `.kamal/secrets` and redeploy. Be aware that existing encrypted data (e.g., in the database) encrypted with the old key will no longer be decryptable.

- **Non-root container:** The Dockerfile runs the app as a non-root `rails` user (UID 1000). The app serves on port 80 via [Thruster](https://github.com/basecamp/thruster/), which handles X-Sendfile and HTTP/2.
