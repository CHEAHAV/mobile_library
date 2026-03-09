from sqlalchemy import Column, DateTime, Integer, String, func

from core.db import Base


class USER(Base):
    __tablename__ = "tbl_user"

    id = Column(Integer, unique= True, primary_key= True, autoincrement= True)
    username = Column(String(100), nullable= False)
    email = Column(String(100), nullable= False)
    password = Column(String(100), nullable= False)
    create_at = Column(DateTime, server_default=func.now())