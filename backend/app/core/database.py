from sqlalchemy import create_engine, Column, Integer, String, Boolean, Float, DateTime, ForeignKey, JSON
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, relationship
import datetime

from app.core.config import settings

engine = create_engine(settings.database_url, connect_args={"check_same_thread": False})
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()


class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    email = Column(String, unique=True, index=True, nullable=False)
    phone = Column(String, nullable=True)
    hashed_password = Column(String, nullable=False)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)


class Category(Base):
    __tablename__ = "categories"
    id = Column(Integer, primary_key=True, index=True)
    name_khmer = Column(String, nullable=False)
    name_english = Column(String, nullable=False)
    icon = Column(String, default="category")
    color = Column(String, default="#FF8C42")


class Product(Base):
    __tablename__ = "products"
    id = Column(Integer, primary_key=True, index=True)
    name_khmer = Column(String, nullable=False)
    name_english = Column(String, nullable=False)
    description_khmer = Column(String, default="")
    description_english = Column(String, default="")
    price = Column(Float, default=0)
    stock = Column(Integer, default=0)
    rating = Column(Float, default=0)
    reviews = Column(Integer, default=0)
    image_url = Column(String, default="")
    # Free-form category string; must match Category.name_khmer for filtering.
    category = Column(String, default="")
    images = Column(JSON, default=list)
    sizes = Column(JSON, default=list)
    colors = Column(JSON, default=list)  # [{name, hex}]


class CartItem(Base):
    __tablename__ = "cart_items"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    product_id = Column(Integer, ForeignKey("products.id"), nullable=False)
    quantity = Column(Integer, default=1)
    selected_size = Column(String, default="")
    selected_color_name = Column(String, default="")
    selected_color_hex = Column(String, default="#000000")
    created_at = Column(DateTime, default=datetime.datetime.utcnow)
    product = relationship("Product")


class Order(Base):
    __tablename__ = "orders"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    total_amount = Column(Float, default=0)
    status = Column(String, default="pending")  # pending | processing | completed | cancelled
    customer_name = Column(String, nullable=False)
    phone = Column(String, nullable=False)
    address = Column(String, default="")
    payment_method = Column(String, default="សាច់ប្រាក់")
    created_at = Column(DateTime, default=datetime.datetime.utcnow)
    items = relationship("OrderItem", back_populates="order", cascade="all, delete-orphan")


class OrderItem(Base):
    __tablename__ = "order_items"
    id = Column(Integer, primary_key=True, index=True)
    order_id = Column(Integer, ForeignKey("orders.id"), nullable=False)
    product_id = Column(Integer, nullable=False)
    name_khmer = Column(String, default="")
    name_english = Column(String, default="")
    image_url = Column(String, default="")
    quantity = Column(Integer, default=1)
    price = Column(Float, default=0)
    selected_size = Column(String, default="")
    selected_color_name = Column(String, default="")
    order = relationship("Order", back_populates="items")


def create_tables():
    Base.metadata.create_all(bind=engine)
    _seed_initial_data()


