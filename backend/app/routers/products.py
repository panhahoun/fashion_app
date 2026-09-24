from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.core.database import get_db, Product
from app.serializers import product_to_dict

router = APIRouter()


@router.get("")
def list_products(search: str | None = None,
                  category: str | None = None,
                  db: Session = Depends(get_db)):
    query = db.query(Product)
    if category:
        query = query.filter(Product.category == category)
    if search:
        like = f"%{search.strip()}%"
        query = query.filter(
            (Product.name_khmer.like(like))
            | (Product.name_english.like(like))
            | (Product.category.like(like))
        )
    return [product_to_dict(p) for p in query.all()]


@router.get("/{product_id}")
def get_product(product_id: int, db: Session = Depends(get_db)):
    product = db.query(Product).filter(Product.id == product_id).first()
    if not product:
        raise HTTPException(status_code=404, detail="រកមិនឃើញផលិតផល")
    return product_to_dict(product)