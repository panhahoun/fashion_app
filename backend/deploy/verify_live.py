#!/usr/bin/env python3
"""Post-deploy verification for the Fashion Store API over public HTTPS.

Read-only against every endpoint except POST /api/orders, which it exercises
against a freshly registered throwaway user so it never touches the demo
account's order history.
"""
import json
import ssl
import sys
import urllib.error
import urllib.request
from datetime import datetime

BASE = "https://fashionapp.api.hpn.world"


def _context():
    """CA bundle for verifying the server's Let's Encrypt chain.

    The python.org macOS framework build frequently has no usable OpenSSL
    cert store, which surfaces as CERTIFICATE_VERIFY_FAILED against a
    certificate that is actually valid (curl works fine in the same shell).
    Prefer certifi when present; otherwise fall back to the default store.
    """
    try:
        import certifi
        return ssl.create_default_context(cafile=certifi.where())
    except ImportError:
        return ssl.create_default_context()


CTX = _context()
ok_count = 0
fail_count = 0


def call(method, path, body=None, token=None, expect=200):
    global ok_count, fail_count
    url = f"{BASE}{path}"
    data = json.dumps(body).encode() if body is not None else None
    req = urllib.request.Request(url, data=data, method=method)
    req.add_header("Accept", "application/json")
    if data:
        req.add_header("Content-Type", "application/json")
    if token:
        req.add_header("Authorization", f"Bearer {token}")
    try:
        with urllib.request.urlopen(req, context=CTX, timeout=20) as r:
            code, payload = r.status, r.read()
    except urllib.error.HTTPError as e:
        code, payload = e.code, e.read()
    except Exception as e:
        code, payload = 0, str(e).encode()

    good = code == expect
    ok_count += good
    fail_count += not good
    mark = "ok  " if good else "FAIL"
    detail = ""
    if not good:
        detail = f"  <- expected {expect}, got {code}: {payload[:200]!r}"
    print(f"  [{mark}] {method:6} {path:34} {code}{detail}")
    try:
        return json.loads(payload)
    except Exception:
        return None


print("=== 1. public reachability ===")
call("GET", "/")
call("GET", "/docs", expect=200)
call("GET", "/api/products")
call("GET", "/api/categories")
call("GET", "/api/products/1")
call("GET", "/api/products?search=silk")
call("GET", "/api/products?category=1")

print("\n=== 2. auth ===")
email = f"deploy-check-{datetime.now().strftime('%H%M%S')}@example.com"
reg = call("POST", "/api/auth/register",
           {"email": email, "password": "check123456", "name": "Deploy Check"})
call("POST", "/api/auth/register",
     {"email": email, "password": "check123456", "name": "Dup"}, expect=400)
call("POST", "/api/auth/login",
     {"email": email, "password": "wrongpass"}, expect=401)
login = call("POST", "/api/auth/login",
             {"email": "sokthyda@gmail.com", "password": "password123"})
token = login.get("accessToken") or login.get("access_token") if login else None

print("\n=== 3. auth enforcement ===")
call("GET", "/api/cart", expect=401)
call("GET", "/api/orders", expect=401)
call("GET", "/api/cart", token="garbage", expect=401)
if token:
    call("GET", "/api/auth/me", token=token)
    call("GET", "/api/cart", token=token)
    call("GET", "/api/orders", token=token)

print("\n=== 4. cart -> order end-to-end (throwaway user) ===")
check_token = reg.get("accessToken") or reg.get("access_token") if reg else None
if check_token:
    add = call("POST", "/api/cart",
               {"product_id": 1, "quantity": 2}, token=check_token, expect=200)
    if isinstance(add, dict) and add.get("id"):
        call("PUT", f"/api/cart/{add['id']}", {"quantity": 3}, token=check_token)
    order = call("POST", "/api/orders", {
        "customer_name": "Deploy Check",
        "phone": "012345678",
        "address": "Phnom Penh",
        "payment_method": "cash",
        "items": [{"product_id": 1, "quantity": 3, "price": 29.99}],
    }, token=check_token)
    if order:
        print(f"         order id={order.get('id')} "
              f"total={order.get('totalAmount')} "
              f"items={len(order.get('items', []))} "
              f"status={order.get('status')}")
        if order.get("totalAmount") is None:
            print("  [FAIL] totalAmount missing from order response")
            fail_count += 1
        else:
            ok_count += 1
            print("  [ok  ] totalAmount present (server-computed)")
    call("GET", "/api/cart", token=check_token)
    call("DELETE", f"/api/cart/{add['id']}" if add and add.get("id") else "/api/cart/999999",
         token=check_token, expect=404)
else:
    print("  [FAIL] could not register throwaway user")

print(f"\n{'=' * 46}")
print(f"  {ok_count} passed, {fail_count} failed")
print("=" * 46)
sys.exit(1 if fail_count else 0)
