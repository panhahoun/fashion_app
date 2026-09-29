# Fashion App — Backend Deployment Note (VPS + Domain)

> **The domain is settled:** `<DOMAIN>` in this document = `hpn.world`, and the
> API host is **`fashionapp.api.hpn.world`**, so the app talks to
> **`https://fashionapp.api.hpn.world/api`**.
> SSH alias for the VPS is **`panha`** (same host as `nextgen`).
>
> This page is the general walkthrough. For the concrete, copy-paste version with
> today's values filled in, use **`backend/deploy/RUNBOOK.md`** + `deploy.sh`.

Step-by-step to put the fashion store API live on your Contabo VPS behind
HTTPS, exactly like the NextGen Scholars setup (`contabo_vps_lesson.md`).

> **Status: deployed 2026-09-29.** API live at
> `https://fashionapp.api.hpn.world`, verified 23/23. `ssh panha` for the VPS.
> `backend/deploy/RUNBOOK.md` is the current, copy-pasteable version; this
> document is the original walkthrough and still explains the reasoning.
> `lesson_learn.md` records what went wrong — most importantly the compose
> project-name collision that briefly took NextGen's API offline.
>
> **Read this first:** replace `<DOMAIN>` everywhere with the real domain you
> are using for this app. Two options:
>
> 1. **Own fashion domain** (e.g. you bought `fashionstore.shop`) → target URL
>    `api.fashionstore.shop`.
> 2. **Reuse nextgenscholars.click** → pick a fresh subdomain, e.g.
>    `shop.nextgenscholars.click` (you can't reuse `api.nextgenscholars.click`,
>    that belongs to NextGen). Everything below works the same.
>
> I can't know your domain, so the commands show `api.<DOMAIN>` — replace it.

**Marked `Mac` = run on your computer. `server` = run inside `ssh nextgen`.**

---

## 0. The plan (and the one big gotcha)

```
Flutter app ──HTTPS──> https://api.<DOMAIN>
                          │  nginx (443, certbot cert)
                          ▼
                   127.0.0.1:8001   ← fashion-api (Docker container)
                   127.0.0.1:8000   ← NextGen API (already there — DO NOT touch)
```

- Same server, same nginx+certbot, same Docker — same pattern you already know.
- **Port 8000 is taken** by the NextGen API container. The fashion API binds
  **8001** (`127.0.0.1:8001:8000` in compose). Do not "just change it to 8000".
- SQLite database is persisted in `~/fashion-api/deploy/data/` (a mounted
  folder, not the file — file mounts become directories in Docker).

---

## 1. Prereqs — verify everything is already there (Mac)

```bash
ssh nextgen                          # you can log in (key, port 26078)
ssh nextgen "docker --version"       # Docker installed
ssh nextgen "systemctl is-active nginx"   # should print: active
ssh nextgen "ss -tlnp | grep 8000"   # confirms NextGen API owns 8000 (expected)
ssh nextgen "sudo ufw status"        # should list 26078/tcp, 80/tcp, 443/tcp
```

All good → continue. (If `ufw status` says "inactive", stop and ask — the
firewall should already be set up from the NextGen lesson.)

---

## 2. DNS: point a subdomain at your server (Mac → Namecheap)

Already done once for `api.nextgenscholars.click` — repeat for the fashion
subdomain (in Namecheap → Domain List → your domain → **Advanced DNS** →
**Host Records** → **Add New Record**):

| Type | Host            | Value           |
|------|-----------------|-----------------|
| A    | `api` (or `@` if using a bare new domain) | `169.58.139.98` |

Wait a few minutes, then check from your Mac:

```bash
dig +short api.<DOMAIN>     # must print 169.58.139.98
```

If it prints that IP, DNS is live.

---

## 3. Deploy files (already prepared for you)

These are committed in the repo so you don't have to write anything tomorrow:

