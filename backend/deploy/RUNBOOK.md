# Runbook — deploy Fashion Store API to fashionapp.api.hpn.world

Everything below is either **`you do on the VPS`** or **one Mac command**.
The Mac side is `backend/deploy/deploy.sh`.

| Thing        | Value                                  |
|--------------|----------------------------------------|
| API host     | `fashionapp.api.hpn.world`             |
| App URL      | `https://fashionapp.api.hpn.world/api` |
| Server       | `169.58.139.98` (Contabo VPS)          |
| SSH alias    | `panha` (also `nextgen`)               |
| Container    | `fashion-api` on `127.0.0.1:8001`      |

---

## Step 0 — Status

- [x] **DNS** — A record `fashionapp.api` → `169.58.139.98` added on Namecheap;
      `dig +short fashionapp.api.hpn.world` returns `169.58.139.98` (verified
      2026-09-29). certbot can now issue for this hostname.
- [x] **API container** — built and running as project `fashion` on
      `127.0.0.1:8001`, seeded, `/docs` + `/api/products` return 200.
- [ ] **SSH key unlocked** — `~/.ssh/nextgen_vps` is passphrase-protected. For
      the agent to survive between commands, run in your terminal:
      ```bash
      eval "$(ssh-agent -s)"
      ssh-add ~/.ssh/nextgen_vps          # type the passphrase once
      ```
      Then point automation at the agent socket (macOS puts it under
      `$TMPDIR/ssh-*/agent.*`):
      ```bash
      lsof -p "$(pgrep -n ssh-agent)" | grep agent\\.
      export SSH_AUTH_SOCK=<path from the line above>
      ```
- [ ] **nginx + HTTPS** — run `ssh -t panha 'bash ~/finish_fashion.sh'`
      (steps 3–4 below). Needs your sudo password.

---

## Step 1 — Confirm the VPS is in the expected state (VPS)

```bash
ssh panha
docker --version && docker compose version
systemctl is-active nginx                        # expect: active
ss -tlnp | grep -E ':(80|443|8000|8001)\b'       # 8000 = NextGen, must stay
sudo ufw status                                  # 26078, 80, 443 allowed
```

If nginx is `inactive` or missing, **stop** — NextGen depends on it.

---

## Step 2 — Upload and start the API (Mac)

```bash
cd /Users/lyznhara/Desktop/pj/mobile_application2/fashion_app/backend/deploy
./deploy.sh
```

The script rsyncs `backend/` to `panha:~/fashion-api/`, pushes the production
`.env`, runs `docker compose up -d --build`, then checks container status,
startup logs, the local endpoint and the public endpoint.

Prefer doing it by hand? The steps are `../deployment_note.md` steps 4–6.

---

## Steps 3–4 — nginx + HTTPS (needs your sudo password)

Docker needs no sudo, so `deploy.sh` covers steps 1–2 on its own. nginx and
certbot do, and the NextGen session removed passwordless sudo — so **you** run
these. The script is already on the server at `~/finish_fashion.sh`:

```bash
ssh -t panha 'bash ~/finish_fashion.sh'
```

The `-t` is required: without it ssh allocates no TTY and sudo fails with
`sudo: a terminal is required to read the password`. If you'd rather log in
first, `ssh panha` then `bash ~/finish_fashion.sh` is equivalent.

It installs the nginx site from `~/fashion-api/deploy/fashionapp.api.hpn.world.nginx`,
runs `nginx -t` before reloading, issues the cert with:

```bash
sudo certbot --nginx -d fashionapp.api.hpn.world \
  --non-interactive --agree-tos --email hournpanha168@gmail.com --redirect
```

then re-verifies. certbot rewrites the site file (adds `listen 443 ssl`, cert
paths, and an HTTP→HTTPS 301 block) — don't hand-edit those lines, they're
tagged `# managed by Certbot`.

<details>
<summary>Doing steps 3–4 by hand instead</summary>

```bash
scp ~/Desktop/pj/mobile_application2/fashion_app/backend/deploy/fashionapp.api.hpn.world.nginx panha:/tmp/
ssh panha
sudo cp /tmp/fashionapp.api.hpn.world.nginx /etc/nginx/sites-available/
sudo ln -s /etc/nginx/sites-available/fashionapp.api.hpn.world /etc/nginx/sites-enabled/
sudo nginx -t                        # MUST say "syntax is ok" before reload
sudo systemctl reload nginx
curl -I http://fashionapp.api.hpn.world/docs     # expect 200
sudo certbot --nginx -d fashionapp.api.hpn.world \
  --non-interactive --agree-tos \
  --email hournpanha168@gmail.com --redirect
```

> `proxy_pass` targets **8001**. Host port 8000 is the NextGen API — do not
> change it and do not "fix" the compose file to 8000.

</details>

---

## Step 5 — Verify

### 5a. Full API suite over public HTTPS (Mac)

```bash
python3 backend/deploy/verify_live.py
```

23 checks: reachability, product search/filter, register + duplicate + wrong
password, auth enforcement (401 without a token, 200 with one), and a
cart → update → order → cart-cleared round-trip. The order is placed as a
throwaway registered user so your demo account's history stays clean.

```
  23 passed, 0 failed
```

### 5b. Transport + exposure (Mac)

