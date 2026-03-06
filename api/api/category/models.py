from sqlalchemy import Column, DateTime, Integer, String, func
from sqlalchemy.orm import relationship
from core.db import Base

class CATEGORY(Base):
    __tablename__ = "tbl_category"
    
    id            = Column(Integer, unique=True, primary_key=True, autoincrement=True)
    category_name = Column(String(100), nullable = False)
    create_at     = Column(DateTime, server_default=func.now())
    
    books = relationship("BOOK", back_populates="category")