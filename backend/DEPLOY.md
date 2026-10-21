# Deploying the Fashion Store API

The API runs on Render's free tier with a managed PostgreSQL database (Neon).

## 1. Database

Create a free Neon project and copy its connection string. It looks like:

```
postgresql://<user>:<password>@<host>/<db>?sslmode=require
```

## 2. Render web service

- **Runtime:** Docker (uses `backend/Dockerfile`), or Python 3 with
  `pip install -r backend/requirements.txt` and
  `uvicorn app.main:app --host 0.0.0.0 --port $PORT` from `backend/`.
- **Health check:** `/`

Environment variables:

| Key | Value |
|---|---|
| `DATABASE_URL` | the Neon connection string |
| `SECRET_KEY` | a long random string (`openssl rand -hex 32`) |
| `CORS_ORIGINS` | your app origins, comma-separated (no `*`) |

Migrations run on start-up. The free filesystem is ephemeral, so **do not** use
SQLite here — without `DATABASE_URL` every redeploy wipes the database.

## 3. Point the app at it

Set `API_BASE_URL` in the Flutter `.env`:

```
API_BASE_URL=https://<your-service>.onrender.com/api
```

The first request after the service has been idle can take ~30 seconds.

## 4. Smoke test

```bash
curl https://<your-service>.onrender.com/
curl https://<your-service>.onrender.com/api/products
```

Interactive API docs: `https://<your-service>.onrender.com/docs`.
