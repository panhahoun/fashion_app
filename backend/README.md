# Fashion Store API (FastAPI)

REST backend for the Flutter fashion app. Replaces the old PHP/MySQL API with
a Python **FastAPI + SQLAlchemy + SQLite** service (JWT auth, Pydantic models,
auto-documented at `/docs`).

## Setup

```bash
cd backend
python3 -m venv .venv
source .venv/bin/activate          # Windows: .venv\Scripts\activate
pip install -r requirements.txt
cp .env.example .env               # adjust secrets / DB URL
```

## Run

```bash
python run.py                       # -> http://localhost:8000
```

Interactive docs: http://localhost:8000/docs

The database (`fashion_store.db`) is created and seeded automatically on first
start (demo user `sokthyda@gmail.com` / `password123`, 5 categories, 7 products).

### Resetting / reseeding demo data

```bash
rm fashion_store.db                 # tables + seed regenerate on next start
```

## Configuration (`.env`)

| Variable           | Default                          | Purpose                         |
|--------------------|----------------------------------|---------------------------------|
| `DEBUG`            | `false`                          | uvicorn auto-reload on/off      |
| `CORS_ORIGINS`     | `*`                              | Comma-separated allowed origins |
| `DATABASE_URL`     | `sqlite:///./fashion_store.db`   | SQLAlchemy DB URL               |
| `SECRET_KEY`       | `fashion-store-secret-2026-...`  | JWT signing secret              |
| `TOKEN_EXPIRE_HOURS` | `24`                           | JWT lifetime in hours           |

### Production persistence (important)

Render's free web services use an **ephemeral filesystem**: the SQLite file is
deleted every time the service restarts, spins down, or redeploys, so any
registered account disappears. For a durable deployment, set `DATABASE_URL` to a
managed Postgres (a free Neon/Supabase project works) instead of a SQLite file:

```bash
DATABASE_URL=postgresql://user:pass@host/db?sslmode=require
```

`psycopg[binary]` ships in `requirements.txt`, and `postgres://` URLs from the
provider are normalized to `postgresql://` automatically.

## Tests

```bash
python test_api.py                  # end-to-end smoke test (separate test DB)
```

## API surface

All JSON. Auth-protected routes need `Authorization: Bearer <token>`.

| Method | Path                 | Auth | Description                          |
|--------|----------------------|------|--------------------------------------|
| GET    | `/`                  | –    | Service info                         |
| POST   | `/api/auth/register` | –    | Create account → `access_token`      |
| POST   | `/api/auth/login`    | –    | Login → `access_token`               |
| GET    | `/api/auth/me`       | ✓    | Current user                         |
| GET    | `/api/products`      | –    | List (`?search=` / `?category=`)     |
| GET    | `/api/products/{id}` | –    | Single product                       |
| GET    | `/api/categories`    | –    | List categories                      |
| GET    | `/api/cart`          | ✓    | User's cart                          |
| POST   | `/api/cart`          | ✓    | Add/merge cart item                  |
| PUT    | `/api/cart/{id}`     | ✓    | Update quantity                      |
| DELETE | `/api/cart/{id}`     | ✓    | Remove item                          |
| GET    | `/api/orders`        | ✓    | User's orders                        |
| POST   | `/api/orders`        | ✓    | Create order (from cart, clears it)  |

## Layout

```
backend/
├── app/
│   ├── main.py            # app + CORS + router registration
│   ├── serializers.py     # ORM models -> JSON shapes the Flutter app expects
│   ├── core/
│   │   ├── config.py      # pydantic-settings (.env)
│   │   ├── database.py    # SQLAlchemy models, engine, seeding
│   │   └── security.py    # bcrypt hashing + JWT helpers
│   └── routers/           # auth, products, categories, cart, orders
├── requirements.txt
├── run.py
└── test_api.py
```