| File | What it does |
|---|---|
| `backend/Dockerfile` | `python:3.12-slim` + `requirements.txt` + `app/`, runs uvicorn on 8000 |
| `backend/.dockerignore` | keeps `.env`, `.venv`, dev db, tests out of the image |
| `backend/deploy/docker-compose.yml` | builds + runs the API, `127.0.0.1:8001:8000`, mounts `./data` for SQLite |
| `backend/deploy/.env.example` | template for the production `.env` (put on the server) |

---

## 4. Sync the backend to the server (Mac)

```bash
cd /Users/lyznhara/Desktop/pj/mobile_application2/fashion_app
rsync -avz \
  --exclude='.git' \
  --exclude='__pycache__' \
  --exclude='*.pyc' \
  --exclude='.venv' \
  --exclude='.env' \
  --exclude='fashion_store.db' \
  --exclude='deploy/.env' \
  --exclude='deploy/data/' \
  backend/ nextgen:~/fashion-api/
```

- `.env` and `fashion_store.db` are excluded on purpose — the dev db and local
  secrets must never go up.
- The `deploy/` folder **is** synced (minus its `.env` and `data/`), so the
  compose file + `.env.example` arrive with the code.

---

## 5. Write the production `.env` (server)

```bash
ssh nextgen
cd ~/fashion-api/deploy
cp .env.example .env
nano .env
```

Set at minimum:

```
DEBUG=false
CORS_ORIGINS=*
DATABASE_URL=sqlite:////app/data/fashion_store.db
SECRET_KEY=<run: openssl rand -hex 32>
TOKEN_EXPIRE_HOURS=24
```

`openssl rand -hex 32` (run on your Mac or the server) prints a long random
string — paste that whole value into `SECRET_KEY`. Never keep the default.

---

## 6. Build + start the API (server)

```bash
ssh nextgen
cd ~/fashion-api/deploy
docker compose up -d --build
```

Check it came up and seeded the demo data:

```bash
docker logs --tail 50 fashion-api
curl -s http://127.0.0.1:8001/api/products | head -c 300
```

Expect a JSON array starting `[{"id":1,"name_khmer":"អាវសូត្រ...` — seeding ran
(demo user `sokthyda@gmail.com` / `password123`, 5 categories, 7 products).
The DB file is now at `~/fashion-api/deploy/data/fashion_store.db`.

---

## 7. nginx: reverse proxy (server)

```bash
sudo nano /etc/nginx/sites-available/api.<DOMAIN>
```

Paste (note the port — 8001, not 8000):

```nginx
server {
    listen 80;
    server_name api.<DOMAIN>;

    location / {
        proxy_pass http://127.0.0.1:8001;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

```bash
sudo ln -s /etc/nginx/sites-available/api.<DOMAIN> /etc/nginx/sites-enabled/
sudo nginx -t                    # must say "syntax is ok" before reloading
sudo systemctl reload nginx
```

Check plain HTTP from your Mac:

```bash
curl -I http://api.<DOMAIN>/docs     # expect 200 (or 301 once HTTPS is added below)
```

---

## 8. HTTPS with certbot (server)

Same one-shot as NextGen:

```bash
sudo certbot --nginx -d api.<DOMAIN>
```

Answer: email (your existing one is fine), accept ToS, "share with EFF" → No,
and choose **2: Redirect** so HTTP bounces to HTTPS.

Verify from your Mac:

```bash
curl -I https://api.<DOMAIN>/docs
curl -s https://api.<DOMAIN>/api/products | head -c 300
```

Both should succeed.

Then, the exact **security checks you did after the NextGen nginx swap**:

```bash
# 1. Direct access must FAIL (proves the 127.0.0.1 bind actually protects it)
curl -m 5 http://169.58.139.98:8001/api/products      # -> timeout / connection refused

# 2. HTTP must bounce to HTTPS (certbot "Redirect" choice)
curl -I http://api.<DOMAIN>/api/products              # -> 301 -> https

