# fashion_app — Lesson Notes

Project: `mobile_application2/fashion_app`
Status: reviewed + fixed (0 analyze issues, widget test passing, debug APK builds)

> A bilingual (English/Khmer) fashion **e-commerce mobile app** in Flutter — now on the **GetX architecture (MVVM-style features)** — talking to a FastAPI REST backend (`backend/` over **Dio** HTTP).

---

## 1. What is this project created for?

A real online-shopping app for Cambodia — "ហាងម៉ូត" ("Fashion Store") — built to demonstrate a complete shopping flow in Flutter:

- Browse catalog: product grid, images, ratings, stock badges, low-stock "នៅសល់ X" tag
- Search with debounce, category filter chips, sort sheet (popular / newest / price low→high / high→low / name)
- Product detail with **size + color** selection
- Cart: add / change quantity / remove — persisted per user on the server
- Checkout: name / phone / address + payment method (cash សាច់ប្រាក់ or bank ធនាគារ) → creates an order server-side
- Order history with expandable detail sheet and status badges (pending/processing/completed/cancelled)
- Favorites persisted locally and shown on cards; login / register / profile / confirm-logout

**Lesson:** it's a client–server teaching project. The UI alone is dead weight — the whole point is the clean separation between UI, controllers, models, services, and config that lets the app talk to a backend (and the state-management layering on top).

## 2. Folder & file map

### Platform scaffolding (generated — don't edit logic here)
`android/` `ios/` `web/` `linux/` `macos/` `windows/` — compile the same Dart to each platform.
Hold native config (AndroidManifest.xml, Info.plist, gradle, icons).

### `lib/` — the actual app

| Path | Purpose |
|---|---|
| `main.dart` | Entry point: loads `.env`, locks portrait, sets theme & routes → starts at `SplashView` |
| `core/api_config.dart` | `ApiConfig` — builds `baseUrl` from `.env` (`API_BASE_URL`) / platform fallback; endpoint prefixes (`auth`, `products`, `cart`, `orders`, `categories`) + timeouts |
| `core/network/dio_client.dart` | Singleton `DioClient` (Dio): base URL, timeouts, `AuthTokenHolder` (in-memory token) + an interceptor that attaches `Authorization: Bearer <token>` on every request |
| `core/app_theme.dart` | Design system: full palette constants (see §4), Material 3 theme, AppBar/Card/Input/Elevated·Outlined button themes, `fontFamily: 'Khmer OS'` |
| `core/stores/session_controller.dart` | Reactive `SessionController` (GetX) — current user (id, name, email, phone, token) persisted with `SharedPreferences`; feeds token into `AuthTokenHolder` |
| `core/stores/favorites_store_controller.dart` | Reactive `FavoritesStoreController` (GetX, `RxSet<int>`) persisting favorite product ids to `SharedPreferences` |
| `core/bindings/app_binding.dart` | `AppBinding` — injects the permanent global controllers before the first route renders |
| `core/routes/app_routes.dart` | Route name constants (`/splash`, `/login`, `/register`, `/main`, `/product-detail`, `/category-products`, `/checkout`, `/favorites`) |
| `core/routes/app_pages.dart` | `AppPages.pages` — `GetPage` route table wiring each route to its View + Binding |
| `features/<name>/` | One folder per screen, split into `<x>_view.dart` (UI), `<x>_controller.dart` (logic/state), `<x>_binding.dart` (DI). Features: splash, login, register, main_navigation, home, product_detail, categories, category_products, cart, checkout, orders, favorites, profile |
| `models/*` | Data classes mirroring backend JSON with `fromJson` + crash-safe parsing helpers: `product.dart` (+`ProductColor`), `category.dart`, `cart_item.dart`, `order.dart` (+status colors), `order_item.dart` |
| `services/api/api_service.dart` | `ApiService.handleRequest` — one Dio wrapper: timeout, typed `ApiException`, maps `DioException` + FastAPI `{detail: …}` errors |
| `services/api/*_service.dart` | HTTP-only API calls: auth, product, cart, order, category (no UI, no state) |
| `widgets/product_card.dart` | Reusable card: image, rating badge, favorite heart, low-stock tag, price, add-to-cart — reused in grids |

