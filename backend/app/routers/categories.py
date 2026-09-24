from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.core.database import get_db, Category
from app.serializers import category_to_dict

router = APIRouter()


@router.get("")
def list_categories(db: Session = Depends(get_db)):
    return [category_to_dict(c) for c in db.query(Category).all()]