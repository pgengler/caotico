# Deploying caotico

caotico is deployed as a Docker container using [Kamal 2](https://kamal-deploy.org). The image is pushed to `ghcr.io/pgengler/caotico` and deployed to `hyperion.pgengler.net`, a multi-app server that already runs nginx for HTTP/HTTPS routing and SSL termination. Kamal Proxy runs behind nginx on a custom HTTP port (8080) and handles zero-downtime cutover between container versions.

## Architecture

```
Internet → nginx (SSL termination, Let's Encrypt) → Kamal Proxy (:8080) → app container (Thruster :80)
```

- **nginx** is the front-end reverse proxy. It terminates SSL using an existing Let's Encrypt certificate and routes requests for `pgengler.net` to Kamal Proxy on port 8080.
- **Kamal Proxy** runs on the server as a Docker container managed by Kamal. It receives HTTP traffic from nginx, performs health checks on new containers, and handles the zero-downtime switch between old and new versions during deploys.
- **The app container** runs the Rails app via Thruster on port 80 inside the container. Kamal Proxy routes traffic to it.

## Local prerequisites

Before you can deploy, your local machine needs the following:

- **Ruby 4.0.6** — match the version in `.ruby-version`. Use `asdf`, `rbenv`, or your preferred version manager.
- **Docker** — used by Kamal to build the production image. Install [Docker Desktop](https://www.docker.com/products/docker-desktop/) or Docker Engine for your platform.
- **Kamal 2** — install via `gem install kamal`, or use the bundled version with `bundle exec kamal` (the `kamal` gem is in the `Gemfile`).
- **direnv** — loads `.env` into your shell environment automatically when you enter the project directory. Kamal's `.kamal/secrets` references env vars (`$KAMAL_REGISTRY_PASSWORD`, `$CAOTICO_DATABASE_PASSWORD`) that must be present in the environment; direnv is how they get there for local deploys. Install via `brew install direnv`, then hook it into your shell by adding `eval "$(direnv hook bash)"` to `~/.bash_profile` (or the equivalent for zsh/fish — see `direnv hook --help`). Start a new shell afterward.
- **GitHub Personal Access Token (PAT)** — create a classic PAT with `write:packages` scope at [github.com/settings/tokens](https://github.com/settings/tokens). This is used to authenticate to the `ghcr.io` container registry. You'll provide it as `KAMAL_REGISTRY_PASSWORD`.
- **`config/master.key`** — the Rails master key for decrypting production credentials. This file is gitignored and must be present on your local machine. It will be injected into the container as `RAILS_MASTER_KEY`.

## First-time remote server setup

These steps are performed once on the remote server (`hyperion.pgengler.net`). Since the server already runs nginx and hosts other apps, some infrastructure is already in place.

### 1. SSH access

Ensure you can SSH into the server as the `apps` user (the SSH user configured in `config/deploy.yml`):

```bash
ssh apps@hyperion.pgengler.net
```

Add your public key to `~/.ssh/authorized_keys` for that user if it isn't already.

### 2. Install Docker

Kamal requires Docker Engine on the remote server. The server may not have Docker yet if the old app ran as a bare Puma process. If the `apps` user has sudo access, `kamal setup` can install Docker automatically. Otherwise, install it manually:

```bash
# On the server, as a user with sudo:
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker apps
```

Log out and back in for the group change to take effect, then verify:

```bash
docker ps
```

### 3. Configure PostgreSQL

PostgreSQL is already running on the host (the old app used it). You need to create a database and role for caotico:

```bash
sudo -u postgres createuser caotico
sudo -u postgres psql -c "ALTER USER caotico WITH PASSWORD '<your-strong-password>';"
sudo -u postgres createdb -O caotico caotico_production
```

Make note of the password — you'll need it for `CAOTICO_DATABASE_PASSWORD`.

If you're migrating data from the old app, this is the time to import it into `caotico_production`.

### 4. Allow the app container to reach PostgreSQL

The app runs inside a Docker container and needs to connect to PostgreSQL on the host. The easiest approach is to set a `DATABASE_URL` environment variable pointing at the host's gateway IP (typically `172.17.0.1` on default Docker networks):

```
DATABASE_URL=postgres://caotico:<password>@172.17.0.1:5432/caotico_production
```

Alternatively, ensure `pg_hba.conf` allows connections from the Docker network range and that PostgreSQL listens on the Docker bridge interface (not just `localhost`). You may need to set `listen_addresses = '*'` in `postgresql.conf` and add an appropriate `host` line in `pg_hba.conf`.

### 5. Configure nginx

Add or update the nginx server block for `pgengler.net` to proxy to Kamal Proxy on port 8080. The existing SSL certificate configuration stays as-is — only the `proxy_pass` target changes:

```nginx
server {
    listen 443 ssl;
    server_name pgengler.net;

    # Existing SSL certificate config (Let's Encrypt)
    ssl_certificate /etc/letsencrypt/live/pgengler.net/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/pgengler.net/privkey.pem;

    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-Proto https;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

Test and reload nginx:

```bash
sudo nginx -t
sudo systemctl reload nginx
```

> **Note:** If port 8080 is already in use by another service on the server, choose a different port and update both the nginx `proxy_pass` and `proxy.run.http_port` in `config/deploy.yml`.

### 6. Firewall

No firewall changes are needed — ports 80 and 443 are already open for nginx. Kamal Proxy listens on port 8080, which only needs to be reachable from nginx (i.e., localhost), so it does not need to be exposed externally.

## Configure secrets

Secrets are wired up across two files:

- **`.kamal/secrets`** (committed, safe for git) — maps each secret to either an environment variable (`$VAR`) or a command substitution (`$(cat config/master.key)`). You should not edit this file with raw values; it is checked into git and would leak credentials.
- **`.env`** (gitignored) — holds the actual secret values for local deploys. direnv loads this automatically (see [Local prerequisites](#local-prerequisites)).

Create `.env` in the project root with your real values:

```bash
# .env  (gitignored — never commit this)
KAMAL_REGISTRY_PASSWORD=<your-github-pat>
CAOTICO_DATABASE_PASSWORD=<your-postgres-password>
```

`RAILS_MASTER_KEY` does not go in `.env` — `.kamal/secrets` reads it directly from `config/master.key` via `$(cat config/master.key)`.

Then authorize direnv to load it (one-time, and again whenever `.envrc` changes):

```bash
direnv allow
```

After that, entering the project directory auto-exports `KAMAL_REGISTRY_PASSWORD` and `CAOTICO_DATABASE_PASSWORD` into your shell, and `kamal deploy` picks them up via `.kamal/secrets`.

If you're using `DATABASE_URL` instead of `CAOTICO_DATABASE_PASSWORD` (see step 4 above), add `DATABASE_URL` to `env.secret` in `config/deploy.yml`, add `DATABASE_URL=<your-url>` to `.env`, and reference it as `DATABASE_URL=$DATABASE_URL` in `.kamal/secrets`.

## First deploy

Once the server is set up, nginx is configured, and secrets are in place, run the initial setup from your local machine:

```bash
kamal setup
```

This will:

1. Build the Docker image locally (for `amd64` architecture).
2. Push the image to `ghcr.io/pgengler/caotico`.
3. Pull the image onto the server and boot the container.
4. Run `db:prepare` (via `bin/docker-entrypoint`) to create/migrate the database.
5. Start Kamal Proxy on port 8080 and register the app container with it.

Kamal will **not** provision an SSL certificate — that's already handled by nginx and Let's Encrypt.

### Migrating from the old app

If the old Perl/Puma app is still running, you can deploy caotico alongside it before cutting over:

1. Deploy caotico with `kamal setup` (it runs on port 8080 behind Kamal Proxy).
2. Verify the app works by hitting port 8080 directly: `curl -H "Host: pgengler.net" http://127.0.0.1:8080/up` (from the server).
3. Once satisfied, update the nginx `proxy_pass` to point to `127.0.0.1:8080` and reload nginx.
4. Shut down the old Puma process.

### Verify the deploy

Check that the app is responding through nginx:

```bash
curl -I https://pgengler.net/up
```

You can also inspect the running container:

```bash
kamal app exec rails runner 'puts "app is up"'
kamal app logs
```

## Deploying new versions

There are two ways to deploy: via GitHub Actions (recommended) or manually from your local machine.

### Via GitHub Actions

A manually-triggered GitHub Actions workflow is defined in `.github/workflows/deploy.yml`. To use it, you first need to configure the following repository secrets under **Settings → Secrets and variables → Actions**:

| Secret                      | Description                                                       |
| --------------------------- | ----------------------------------------------------------------- |
| `SSH_PRIVATE_KEY`           | SSH private key for the `apps` user on `hyperion.pgengler.net`    |
| `KAMAL_REGISTRY_PASSWORD`   | GitHub PAT with `write:packages` scope (for pushing to `ghcr.io`) |
| `RAILS_MASTER_KEY`          | Contents of `config/master.key`                                   |
| `CAOTICO_DATABASE_PASSWORD` | PostgreSQL password for the `caotico` role                        |

Once the secrets are configured, trigger a deploy by going to **Actions → Deploy → Run workflow** in the GitHub UI. The workflow will:

1. Check out the code and set up Ruby 4.0.6.
2. Configure SSH access to the server using the `SSH_PRIVATE_KEY` secret.
3. Write the Kamal secrets file from the remaining secrets.
4. Run `kamal deploy`, which builds the Docker image, pushes it to `ghcr.io`, and rolls it out on the server with zero downtime.

### From your local machine

Make sure `.kamal/secrets` is populated (see [Configure secrets](#configure-secrets)), then run:

```bash
kamal deploy
```

### How deploys work

Either method builds a new image, pushes it, and performs a zero-downtime rollout on the server. Kamal Proxy keeps the old container running while the new one boots and passes health checks, then switches traffic over. The entrypoint script (`bin/docker-entrypoint`) automatically runs `db:prepare` on boot, so database migrations are applied as part of every deploy — no manual migration step is needed.

### Rolling back

If a deploy goes wrong, roll back to the previous version:

```bash
kamal app rollback
```

### Useful commands

| Command                | Description                               |
| ---------------------- | ----------------------------------------- |
| `kamal app logs`       | Tail the Rails app logs                   |
| `kamal app exec <cmd>` | Run a command inside the app container    |
| `kamal app exec bash`  | Get an interactive shell in the container |
| `kamal proxy reboot`   | Restart Kamal Proxy                       |
| `kamal audit`          | Show deploy history                       |

## Notes and troubleshooting

- **Asset bridging:** `config/deploy.yml` sets `asset_path: /app/public/assets`, which tells Kamal to bridge fingerprinted assets (JS, CSS) between the old and new versions during rollout. This prevents 404 errors for in-flight requests that reference the previous version's assets.

- **Automatic migrations:** `bin/docker-entrypoint` runs `rails db:prepare` on every container boot. This creates the database if it doesn't exist and runs any pending migrations. There is no need to run migrations manually.

- **Rotating the registry PAT:** Generate a new GitHub PAT, update `KAMAL_REGISTRY_PASSWORD` in `.env` (for local deploys — direnv reloads automatically) or in the GitHub repository secrets (for Actions deploys), and run `kamal deploy`. The new token is used for the next image push.

- **Rotating the master key:** If you regenerate `config/master.key` (and re-encrypt credentials), no `.env`/`.kamal/secrets` change is needed — `.kamal/secrets` reads the key file directly via `$(cat config/master.key)`. Just redeploy. Be aware that existing encrypted data (e.g., in the database) encrypted with the old key will no longer be decryptable.

- **Non-root container:** The Dockerfile runs the app as a non-root `rails` user (UID 1000). The app serves on port 80 via [Thruster](https://github.com/basecamp/thruster/), which handles X-Sendfile and HTTP/2.

- **Multiple apps on the same server:** Kamal Proxy supports host-based routing for multiple apps. Each app needs its own `config/deploy.yml` with a unique `proxy.host` and `proxy.run.http_port`. nginx routes each domain to the corresponding Kamal Proxy port.
