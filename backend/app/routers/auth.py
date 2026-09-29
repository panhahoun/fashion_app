from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from pydantic import BaseModel
from app.core.database import get_db, User
from app.core.security import verify_password, hash_password, create_token, get_current_user

router = APIRouter()


class RegisterRequest(BaseModel):
    name: str
    email: str
    phone: str | None = None
    password: str


class LoginRequest(BaseModel):
    email: str
    password: str


class UpdateProfileRequest(BaseModel):
    name: str | None = None
    phone: str | None = None


class ChangePasswordRequest(BaseModel):
    current_password: str
    new_password: str


def auth_response(user: User) -> dict:
    token = create_token({"sub": str(user.id), "email": user.email, "name": user.name})
    return {
        "access_token": token,
        "token_type": "bearer",
        "user": {
            "id": user.id,
            "name": user.name,
            "email": user.email,
            "phone": user.phone or "",
        },
    }


@router.post("/register")
def register(data: RegisterRequest, db: Session = Depends(get_db)):
    if db.query(User).filter(User.email == data.email.lower().strip()).first():
        raise HTTPException(status_code=400, detail="អ៊ីមែលនេះត្រូវបានប្រើរួចហើយ")
    user = User(
        name=data.name.strip(),
        email=data.email.lower().strip(),
        phone=data.phone or "",
        hashed_password=hash_password(data.password),
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    return auth_response(user)


@router.post("/login")
def login(data: LoginRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == data.email.lower().strip()).first()
    if not user or not verify_password(data.password, user.hashed_password):
        raise HTTPException(status_code=401, detail="អ៊ីមែល ឬ ពាក្យសម្ងាត់ មិនត្រឹមត្រូវ")
    return auth_response(user)


@router.get("/me")
def me(current: User = Depends(get_current_user)):
    return {"id": current.id, "name": current.name, "email": current.email,
            "phone": current.phone or ""}


@router.put("/me")
def update_me(data: UpdateProfileRequest,
              current: User = Depends(get_current_user),
              db: Session = Depends(get_db)):
    if data.name is not None:
        cleaned = data.name.strip()
        if not cleaned:
            raise HTTPException(status_code=400, detail="ឈ្មោះមិនអាចទុកទទេ")
        current.name = cleaned
    if data.phone is not None:
        current.phone = data.phone.strip()
    db.commit()
    db.refresh(current)
    return {"id": current.id, "name": current.name, "email": current.email,
            "phone": current.phone or ""}


@router.post("/change-password")
def change_password(data: ChangePasswordRequest,
                    current: User = Depends(get_current_user),
                    db: Session = Depends(get_db)):
    if not verify_password(data.current_password, current.hashed_password):
        raise HTTPException(status_code=400, detail="ពាក្យសម្ងាត់បច្ចុប្បន្នមិនត្រឹមត្រូវ")
    if len(data.new_password) < 6:
        raise HTTPException(status_code=400, detail="ពាក្យសម្ងាត់ថ្មីត្រូវមានយ៉ាងតិច 6 តួអក្សរ")
    current.hashed_password = hash_password(data.new_password)
    db.commit()
    return {"ok": True}