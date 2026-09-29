from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from pydantic import BaseModel
from app.core.database import get_db, User, Address
from app.core.security import get_current_user
from app.serializers import address_to_dict

router = APIRouter()


class AddressRequest(BaseModel):
    label: str = ""
    recipient_name: str = ""
    phone: str = ""
    detail: str = ""
    is_default: bool = False


def _own_address(db: Session, address_id: int, user_id: int) -> Address:
    address = (db.query(Address)
               .filter(Address.id == address_id, Address.user_id == user_id)
               .first())
    if not address:
        raise HTTPException(status_code=404, detail="រកមិនឃើញអាសយដ្ឋាន")
    return address


def _apply_default(db: Session, user_id: int, address_id: int) -> None:
    """Ensure only one address is flagged as the default.

    Flags are assigned through the ORM (not a bulk UPDATE) so the changes are
    tracked and written by the surrounding commit.
    """
    for address in db.query(Address).filter(Address.user_id == user_id).all():
        address.is_default = (address.id == address_id)


@router.get("")
def list_addresses(current: User = Depends(get_current_user),
                   db: Session = Depends(get_db)):
    addresses = (db.query(Address)
                 .filter(Address.user_id == current.id)
                 .order_by(Address.is_default.desc(), Address.id.desc())
                 .all())
    return [address_to_dict(a) for a in addresses]


@router.post("")
def create_address(data: AddressRequest,
                   current: User = Depends(get_current_user),
                   db: Session = Depends(get_db)):
    if not data.detail.strip():
        raise HTTPException(status_code=400, detail="សូមបញ្ចូលព័ត៌មានអាសយដ្ឋាន")
    address = Address(
        user_id=current.id,
        label=data.label.strip(),
        recipient_name=data.recipient_name.strip(),
        phone=data.phone.strip(),
        detail=data.detail.strip(),
        is_default=False,
    )
    db.add(address)
    db.flush()

    # The very first address becomes the default automatically.
    existing = (db.query(Address)
                .filter(Address.user_id == current.id, Address.id != address.id)
                .count())
    if data.is_default or existing == 0:
        _apply_default(db, current.id, address.id)

    db.commit()
    db.refresh(address)
    return address_to_dict(address)


@router.put("/{address_id}")
def update_address(address_id: int, data: AddressRequest,
                   current: User = Depends(get_current_user),
                   db: Session = Depends(get_db)):
    address = _own_address(db, address_id, current.id)
    if not data.detail.strip():
        raise HTTPException(status_code=400, detail="សូមបញ្ចូលព័ត៌មានអាសយដ្ឋាន")
    address.label = data.label.strip()
    address.recipient_name = data.recipient_name.strip()
    address.phone = data.phone.strip()
    address.detail = data.detail.strip()
    if data.is_default:
        _apply_default(db, current.id, address.id)
    db.commit()
    db.refresh(address)
    return address_to_dict(address)


@router.delete("/{address_id}")
def delete_address(address_id: int,
                   current: User = Depends(get_current_user),
                   db: Session = Depends(get_db)):
    address = _own_address(db, address_id, current.id)
    was_default = bool(address.is_default)
    db.delete(address)
    db.flush()
    # Promote another address so the user always keeps a default.
    if was_default:
        replacement = (db.query(Address)
                       .filter(Address.user_id == current.id)
                       .order_by(Address.id.desc())
                       .first())
        if replacement:
            replacement.is_default = True
    db.commit()
    return {"ok": True}
