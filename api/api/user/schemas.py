from fastapi import HTTPException
from pydantic import BaseModel, ConfigDict, field_validator
import bcrypt


class UserRespone(BaseModel):
    id      : int
    username: str
    gender  : str
    phone   : str
    email   : str
    password: str


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
            raise HTTPException(status_code=404, detail="Username must not be empty")
        if len(v) < 3:
            raise HTTPException(status_code=404, detail="Username must be at least 3 characters")
        return v.strip()

    @field_validator('email')
    @classmethod
    def validate_email(cls, v: str):
        if '@' not in v or '.' not in v.split('@')[-1]:
            raise HTTPException(status_code=404, detail="Invalid email format")
        return v.lower().strip()

    @field_validator('password')
    @classmethod
    def hash_password(cls, v: str):
        if not v.strip():
            raise HTTPException(status_code=404, detail="Password must not be empty")
        if len(v) < 6:
            raise HTTPException(status_code=404, detail="Password must be at least 6 characters")
        hashed = bcrypt.hashpw(v.encode('utf-8'), bcrypt.gensalt())
        return hashed.decode('utf-8')
    
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