# 3. Auto-renewal is real, not assumed (server)
ssh nextgen "sudo systemctl list-timers | grep certbot"   # daily timer exists
ssh nextgen "sudo certbot renew --dry-run"                 # simulated renewal OK
```

If you'd rather script certbot next time (to avoid the interview prompts):

```bash
sudo certbot --nginx -d api.<DOMAIN \
  --non-interactive --agree-tos --email you@example.com --redirect
```

---

## 9. Point the Flutter app at the live API (Mac)

Open the app's `.env`:

```bash
nano /Users/lyznhara/Desktop/pj/mobile_application2/fashion_app/.env
```

Replace the URL:

```
API_BASE_URL=https://api.<DOMAIN>/api
```

Then run the app (Android emulator / iOS / real device — `https` works on all;
you may need to run `flutter pub get` if you see dependency warnings):

```bash
flutter run
```

Test the flow: login `sokthyda@gmail.com` / `password123` → browse products →
detail → cart → checkout → orders. Also test register with a fresh account.

---

## 10. End-to-end API check (Mac, optional but convincing)

```bash
# login (get a token)
curl -s -X POST https://api.<DOMAIN>/api/auth/login \
  -H 'Content-Type: application/json' \
  -d '{"email":"sokthyda@gmail.com","password":"password123"}'

# authed cart/orders hit 401 without a token, 200 with one:
curl -s https://api.<DOMAIN>/api/cart -H "Authorization: Bearer <TOKEN>"
# -> {"detail":"Not authenticated"} if the token is missing/invalid
```

---

## 11. How to deploy updated backend code

**The one rule that decides everything:**

> **Code changed** (Python files) → rsync + `docker compose up -d --build` (adds `--build`).
> **Only `.env` changed** (secrets/config) → edit server `.env` + `docker compose up -d --force-recreate` (**no `--build`**, no rsync).

The `--build` flag is what makes Docker rebuild the image from the new source.
Forget it and the old code keeps running even though you uploaded new files.

### A. Code change, step by step

**1. Edit your code on the Mac** (`backend/app/...`). Optional: smoke-test locally
before pushing — run `cd backend && source .venv/bin/activate && python run.py`
and hit `http://localhost:8000/api/products`. If it works here it'll work there.

**2. rsync the backend to the server (Mac)** — same command as step 4:

```bash
cd /Users/lyznhara/Desktop/pj/mobile_application2/fashion_app
rsync -avz \
  --exclude='.git' \
  --exclude='__pycache__' \
  --exclude='*.pyc' \
  --exclude='.venv' \
  --exclude='.env' \
  --exclude='fashion_store.db' \
  --exclude='deploy/.env' \
  --exclude='deploy/data/' \
  backend/ nextgen:~/fashion-api/
```

`~` = your home folder. The excludes keep your dev DB and secrets off the
server; the server keeps its own `.env` and `data/`.

**3. Rebuild + restart the container (server):**

```bash
ssh nextgen
cd ~/fashion-api/deploy
docker compose up -d --build
```

**4. Verify (server or Mac):**

```bash
docker ps                                  # fashion-api Up, healthy
docker logs --tail 20 fashion-api          # no tracebacks at startup
curl -s https://api.<DOMAIN>/api/products | head -c 200
```

`--build` only re-runs the steps that changed (Docker layer cache), so this is
fast — usually a few seconds unless `requirements.txt` changed (that layer
reinstalls everything, ~30s).

**Worked example — "add a new endpoint":**

```python
# backend/app/routers/products.py — imagine you added:
@router.get("/featured")
def featured_products():
    ...
```

`rsync` (step 2) → `docker compose up -d --build` (step 3) → done. The endpoint
is live at `https://api.<DOMAIN>/api/products/featured` with no nginx or certbot
involvement (they just forward everything to the container).

### B. Env-only change (no code edited)

