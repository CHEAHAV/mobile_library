from fastapi import HTTPException
from pydantic import BaseModel, ConfigDict, field_validator

class UserResponseLogin(BaseModel):
    username: str
    gender  : str
    phone   : str
    email   : str


class UserModel(BaseModel):
    username: str
    gender  : str
    phone   : str
    email   : str
    password: str

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

    @field_validator('password')
    @classmethod
    def validate_password(cls, v: str):
        if not v.strip():
            raise HTTPException(status_code=400, detail="Password must not be empty!")
        if len(v) < 6:
            raise HTTPException(status_code=400, detail="Password must be at least 6 characters!")
        return v  # ✅ return plain password, let views.py handle hashing

    model_config = ConfigDict(
        from_attributes=True,
        json_schema_extra={
            "example": {
                "username": "snoopy",
                "gender"  : "male",
                "phone"   : "09878654321",
                "email"   : "snoopy123@gmail.com",
                "password": "123123",
            }
        }
    )


class UserLogin(BaseModel):
    username: str
    password: str

    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "username": "snoopy",
                "password": "123123",
            }
        }
    )