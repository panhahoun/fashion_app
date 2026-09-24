from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from pydantic import BaseModel
from app.core.database import get_db, User, Product, CartItem
from app.core.security import get_current_user
from app.serializers import cart_item_to_dict

router = APIRouter()


class AddCartRequest(BaseModel):
    product_id: int
    quantity: int = 1
    selected_size: str = ""
    selected_color_name: str = ""
    selected_color_hex: str = "#000000"


class UpdateCartRequest(BaseModel):
    quantity: int


@router.get("")
def get_cart(current: User = Depends(get_current_user), db: Session = Depends(get_db)):
    items = db.query(CartItem).filter(CartItem.user_id == current.id).all()
    result = []
    for ci in items:
        p = db.query(Product).filter(Product.id == ci.product_id).first()
        if p:
            result.append(cart_item_to_dict(ci, p))
    return result


@router.post("")
def add_to_cart(data: AddCartRequest,
                current: User = Depends(get_current_user),
                db: Session = Depends(get_db)):
    p = db.query(Product).filter(Product.id == data.product_id).first()
    if not p:
        raise HTTPException(status_code=404, detail="រកមិនឃើញផលិតផល")
    if p.stock <= 0:
        raise HTTPException(status_code=400, detail="ផលិតផលនេះអស់ស្តុក")

    existing = (db.query(CartItem)
                .filter(CartItem.user_id == current.id,
                        CartItem.product_id == data.product_id,
                        CartItem.selected_size == data.selected_size,
                        CartItem.selected_color_name == data.selected_color_name)
                .first())
    if existing:
        existing.quantity += data.quantity
        db.commit()
        db.refresh(existing)
        return cart_item_to_dict(existing, p)

    ci = CartItem(user_id=current.id, product_id=data.product_id,
                  quantity=data.quantity, selected_size=data.selected_size,
                  selected_color_name=data.selected_color_name,
                  selected_color_hex=data.selected_color_hex)
    db.add(ci)
    db.commit()
    db.refresh(ci)
    return cart_item_to_dict(ci, p)


@router.put("/{cart_id}")
def update_cart(cart_id: int, data: UpdateCartRequest,
                current: User = Depends(get_current_user),
                db: Session = Depends(get_db)):
    ci = db.query(CartItem).filter(CartItem.id == cart_id,
                                   CartItem.user_id == current.id).first()
    if not ci:
        raise HTTPException(status_code=404, detail="រកមិនឃើញទំនិញក្នុងកន្ត្រក")
    if data.quantity < 1:
        raise HTTPException(status_code=400, detail="បរិមាណត្រូវតែយ៉ាងហោចណាស់ 1")
    ci.quantity = data.quantity
    db.commit()
    db.refresh(ci)
    p = db.query(Product).filter(Product.id == ci.product_id).first()
    return cart_item_to_dict(ci, p)


@router.delete("/{cart_id}")
def remove_cart(cart_id: int,
                current: User = Depends(get_current_user),
                db: Session = Depends(get_db)):
    ci = db.query(CartItem).filter(CartItem.id == cart_id,
                                   CartItem.user_id == current.id).first()
    if not ci:
        raise HTTPException(status_code=404, detail="រកមិនឃើញទំនិញក្នុងកន្ត្រក")
    db.delete(ci)
    db.commit()
    return {"ok": True}