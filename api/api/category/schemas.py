from pydantic import BaseModel, field_validator, ConfigDict
from fastapi import Form, HTTPException
from api.book.schemas import BookResponse
from core.db import get_db

class CategoryRespone(BaseModel):
    id           : str
    category_name: str


class CategoryResponeWithBooks(BaseModel):
    category_name: str
    books        : list[BookResponse] = []


class CategoryModel(BaseModel):
    id           : str
    category_name: str

    @classmethod
    def form(cls,
             id            : str = Form(...,description= "ID", examples= [""]),
             category_name: str  = Form(...,description= "Category name", examples= [""])):
        return cls(
            id=id,
            category_name=category_name)

    @field_validator("category_name")
    @classmethod
    def validate_category_name(cls, v: str):
        if len(v.strip()) < 3:
            raise HTTPException(status_code=404, detail="Category name must be 3 characters or more!")
        return v.strip()