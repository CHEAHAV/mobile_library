from pydantic import BaseModel, field_validator, ConfigDict
from fastapi import Form
from api.book.schemas import BookRespone


class CategoryRespone(BaseModel):
    id: int
    category_name: str

    model_config = ConfigDict(from_attributes=True)


# includes books list
class CategoryResponeWithBooks(BaseModel):
    category_name: str
    books: list[BookRespone] = []

    model_config = ConfigDict(from_attributes=True)


class CategoryModel(BaseModel):
    category_name: str

    @classmethod
    def form(cls, category_name: str = Form(...)):
        return cls(category_name=category_name)

    @field_validator("category_name")
    @classmethod
    def validate_category_name(cls, v: str):
        if len(v.strip()) < 3:
            raise ValueError("Category name must be at least 3 characters")
        return v.strip()