from sqlalchemy import Column, DateTime, ForeignKey, Integer, String, Numeric, Text, func
from sqlalchemy.orm import relationship
from core.db import Base
class BOOK(Base):
    __tablename__ = "tbl_book"
    
    id          = Column(Integer, primary_key=True, autoincrement=True, unique=True)
    title       = Column(String(100), nullable = False)
    description = Column(String(255))
    author_name = Column(String(100))
    rating      = Column(Numeric(3,2))
    language    = Column(String(64))
    page        = Column(Integer)
    file_path   = Column(String, nullable = False)
    cover_image = Column(String(255), nullable=False)
    category_id = Column(Integer, ForeignKey("tbl_category.id"), nullable= False)
    
    create_at = Column(DateTime, server_default=func.now())

    category = relationship("CATEGORY", back_populates="books")