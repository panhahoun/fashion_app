"""End-to-end smoke test for the Fashion Store API using FastAPI TestClient.

Run:  python test_api.py
"""

import os

os.environ["DATABASE_URL"] = "sqlite:///./test_fashion_store.db"

from fastapi.testclient import TestClient
from app.main import app
from app.core.database import Base, engine


def check(cond, msg):
    assert cond, f"FAIL: {msg}"
    print(f"  ok - {msg}")


def main():
    Base.metadata.drop_all(bind=engine)

    # Entering the context manager runs the FastAPI lifespan, which creates
    # and seeds the tables.
    with TestClient(app) as client:
        print("== Products ==")
        r = client.get("/api/products")
        check(r.status_code == 200, "GET /api/products -> 200")
        products = r.json()
        check(len(products) > 0, f"products seeded ({len(products)})")
        p0 = products[0]
        for key in ["id", "nameKhmer", "nameEnglish", "price", "stock", "images", "sizes", "colors"]:
            check(key in p0, f"product has '{key}'")

        print("== Categories ==")
        r = client.get("/api/categories")
        check(r.status_code == 200 and len(r.json()) > 0, "GET /api/categories seeded")

        print("== Auth: register + login ==")
        r = client.post("/api/auth/register", json={
            "name": "Test User", "email": "test@fashion.com",
            "phone": "099999999", "password": "secret123"})
        check(r.status_code == 200, "register -> 200")
        body = r.json()
        check("access_token" in body and body["user"]["email"] == "test@fashion.com",
              "register returns access_token + user")
        token = body["access_token"]

        r = client.post("/api/auth/register", json={
            "name": "Dup", "email": "test@fashion.com", "password": "secret123"})
        check(r.status_code == 400, "duplicate email -> 400")

        r = client.post("/api/auth/login", json={
            "email": "test@fashion.com", "password": "wrong"})
        check(r.status_code == 401, "wrong password -> 401")

        headers = {"Authorization": f"Bearer {token}"}

        r = client.get("/api/auth/me", headers=headers)
        check(r.status_code == 200 and r.json()["name"] == "Test User", "GET /auth/me")

        print("== Cart ==")
        r = client.get("/api/cart", headers=headers)
        check(r.status_code == 200 and r.json() == [], "cart empty initially")

        r = client.post("/api/cart", headers=headers, json={
            "product_id": p0["id"], "quantity": 2,
            "selected_size": p0["sizes"][0] if p0["sizes"] else "One Size",
            "selected_color_name": p0["colors"][0]["name"] if p0["colors"] else "Default"})
        check(r.status_code == 200, "add to cart")
        cart_item = r.json()
        check(cart_item["quantity"] == 2 and cart_item["productId"] == p0["id"],
              "cart item fields match")

        r = client.post("/api/cart", headers=headers, json={
            "product_id": p0["id"], "quantity": 1,
            "selected_size": cart_item["selectedSize"],
            "selected_color_name": cart_item["selectedColorName"]})
        check(r.status_code == 200 and r.json()["quantity"] == 3,
              "re-adding same variant merges quantity")

        r = client.put(f"/api/cart/{cart_item['id']}", headers=headers, json={"quantity": 5})
        check(r.status_code == 200 and r.json()["quantity"] == 5, "update cart quantity")

        print("== Orders ==")
        r = client.post("/api/orders", headers=headers, json={
            "customer_name": "Test User", "phone": "099999999",
            "address": "Phnom Penh", "payment_method": "សាច់ប្រាក់",
            "items": [{"product_id": p0["id"], "quantity": 2}]})
        check(r.status_code == 200, "create order -> 200")
        order = r.json()
        check(order["totalAmount"] == round(p0["price"] * 2, 2), "order total computed server-side")
        check(len(order["items"]) == 1, "order items present")

        r = client.get("/api/orders", headers=headers)
        check(len(r.json()) == 1, "GET /orders for user")

        r = client.get("/api/cart", headers=headers)
        check(r.json() == [], "cart cleared after order")

        r = client.get("/api/cart", headers={"Authorization": "Bearer bad.token"})
        check(r.status_code == 401, "bad token -> 401")

        r = client.get("/api/products", params={"search": "blouse"})
        check(r.status_code == 200, "search products")

        print("== Profile ==")
        r = client.put("/api/auth/me", headers=headers, json={"name": "New Name", "phone": "011223344"})
        check(r.status_code == 200, "update profile -> 200")
        check(r.json()["name"] == "New Name" and r.json()["phone"] == "011223344", "profile fields persisted")

        r = client.put("/api/auth/me", headers=headers, json={"name": "   "})
        check(r.status_code == 400, "empty profile name -> 400")

        r = client.post("/api/auth/change-password", headers=headers,
                        json={"current_password": "wrong", "new_password": "newpass123"})
        check(r.status_code == 400, "wrong current password -> 400")

        r = client.post("/api/auth/change-password", headers=headers,
                        json={"current_password": "secret123", "new_password": "short"})
        check(r.status_code == 400, "too-short new password -> 400")

        r = client.post("/api/auth/change-password", headers=headers,
                        json={"current_password": "secret123", "new_password": "newpass123"})
        check(r.status_code == 200, "change password -> 200")

        r = client.post("/api/auth/login", json={"email": "test@fashion.com", "password": "newpass123"})
        check(r.status_code == 200, "login with the new password -> 200")

        r = client.get("/api/auth/me", headers={"Authorization": "Bearer bad.token"})
        check(r.status_code == 401, "GET /auth/me bad token -> 401")

        print("== Addresses ==")
        r = client.get("/api/addresses", headers=headers)
        check(r.status_code == 200 and r.json() == [], "addresses empty initially")

        r = client.post("/api/addresses", headers=headers, json={"detail": "  "})
        check(r.status_code == 400, "empty address detail -> 400")

        r = client.post("/api/addresses", headers=headers, json={
            "label": "Home", "recipient_name": "Test User", "phone": "011223344",
            "detail": "St 5, Sangkat 3"})
        check(r.status_code == 200, "create first address -> 200")
        check(r.json()["isDefault"] is True, "first address becomes default")
        home_id = r.json()["id"]

        r = client.post("/api/addresses", headers=headers, json={
            "label": "Work", "recipient_name": "Test User", "phone": "011223344",
            "detail": "St 9, Khan 1"})
        check(r.status_code == 200 and r.json()["isDefault"] is False, "second address is not default")
        work_id = r.json()["id"]

        r = client.get("/api/addresses", headers=headers)
        check(len(r.json()) == 2, "GET /addresses lists both")

        r = client.put(f"/api/addresses/{work_id}", headers=headers, json={
            "label": "Work", "detail": "St 9, Khan 1", "is_default": True})
        check(r.json()["isDefault"] is True, "set work address as default")

        r = client.get("/api/addresses", headers=headers)
        flags = {a["id"]: a["isDefault"] for a in r.json()}
        check(flags[work_id] is True and flags[home_id] is False, "only one address stays default")

        r = client.delete(f"/api/addresses/{home_id}", headers=headers)
        check(r.status_code == 200, "delete address -> 200")

        r = client.get("/api/addresses", headers=headers)
        check(len(r.json()) == 1, "deleted address removed")
        check(r.json()[0]["isDefault"] is True, "remaining address keeps default")

        r = client.delete(f"/api/addresses/{home_id}", headers=headers)
        check(r.status_code == 404, "delete unknown address -> 404")

        r = client.get("/api/addresses")
        check(r.status_code == 401, "addresses require auth")

    print("\nALL SMOKE TESTS PASSED")


if __name__ == "__main__":
    main()