Example: rotate `SECRET_KEY`, change `CORS_ORIGINS`, or bump `TOKEN_EXPIRE_HOURS`.

**1. Edit the server's `.env`:** `nano ~/fashion-api/deploy/.env` (save: Ctrl+O, Enter, Ctrl+X).

**2. Recreate the container (no rsync, no `--build`):**

```bash
ssh nextgen
cd ~/fashion-api/deploy
docker compose up -d --force-recreate
```

**3. Confirm the new value is live:**

```bash
docker exec fashion-api printenv SECRET_KEY   # check the first letters
```

> `SECRET_KEY` changes invalidate all old login tokens — expected; users just
> log in again.

### C. Decision table

| What changed          | Run                                                                                   |
| --------------------- | ------------------------------------------------------------------------------------- |
| Python code           | rsync + `docker compose up -d --build`                                                |
| `.env` only           | `nano` server `.env` + `docker compose up -d --force-recreate` (no `--build`)         |
| requirements.txt      | rsync + `docker compose up -d --build` (deps reinstall — slower)                      |
| Dockerfile / compose  | rsync + `docker compose up -d --build`                                                |
| Nothing (just nerf-proof) | `docker compose up -d --force-recreate` (cheap, harmless)                          |

If a deploy breaks, `docker logs --tail 50 fashion-api` shows the Python
traceback/import error almost every time — paste it here and I'll guide you.

---

## 12. Backup / reset / rollback (server)

**Back up the database** (SQLite file → copy down to your Mac):

```bash
cd ~/fashion-api/deploy
cp data/fashion_store.db ~/fashion_store.backup-$(date +%F).db
# from the Mac:
rsync -avz nextgen:~/fashion-api/deploy/data/fashion_store.db \
  ~/Desktop/fashion_store.backup.db
```

**Reset to fresh demo data:**

```bash
cd ~/fashion-api/deploy && docker compose down && sudo rm -rf data \
  && docker compose up -d --build
```

(Deleting `data/` gives an empty DB; `create_tables()` reseeds it on startup.)

**Take it down completely:**

```bash
cd ~/fashion-api/deploy && docker compose down
```

Doesn't touch NextGen — different container, different port.

**Roll back the code to a known-good version** (same idea as the NextGen cheat
sheet: "redeploy the last known-good commit and rebuild"):

```bash
cd /Users/lyznhara/Desktop/pj/mobile_application2/fashion_app
git log --oneline backend/           # find the last commit that worked
git checkout <good-commit> -- backend # (or use git stash to drop a bad change)
```
then the normal rsync + `docker compose up -d --build` on the server.

Docker also keeps old images, so the previously-running code is always one step
away:

```bash
ssh nextgen
docker images fashion-api            # the last good image is still listed (or <none>)
# if needed: docker compose down && docker compose up -d   # reuses cached layers
```

For a demo project, the DB backup above + `git` is usually all the rollback you
ever need.

---

## 13. Gotchas (read before you start, or when it breaks)

1. **`127.0.0.1:8001:8000`, never `8000:8000`** — NextGen owns host 8000, and a
   `0.0.0.0`/public binding would bypass ufw and expose the API directly.
2. **Mount the `data/` folder, not the `.db` file** — Docker turns a missing
   file mount into a directory, and the API would then fail to open it.
3. **`.env` never gets committed or rsynced** — the server's
   `~/fashion-api/deploy/.env` is the single source of truth for secrets.
4. **`SECRET_KEY` must be unique + long** (`openssl rand -hex 32`). If you
   later change it, all existing JWTs invalidate (users just log in again).
5. **Demo credentials ship with the app** — `sokthyda@gmail.com` /
   `password123` is seeded on the server too. Fine for a portfolio demo.
6. **`DEBUG=false`** on the server. Leaving it true keeps uvicorn reload (slow)
   and turns CORS into a footgun for nothing.
