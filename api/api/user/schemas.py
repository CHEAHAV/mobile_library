from fastapi import File, Form, HTTPException, UploadFile
from pydantic import BaseModel, field_validator


class UserResponse(BaseModel):
    id         : int
    username   : str
    gender     : str
    phone      : str
    email      : str
    photo_name : str
class UserResponseLogin(BaseModel):
    id         : int
    username   : str
    gender     : str
    phone      : str
    email      : str
    photo_name : str


class UserModel(BaseModel):
    username: str
    gender  : str
    phone   : str
    email   : str
    password: str
    photo_image: UploadFile

    @classmethod
    def form(
        cls,
        username: str = Form(..., description="Username", examples=[""]),
        gender  : str = Form(None, description="Gender", examples=[""]),
        phone   : str = Form(..., description="Phone", examples=[""]),
        email   : str = Form(..., description="Email", examples=[""]),
        password: str = Form(..., description="Password", examples=[""]),
        photo_image: UploadFile = File(..., description="Photo Image")
    ):
        return cls(
            username=username,
            gender=gender,
            phone=phone,
            email=email,
            password=password,
            photo_image=photo_image
        )


    @field_validator('username')
    @classmethod
    def validate_username(cls, v: str):
        if not v.strip():
            raise HTTPException(status_code=400, detail="Username must not be empty!")
        if len(v) < 3:
            raise HTTPException(status_code=400, detail="Username must be at least 3 characters!")
        return v.strip()


    @field_validator('email')
    @classmethod
    def validate_email(cls, v: str):
        if '@' not in v or '.' not in v.split('@')[-1]:
            raise HTTPException(status_code=400, detail="Invalid email format!")
        return v.lower().strip()
    

    @field_validator('photo_image')
    @classmethod
    def validate_photo_image(cls, v: UploadFile):
        # Allowed MIME types
        allowed_types = {'image/jpeg', 'image/png', 'image/svg+xml'}
 
        # Fallback: check by file extension if MIME is missing/octet-stream
        allowed_exts = {'.jpg', '.jpeg', '.png', '.svg'}
 
        content_type = (v.content_type or '').lower()
        filename     = (v.filename     or '').lower()
        ext          = '.' + filename.rsplit('.', 1)[-1] if '.' in filename else ''
 
        # Accept if MIME type matches OR extension matches
        if content_type not in allowed_types and ext not in allowed_exts:
            raise HTTPException(
                status_code=400,
                detail="Photo image must be jpg, png, or svg",
            )
        return v


class UserLogin(BaseModel):
    username: str
    password: str

    @classmethod
    def form(
        cls,
        username: str = Form(..., description="Username", example=[""]),
        password: str = Form(..., description="Password", example=[""])
    ):
        return cls(
            username=username,
            password=password
        )