```bash
# HTTP bounces to HTTPS
curl -sSI http://fashionapp.api.hpn.world/api/products | grep -iE '^HTTP|^location'
#   HTTP/1.1 301 Moved Permanently
#   Location: https://fashionapp.api.hpn.world/api/products

# Direct port must be unreachable from the internet — this is what the
# 127.0.0.1 bind buys you, because Docker published ports bypass ufw
nc -z -G 6 -w 6 169.58.139.98 8001 && echo "OPEN — BAD" || echo "closed — good"

# Cert is real and covers the hostname
echo | openssl s_client -connect fashionapp.api.hpn.world:443 \
  -servername fashionapp.api.hpn.world 2>/dev/null \
  | openssl x509 -noout -subject -issuer -dates -ext subjectAltName
```

### 5c. Renewal (needs sudo)

```bash
ssh -t panha 'sudo certbot renew --dry-run'
```

All simulated renewals should succeed. Worth running once here rather than
discovering a broken renewal at the 30-day mark.

---

## Step 6 — Run the Flutter app (Mac)

`.env` is already set to `https://fashionapp.api.hpn.world/api`. HTTPS works on
the Android emulator, iOS simulator and real devices alike.

```bash
cd /Users/lyznhara/Desktop/pj/mobile_application2/fashion_app
flutter pub get
flutter run
```

Test: login → browse → product detail → cart → checkout → orders, plus a fresh
register.

---

## Day-to-day

| Change             | Command                           |
|--------------------|-----------------------------------|
| Python code        | `backend/deploy/deploy.sh`        |
| `deploy/.env` only | `backend/deploy/deploy.sh --env`  |
| Container logs     | `backend/deploy/deploy.sh --logs` |
| Re-verify after deploy | `python3 backend/deploy/verify_live.py` |
| DB backup → Mac    | `rsync -avz panha:~/fashion-api/deploy/data/fashion_store.db ./` |
| Fresh demo data    | `cd ~/fashion-api/deploy && docker compose down && rm -rf data && docker compose up -d --build` |
| Stop               | `cd ~/fashion-api/deploy && docker compose down` |

`--env` does **no** rsync and **no** `--build` — it only recreates the container
so it picks up the new environment. `--build` there wastes a rebuild; omitting
it after a code change silently keeps running the old code.

---

## Gotchas

1. **Port 8001 only.** 8000 is the NextGen API. Compose binds `127.0.0.1:8001:8000`.
2. **`name: fashion` in the compose file is load-bearing — never delete it.**
   Compose derives the project name from the directory, and this directory is
   called `deploy`, the same as `~/nextgen-api/deploy/`. Both stacks then share
   the project `deploy`, and `docker compose up` in either directory tears down
   the other project's containers. This actually happened on 2026-09-29:
   deploying fashion killed `nextgen-api`, and restoring NextGen killed
   `fashion-api`. Verify after any compose change:
   ```bash
   docker ps --format '{{.Names}}\t{{.Label "com.docker.compose.project"}}'
   # fashion-api -> fashion ; nextgen-api -> deploy
   ```
3. **Mount `data/`, never the `.db` file.** Docker turns a missing file mount into
   a *directory*, and SQLite then can't open the database.
4. **`--build` after every code sync.** Layer caching makes it fast; without it you
   redeploy the old code and think you deployed.
5. **Changing `SECRET_KEY` invalidates every JWT.** Users just log in again.
6. **Demo credentials are seeded in production** (`sokthyda@gmail.com` /
   `password123`). Fine for a portfolio demo — don't reuse this pattern anywhere
   real.
7. **No login rate limiting.** The fashion `auth.py` has no failed-login lockout,
   unlike NextGen's `login_lockout.py`. Acceptable for a demo; copy the NextGen
   pattern before this faces real users.
8. **`CORS_ORIGINS=*`** is fine while only mobile clients call the API. If you
   later serve Flutter web from this domain, set the explicit origin instead and
   run `./deploy.sh --env`.
9. **No admin panel exists.** This API is customer-facing only — no roles, no
   admin routes, no admin UI. Don't expect one to appear from this deploy.
10. **`fashionapp.api.hpn.world` is a 4-label hostname.** It resolves fine and
    certbot handles it, but it's easy to mistype. Nothing to fix unless you want
    the shorter `api.hpn.world` instead.
11. **`sudo` needs a password.** The temporary passwordless sudo from the NextGen
    session was removed, so `deploy.sh` can do everything Docker-related but the
    nginx/certbot steps must be run by you in an interactive shell.

---

## Where things live

| Thing              | Location                                                     |
|--------------------|--------------------------------------------------------------|
| Code on server     | `~/fashion-api/`                                              |
| Production secrets | `~/fashion-api/deploy/.env`                                   |
| SQLite DB          | `~/fashion-api/deploy/data/fashion_store.db`                 |
| nginx site         | `/etc/nginx/sites-available/fashionapp.api.hpn.world`         |
| Container          | `fashion-api` (`docker logs fashion-api`)                     |
| SSH alias          | `panha` (also `nextgen`) — `169.58.139.98:26078`             |

**Done when:** `curl -fsS https://fashionapp.api.hpn.world/api/products` returns
product JSON and the Flutter app loads products on the home screen over HTTPS.
