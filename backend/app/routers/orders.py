from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from pydantic import BaseModel
from app.core.database import get_db, User, Product, CartItem, Order, OrderItem
from app.core.security import get_current_user
from app.serializers import order_to_dict

router = APIRouter()


class OrderItemRequest(BaseModel):
    product_id: int
    quantity: int = 1
    price: float = 0
    selected_size: str = ""
    selected_color_name: str = ""


class CreateOrderRequest(BaseModel):
    customer_name: str
    phone: str
    address: str = ""
    payment_method: str = "សាច់ប្រាក់"
    items: list[OrderItemRequest]


@router.get("")
def get_orders(current: User = Depends(get_current_user), db: Session = Depends(get_db)):
    orders = db.query(Order).filter(Order.user_id == current.id).order_by(Order.id.desc()).all()
    return [order_to_dict(o) for o in orders]


@router.post("")
def create_order(data: CreateOrderRequest,
                 current: User = Depends(get_current_user),
                 db: Session = Depends(get_db)):
    if not data.items:
        raise HTTPException(status_code=400, detail="កន្ត្រករបស់អ្នកទទេ")

    total = 0.0
    items = []
    for req in data.items:
        p = db.query(Product).filter(Product.id == req.product_id).first()
        if not p:
            raise HTTPException(status_code=404, detail=f"រកមិនឃើញផលិតផល #{req.product_id}")
        price = p.price
        total += price * req.quantity
        items.append(OrderItem(
            product_id=p.id,
            name_khmer=p.name_khmer,
            name_english=p.name_english,
            image_url=p.image_url or "",
            quantity=req.quantity,
            price=price,
            selected_size=req.selected_size,
            selected_color_name=req.selected_color_name,
        ))
        # Reduce stock (clamped at 0)
        p.stock = max(0, p.stock - req.quantity)

    order = Order(
        user_id=current.id,
        total_amount=round(total, 2),
        customer_name=data.customer_name.strip(),
        phone=data.phone.strip(),
        address=data.address.strip(),
        payment_method=data.payment_method,
        items=items,
    )
    db.add(order)
    db.flush()

    # Clear the user's cart after a successful order.
    db.query(CartItem).filter(CartItem.user_id == current.id).delete()

    db.commit()
    db.refresh(order)
    return order_to_dict(order)