### Supporting files
- `pubspec.yaml` — deps (`dio`, `get`, `flutter_dotenv`, `shared_preferences`, `cached_network_image`, `intl`, `pdf`/`printing`, `flutter_lints`) + declares `.env` as asset
- `.env` / `.env.example` — local API config; only `.env.example` committed, real `.env` gitignored (secret-safe)
- `analysis_options.yaml` — flutter_lints rules
- `test/widget_test.dart` — boot test: splash branding → routes to login (uses `SharedPreferences.setMockInitialValues`)

### Why split this way?
Clear separation of concerns — now in **three layers**:

- **View** (features/`*_view.dart`) — pure UI, reads controller state via `Obx`
- **Controller + Binding** — GetX state, business flow, calls services (no HTTP, no SQL)
- **Services** — only HTTP conversations (no UI)
- **Models** — JSON → typed objects
- **Core** — config, HTTP client, global stores, routes, theme

Compare with single-file apps (3000-line `main.dart`) or even the earlier flat `screens/` layout: the feature-per-folder + named-route structure is why it's portfolio-strength.

## 3. What is the backend?

A **FastAPI + SQLAlchemy + SQLite** REST API in this repo (`backend/`). The app only knows its address (`API_BASE_URL`).

```
http://localhost:8000/api
├── auth       POST /register · POST /login · GET /me          → {access_token, user}
├── products   GET  (all | /{id} | ?search= | ?category=)
├── categories GET
├── cart       GET · POST · PUT /{cart_id} · DELETE /{cart_id}  (JWT)
└── orders     GET · POST                                       (JWT)
```

Responses are raw JSON (FastAPI auto-docs at `/docs`). JWT auth via
`Authorization: Bearer <token>`; bcrypt password hashing. `.env` configures
DB URL, secret key, CORS, token lifetime (`backend/.env.example`).

The Dio interceptor (`dio_client.dart`) attaches the token automatically from
`AuthTokenHolder`, which `SessionController` updates after login/register.

**Lesson:** the app is the *client*. It never stores products/orders itself; it renders what the API returns and posts actions back. The backend is a separate FastAPI project – and `ApiConfig` centralizes its URL so you can switch dev ∕ test ∕ prod without touching the UI.

## 4. Design system (palette)

All colors live as constants in `core/app_theme.dart` and are referenced everywhere in the UI:

| Purpose | Color | Hex |
|---|---|---|
| Primary | Deep Black | `#111111` |
| Background | Off White | `#F8F8F8` |
| Surface / Card | White | `#FFFFFF` |
| Text | Dark Gray | `#222222` |
| Secondary Text | Gray | `#777777` |
| Accent | Warm Beige | `#C8A27A` |
| Border | Light Gray | `#E5E5E5` |
| Success | Green | `#2E7D32` |
| Error | Red | `#D32F2F` |
| Bottom-nav idle | Gray | `#999999` |

Applied per spec across the UI: header/cards `#FFFFFF`, page bg `#F8F8F8`, prices/primary buttons `#111111` with white text, outlined buttons `#FFFFFF` + `#111111` border, bottom nav selected `#111111` / unselected `#999999`, discounts & low-stock `#D32F2F`.

## Notes from the fix / migration passes

**Rewrite → GetX (feature architecture)**
- Replaced flat `screens/` + `http` with `features/<name>/{view,controller,binding}` and Dio (`dio_client.dart` + JWT interceptor); routes centralized in `core/routes/`.
- Replaced static `UserSession` / `FavoritesStore` with reactive `SessionController` / `FavoritesStoreController` (`GetxController` + `Rx` types), DI'd globally in `AppBinding`.
- Auth endpoints updated to `/auth/login` · `/auth/register` (JWT-based) instead of `{action: …}`; cart/orders switched from `?user_id=` query to bearer-token auth.

**Palette pass**
- Added `outlinedButtonTheme` (white fill, `#111111` border/text) to match the spec's secondary button.
- Bottom nav unselected → `#999999` (`AppTheme.navUnselected`).
- Home header icons pinned to `#111111`; header gradient/sort chip borders and bottom-sheet handle now use palette tokens (`AppTheme.border`, `AppTheme.accent`).
- Order status colors mapped onto the palette (removed off-palette `Colors.blue`/`Colors.grey`).
- Fixed pre-existing compile errors: splash + profile headers referenced a removed `AppTheme.darkOrange` → now `primary → accent` gradient.

**Quality**
- 0 `flutter analyze` issues; `test/widget_test.dart` passes; `flutter build apk --debug` succeeds.
- App requires the backend running to show live data; error + retry UI handles offline gracefully.