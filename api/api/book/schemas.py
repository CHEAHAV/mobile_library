from pydantic import BaseModel, field_validator, ConfigDict
from fastapi import File, Form, HTTPException, UploadFile

class BookResponse(BaseModel):
    id         : str
    title      : str
    description: str
    author_name: str
    rating     : float
    language   : str
    page       : int
    cover_name : str    # image filename from DB
    file_name  : str    # PDF filename from DB
    category_id: str


class BookModel(BaseModel):
    title      : str
    description: str | None = None
    author_name: str | None = None
    rating     : float
    language   : str | None = None
    page       : int
    cover_image: UploadFile   # binary upload
    file_path  : UploadFile   # binary upload
    category_id: str


    @classmethod
    def form(
        cls,
        title       : str        = Form(..., description= "Title", examples= [""]),
        description: str         = Form(None,description= "Description", examples= [""]),
        author_name: str         = Form(None,description= "Author name", examples= [""]),
        rating      : float      = Form(...,description= "Rating", examples= [""]),
        language    : str        = Form(None,description= "Language", examples= [""]),
        page        : int        = Form(...,description= "Page", examples= [""]),
        cover_image: UploadFile  = File(...,description= "Cover Image", examples= [""]),
        file_path   : UploadFile = File(...,description= "File PDF", examples= [""]),
        category_id: str         = Form(...,description= "Category ID", examples= [""]),
    ):
        return cls(
            title=title, 
            description=description, 
            author_name=author_name,
            rating=rating, 
            language=language, 
            page=page,
            cover_image=cover_image, 
            file_path=file_path, 
            category_id=category_id,
        )

    @field_validator('cover_image')
    @classmethod
    def validate_cover_image(cls, v: UploadFile):
        allowed = {'image/jpeg', 'image/png', 'image/svg+xml'}
        if v.content_type not in allowed:
            raise HTTPException(status_code=404, detail="Cover image must be jpg, png, or svg")
        return v
    
    @field_validator('file_path')
    @classmethod
    def validate_file_path(cls, v: UploadFile):
        allowed = {'application/pdf'}
        if v.content_type not in allowed:
            raise HTTPException(status_code=404, detail="File path must be pdf")
        return v

    @field_validator('rating')
    @classmethod
    def validate_rating(cls, v: float):
        if not 0 <= v <= 5:
            raise HTTPException(status_code=404, detail="Rating must be between 0 and 5")
        return v

    @field_validator('page')
    @classmethod
    def validate_page_count(cls, v: int):
        if v <= 0:
            raise HTTPException(status_code=404, detail="Page count must be greater than 0")
        return v
    