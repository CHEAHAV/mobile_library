import os
from typing import Optional
from pydantic import BaseModel, field_validator, ConfigDict
from fastapi import File, Form, UploadFile

from api.book.schemas import BookRespone

class CategoryRespone(BaseModel):
    category_name : str
    
    class Config:
        from_attributes = True

class CategoryResponeWithBooks(BaseModel):
    category_name: str
    books: list[BookRespone] = []

    class Config:
        from_attributes = True


class CategoryModel(BaseModel):
    category_name: str

    @classmethod
    def form(
        cls,
        category_name: str = Form(..., description="Category name"),
    ):
        return cls(
            category_name=category_name,
        )

    # 1. Validate category_name
    @field_validator("category_name")
    @classmethod
    def validate_lengths(cls, v: str, info):
        if v and len(v) < 3:
            raise ValueError(f"{info.category_name.capitalize()} must be at least 3 characters")
        return v