def _seed_initial_data():
    from app.core.security import hash_password
    db = SessionLocal()

    # Demo user: sokthyda@gmail.com / password123
    if not db.query(User).filter(User.email == "sokthyda@gmail.com").first():
        db.add(User(name="សុខ ធីតា", email="sokthyda@gmail.com",
                    phone="012345678", hashed_password=hash_password("password123")))

    categories = [
        # name_khmer, name_english, icon, color
        ("ម៉ូតស្ត្រី", "Women's Fashion", "face", "#FF8C42"),
        ("ម៉ូតប្រុស", "Men's Fashion", "checkroom", "#2C3E50"),
        ("កាបូប", "Bags", "shopping_bag", "#E67E22"),
        ("ស្បែកជើង", "Shoes", "sports_handball", "#8E44AD"),
        ("គ្រឿងអលង្ការ", "Accessories", "star", "#E74C3C"),
    ]
    if not db.query(Category).first():
        for name_kh, name_en, icon, color in categories:
            db.add(Category(name_khmer=name_kh, name_english=name_en, icon=icon, color=color))

    products = [
        ("អាវសូត្រសម្រាប់ស្ត្រី", "White Silk Blouse", "អាវសូត្រពណ៌សទាន់សម័យ ស្រួលពាក់", "A stylish white silk blouse, comfortable for everyday wear.", 29.99,
         50, 4.7, 128, "https://picsum.photos/seed/f001/500/600", "ម៉ូតស្ត្រី", ["S", "M", "L", "XL"], [{"name": "ស", "hex": "#FFFFFF"}, {"name": "ខ្មៅ", "hex": "#000000"}]),
        ("អាវយឺតដៃវែងខ្មៅ", "Black Long-Sleeve Tee", "អាវយឺតដៃវែងពណ៌ខ្មៅ ស្រាល មិនក្តៅ", "Lightweight black long-sleeve tee, breathable fabric.", 19.99,
         80, 4.5, 96, "https://picsum.photos/seed/m001/500/600", "ម៉ូតប្រុស", ["M", "L", "XL"], [{"name": "ខ្មៅ", "hex": "#000000"}]),
        ("ខោខូវប៊យ", "Classic Blue Jeans", "ខោខូវប៊យកាត់តាមបែបបុរាណ", "Classic cut blue jeans with stretch fit.", 39.99,
         35, 4.6, 210, "https://picsum.photos/seed/m002/500/600", "ម៉ូតប្រុស", ["S", "M", "L", "XL", "XXL"], [{"name": "ខៀវ", "hex": "#2E4053"}]),
        ("រ៉ូបផ្កា", "Floral Print Dress", "រ៉ូបបោះពុម្ពផ្កា ម៉ូដរដូវក្តៅ", "Floral print summer dress with lightweight fabric.", 49.99,
         20, 4.8, 175, "https://picsum.photos/seed/f002/500/600", "ម៉ូតស្ត្រី", ["S", "M", "L"], [{"name": "ក្រហម", "hex": "#C0392B"}, {"name": "ខៀវ", "hex": "#2980B9"}]),
        ("កាបូបស្បែក", "Leather Handbag", "កាបូបស្បែកម៉ូដទាន់សម័យ", "Genuine leather handbag, spacious and durable.", 89.99,
         15, 4.9, 320, "https://picsum.photos/seed/b001/500/600", "កាបូប", ["One Size"], [{"name": "ត្នោត", "hex": "#6E2C00"}, {"name": "ខ្មៅ", "hex": "#000000"}]),
        ("ស្បែកជើងប៉ាតា", "White Sneakers", "ស្បែកជើងប៉ាតាពណ៌ស ស្រួលពាក់", "Comfortable white sneakers for everyday use.", 59.99,
         40, 4.7, 240, "https://picsum.photos/seed/s001/500/600", "ស្បែកជើង", ["38", "39", "40", "41", "42"], [{"name": "ស", "hex": "#FFFFFF"}]),
        ("ក្រវិលមាស", "Gold Hoop Earrings", "ក្រវិលមាសសម្រាប់គ្រប់ឱកាស", "Elegant gold hoop earrings for all occasions.", 24.99,
         60, 4.4, 88, "https://picsum.photos/seed/a001/500/600", "គ្រឿងអលង្ការ", ["One Size"], [{"name": "មាស", "hex": "#D4AF37"}]),
    ]
    if not db.query(Product).first():
        for (name_kh, name_en, desc_kh, desc_en, price, stock, rating, reviews, img, cat, sizes, colors) in products:
            db.add(Product(name_khmer=name_kh, name_english=name_en,
                           description_khmer=desc_kh, description_english=desc_en,
                           price=price, stock=stock, rating=rating, reviews=reviews,
                           image_url=img, category=cat,
                           images=[img], sizes=sizes, colors=colors))

    db.commit()
    db.close()


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()