from pydantic import BaseModel, field_validator, ConfigDict
from fastapi import File, Form, UploadFile

class BookRespone(BaseModel):
    id         : str
    title      : str
    description: str
    author_name: str
    rating     : float
    language   : str
    page       : int
    cover_name : str                        # image filename from DB
    file_name  : str                        # PDF filename from DB
    category_id: str


class BookModel(BaseModel):
    id         : str
    title      : str
    description: str | None = None
    author_name: str | None = None
    rating     : float
    language   : str | None = None
    page       : int
    cover_image: UploadFile         # binary upload
    file_path  : UploadFile         # binary upload
    category_id: str

    model_config = ConfigDict(from_attributes=True)


    @classmethod
    def form(
        cls,
        id          : str        = Form(..., description= "ID", examples= [""]),
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
            id=id,
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
    