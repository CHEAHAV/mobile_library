from sqlalchemy import Column, DateTime, Integer, String, func
from sqlalchemy.orm import relationship
from core.db import Base

class CATEGORY(Base):
    __tablename__ = "tbl_category"
    
    id            = Column(String(64), primary_key= True, nullable= False)
    category_name = Column(String(100), nullable = False, unique=True)
    create_at     = Column(DateTime, server_default=func.now())
    
    books = relationship("BOOK", back_populates="category")
    