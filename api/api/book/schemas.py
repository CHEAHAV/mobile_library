from datetime import datetime
from typing import Optional
from pydantic import BaseModel, field_validator, ConfigDict
from fastapi import File, Form, UploadFile


class BookRespone(BaseModel):
    id: int
    title: str
    description: Optional[str] = None
    author_name: Optional[str] = None
    rating: float
    language: Optional[str] = None
    page: int
    cover_name: str    # ✅ image filename from DB
    file_name: str     # ✅ PDF filename from DB
    create_at: Optional[datetime] = None

    model_config = ConfigDict(from_attributes=True)


class BookModel(BaseModel):
    title: str
    description: Optional[str] = None
    author_name: Optional[str] = None
    rating: float = 1.0
    language: Optional[str] = None
    page: int = 1
    cover_image: UploadFile   # ✅ binary upload
    file_path: UploadFile     # ✅ binary upload
    category_id: int

    model_config = ConfigDict(arbitrary_types_allowed=True)

    @classmethod
    def form(
        cls,
        title: str = Form(...),
        description: str = Form(None),
        author_name: str = Form(None),
        rating: float = Form(1.0),
        language: str = Form(None),
        page: int = Form(1),
        cover_image: UploadFile = File(...),
        file_path: UploadFile = File(...),
        category_id: int = Form(...),
    ):
        return cls(
            title=title, description=description, author_name=author_name,
            rating=rating, language=language, page=page,
            cover_image=cover_image, file_path=file_path, category_id=category_id,
        )

    @field_validator('rating')
    @classmethod
    def validate_rating(cls, v: float):
        if not 0 <= v <= 5:
            raise ValueError('Rating must be between 0 and 5')
        return v

    @field_validator('page')
    @classmethod
    def validate_page_count(cls, v: int):
        if v <= 0:
            raise ValueError('Page count must be greater than 0')
        return v

    @field_validator('category_id')
    @classmethod
    def validate_category_id(cls, v: int):
        if v <= 0:
            raise ValueError('category_id must be greater than 0')
        return v