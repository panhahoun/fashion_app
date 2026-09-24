"""Serialize ORM models into the exact JSON shape the Flutter app expects."""

from app.core.database import Product, Category, CartItem, Order, OrderItem


def product_to_dict(p: Product) -> dict:
    return {
        "id": p.id,
        "nameKhmer": p.name_khmer,
        "nameEnglish": p.name_english,
        "descriptionKhmer": p.description_khmer or "",
        "descriptionEnglish": p.description_english or "",
        "price": p.price,
        "stock": p.stock,
        "rating": p.rating,
        "reviews": p.reviews,
        "imageUrl": p.image_url or "",
        "category": p.category or "",
        "images": p.images or [],
        "sizes": p.sizes or [],
        "colors": p.colors or [],
        "isFavorite": False,
    }


def category_to_dict(c: Category) -> dict:
    return {
        "id": c.id,
        "nameKhmer": c.name_khmer,
        "nameEnglish": c.name_english,
        "icon": c.icon or "category",
        "color": c.color or "#FF8C42",
    }


def cart_item_to_dict(ci: CartItem, p: Product) -> dict:
    return {
        "id": ci.id,
        "productId": p.id,
        "nameKhmer": p.name_khmer,
        "nameEnglish": p.name_english,
        "price": p.price,
        "imageUrl": p.image_url or "",
        "quantity": ci.quantity,
        "selectedSize": ci.selected_size or "",
        "selectedColorName": ci.selected_color_name or "",
        "selectedColorHex": ci.selected_color_hex or "#000000",
        "stock": p.stock,
    }


def order_item_to_dict(oi: OrderItem) -> dict:
    return {
        "productId": oi.product_id,
        "nameKhmer": oi.name_khmer,
        "nameEnglish": oi.name_english,
        "imageUrl": oi.image_url or "",
        "quantity": oi.quantity,
        "price": oi.price,
        "selectedSize": oi.selected_size or "",
        "selectedColorName": oi.selected_color_name or "",
    }


def order_to_dict(o: Order) -> dict:
    return {
        "id": o.id,
        "totalAmount": o.total_amount,
        "status": o.status,
        "customerName": o.customer_name,
        "phone": o.phone,
        "address": o.address,
        "paymentMethod": o.payment_method,
        "createdAt": o.created_at.isoformat() if o.created_at else "",
        "items": [order_item_to_dict(i) for i in o.items],
    }