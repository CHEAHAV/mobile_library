from datetime import datetime
import os
from typing import Optional
from pydantic import BaseModel, field_validator, ConfigDict
from fastapi import File, Form, UploadFile


class BookRespone(BaseModel):
    title: str
    description: Optional[str] = None
    author_name : str | None = None
    rating: float
    language: Optional[str] = None
    page: int
    cover_image: str
    file_path: str
    create_at: Optional[datetime] = None

    model_config = ConfigDict(from_attributes=True)


class BookModel(BaseModel):
    # Override file fields to accept UploadFile instead of str
    title: str
    description: Optional[str] = None
    author_name : str | None = None
    rating: float = 1
    language: Optional[str] = None
    page: int = 1
    cover_image: UploadFile
    file_path: UploadFile
    category_id: int

    model_config = ConfigDict(arbitrary_types_allowed=True)

    @classmethod
    def form(
        cls,
        title: str = Form(..., description="Title"),
        description: str = Form(None, description="Description"),
        author_name : str = Form(None, description= "Author name"),
        rating: float = Form(1, description="Rating"),
        language: str = Form(None, description="Language"),
        page: int = Form(1, description="Page"),
        cover_image: UploadFile = File(..., description="Cover Image"),
        file_path: UploadFile = File(..., description="File path"),
        category_id: int = Form(..., description="Category ID"),
    ):
        return cls(
            title=title,
            description=description,
            author_name = author_name,
            rating=rating,
            language=language,
            page=page,
            cover_image=cover_image,
            file_path=file_path,
            category_id = category_id,
        )

    # 1. Validate Rating (0 to 5 scale)
    @field_validator('rating')
    @classmethod
    def validate_rating(cls, v: float):
        if not 0 <= v <= 5:
            raise ValueError('Rating must be between 0 and 5')
        return v

    # 2. Validate Page Count (Must be positive)
    @field_validator('page')
    @classmethod
    def validate_page_count(cls, v: int):
        if v <= 0:
            raise ValueError('Page count must be greater than 0')
        return v

    # 3. Validate Cover Image Extension
    @field_validator('cover_image')
    @classmethod
    def validate_cover_type(cls, v: UploadFile):
        if v.content_type not in ["image/jpeg", "image/png", "image/webp", "image/jpg"]:
            raise ValueError("File type not supported. Please upload a real image.")
        return v

    # 4. Validate PDF File Extension
    @field_validator('file_path')
    @classmethod
    def validate_pdf_extension(cls, v: UploadFile):
        filename = v.filename
        if not filename:
            raise ValueError("The uploaded file must have a filename.")
        if not filename.lower().endswith('.pdf'):
            raise ValueError("The book file must be a PDF")
        return v

    async def save_cover_image(self) -> str | None:
        if not self.cover_image or not self.cover_image.filename:
            return None
        upload_dir = "uploads/book_pictures"
        os.makedirs(upload_dir, exist_ok=True)
        cover_image = self.cover_image.filename
        content = await self.cover_image.read()
        file_path = os.path.join(upload_dir, cover_image)
        with open(file_path, "wb") as f:
            f.write(content)
        return cover_image

    async def update_cover_image(self, old_name: str):
        if not self.cover_image or not self.cover_image.filename:
            return old_name
        upload_dir = "uploads/book_pictures"
        old_path = os.path.join(upload_dir, old_name)
        if os.path.exists(old_path):
            os.remove(old_path)
        new_name = self.cover_image.filename
        new_path = os.path.join(upload_dir, new_name)
        content = await self.cover_image.read()
        with open(new_path, "wb") as f:
            f.write(content)
        return new_name

    async def save_pdf(self) -> str | None:
        if not self.file_path or not self.file_path.filename:
            return None
        pdf_dir = "uploads/book_pdfs"
        os.makedirs(pdf_dir, exist_ok=True)
        file_name = self.file_path.filename
        save_path = os.path.join(pdf_dir, file_name)
        content = await self.file_path.read()
        with open(save_path, "wb") as f:
            f.write(content)
        return file_name
    
    async def update_pdf(self, old_name: str) -> str | None:
        if not self.file_path or not self.file_path.filename:
            return old_name
        pdf_dir = "uploads/book_pdfs"
        
        # Remove the old PDF file
        old_path = os.path.join(pdf_dir, old_name)
        if os.path.exists(old_path):
            os.remove(old_path)
        
        # Save the new PDF file
        file_name = self.file_path.filename
        new_path = os.path.join(pdf_dir, file_name)
        content = await self.file_path.read()
        with open(new_path, "wb") as f:
            f.write(content)
        
        return file_name