7. If `docker compose up` fails, almost always seeable in
   `docker logs fashion-api` (import error, env typo). Paste it back here and
   I'll guide you.
8. If you ever host **Flutter web** for this app, add its origin to `CORS_ORIGINS`
   (e.g. `https://shop.<DOMAIN>`) and `docker compose up -d --force-recreate`.
9. **No login rate limit** — unlike NextGen (`login_lockout.py`), the fashion
   `auth.py` has no failed-login lockout. Fine for a demo; if this ever goes
   public-facing, add one (the NextGen lesson is the template).

---

## 14. Where everything lives

| Thing                     | Location                                                            |
| ------------------------- | ------------------------------------------------------------------- |
| Repo deploy files         | `backend/Dockerfile`, `backend/.dockerignore`, `backend/deploy/`    |
| Code on server            | `~/fashion-api/` (synced via rsync)                                  |
| Production secrets        | `~/fashion-api/deploy/.env`                                          |
| SQLite database           | `~/fashion-api/deploy/data/fashion_store.db` (auto-seeded)           |
| nginx site                | `/etc/nginx/sites-available/api.<DOMAIN>` (+ symlink in `sites-enabled`) |
| Container                 | `fashion-api` (logs: `docker logs fashion-api`)                      |

**Done when:** `curl -s https://api.<DOMAIN>/api/products` returns product JSON
and the Flutter app loads products on the home screen over HTTPS.

---

## 15. How to change the domain later (when you buy the fashion domain)

Reusing `nextgenscholars.click` now is cheap to undo. Switching to a new domain
later is a **~10-minute, server-side-only job** — the API container, port
(`8001`) and SQLite data are untouched because they don't care what hostname
fronts them. Only 4 places change:

**1. DNS (Mac → Namecheap)** — add an A record for the new subdomain:

| Type | Host | Value |
|---|---|---|
| A | `api` (or `@` on the new domain) | `169.58.139.98` |

Wait a few minutes, then `dig +short api.<NEW_DOMAIN>` must print `169.58.139.98`.

**2. nginx (server)** — new site block (copy the one from step 7, same content,
just the new `server_name`):

```bash
sudo nano /etc/nginx/sites-available/api.<NEW_DOMAIN>
# same as step 7, proxy_pass stays http://127.0.0.1:8001
sudo ln -s /etc/nginx/sites-available/api.<NEW_DOMAIN> /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx
```

**3. HTTPS (server)** — get a cert for the new hostname:

```bash
sudo certbot --nginx -d api.<NEW_DOMAIN>
```

Old cert and site block are harmless to leave — certbot auto-renews them. When
you're happy, remove the old one any time:

```bash
sudo rm /etc/nginx/sites-enabled/api.<OLD_DOMAIN> \
      /etc/nginx/sites-available/api.<OLD_DOMAIN>
sudo systemctl reload nginx
sudo certbot delete --cert-name api.<OLD_DOMAIN>
```

**4. Flutter app (Mac — the only step that "costs")**: the URL is compiled into
the app, so changing it means a rebuild + reinstall on your device/emulator:

```bash
nano /Users/lyznhara/Desktop/pj/mobile_application2/fashion_app/.env
# API_BASE_URL=https://api.<NEW_DOMAIN>/api
flutter run          # or flutter build apk --debug for a fresh install
```

**Optional — CORS:** only if you also host Flutter web later; add the web origin
to `CORS_ORIGINS` and `docker compose up -d --force-recreate`.

**What does NOT change:** Docker port, compose file, `.env`, SQLite data,
database contents — none of it. The container keeps serving on
`127.0.0.1:8001`; nginx just points a different hostname at it.

> **Golden tip:** pick the subdomain name as if it's permanent (e.g.
> `fashion.nextgenscholars.click` is a fine long-term choice). Every switch is
> cheap, but each one burns a few minutes + a client rebuild.