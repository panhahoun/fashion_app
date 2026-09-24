# ហាងម៉ូត — Fashion Store (Flutter)

A bilingual (English/Khmer) fashion e-commerce mobile app built with **Flutter**.

## Features

- **Auth** — splash, login, register, persistent session (SharedPreferences)
- **Home** — hero header, live search with debounce, category filter chips, sort sheet (popular / newest / price / name), product grid (responsive 2–4 columns)
- **Products** — detail screen with size & colour selection
- **Cart** — add/update/remove items, saved against the backend per user
- **Checkout** — customer info form + payment method (cash / bank), order summary
- **Orders** — list orders, expandable detail bottom sheet (items, totals, status)
- **Favorites** — persisted locally and synced to product cards
- **Profile** — account info, menu, confirm-logout dialog
- Everything localised in Khmer (ខ្មែរ) with English product data

## Architecture

```
lib/
├── core/        → api_config, app_theme, favorites_store, user_session
├── models/      → product, category, cart_item, order, order_item
├── screens/     → splash, login, register, main_navigation, home, products…, cart, checkout, orders, profile
├── services/api → api_service (shared request/error handling), auth, product, cart, order, category
└── widgets/     → product_card
```

- State: lightweight — `setState` + static stores (`UserSession`, `FavoritesStore`)
- API: REST over `http`, unified `handleRequest` with timeout + typed errors
- Images: `cached_network_image`

## Backend

A FastAPI + SQLAlchemy + SQLite REST service lives in `backend/` (see
`backend/README.md` for setup). JWT auth; interactive docs at `/docs`.

```
http://localhost:8000/api
├── auth        POST /register · POST /login · GET /me
├── products    GET (all | ?id= | ?search= | ?category=)
├── categories  GET
├── cart        GET · POST · PUT /{id} · DELETE /{id}   (auth)
└── orders      GET · POST                              (auth)
```

### Run the backend

```bash
cd backend
python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env
python run.py            # http://localhost:8000 (docs at /docs)
```

Smoke test: `python test_api.py` (uses a separate test DB).

### Configure the API URL

Create `.env` (see `.env.example`):

```env
API_BASE_URL=http://localhost:8000/api
```

| Platform | Default |
|---|---|
| Android emulator | `http://10.0.2.2:8000/api` |
| iOS simulator / web | `http://localhost:8000/api` |
| Real device | `http://<your-local-IP>:8000/api` |

## Run

```bash
flutter pub get
flutter run            # pick a device
flutter test           # widget test: splash → routing → login
```

## Tech stack

Flutter · Dart · `http` · `flutter_dotenv` · `shared_preferences` · `cached_network_image` · `intl` · `pdf`/`printing` · `flutter_lints`

Backend: Python · FastAPI · SQLAlchemy · SQLite · Pydantic-settings · python-jose (JWT) · passlib/bcrypt