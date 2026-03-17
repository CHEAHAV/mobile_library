import uuid
from sqlalchemy import Column, DateTime, ForeignKey, Integer, String, Numeric, LargeBinary, func
from sqlalchemy.orm import relationship
from core.db import Base

class BOOK(Base):
    __tablename__ = "tbl_book"

    
    id = Column(String(64), primary_key=True, nullable=False, default=lambda: str(uuid.uuid4()))
    title       = Column(String(100), nullable=False)
    description = Column(String(255), nullable=False)
    author_name = Column(String(100))
    rating      = Column(Numeric(3, 2), nullable=False)
    language    = Column(String(64), nullable=False)
    page        = Column(Integer)
    file_path   = Column(LargeBinary, nullable=False)  # binary PDF
    cover_image = Column(LargeBinary, nullable=False)  # binary image
    file_name   = Column(String(255), nullable=False)  # PDF filename
    cover_name  = Column(String(255), nullable=False)  # image filename
    category_id = Column(String(64), ForeignKey("tbl_category.id"), nullable=False)
    create_at   = Column(DateTime, server_default=func.now())

    category = relationship("CATEGORY", back_populates="books")