from pydantic import BaseModel, field_validator
import bcrypt


class UserRespone(BaseModel):
    id: int
    username: str
    email: str
    password: str


class UserModel(BaseModel):
    username: str
    email: str
    password: str

    @field_validator('username')
    @classmethod
    def validate_username(cls, v: str):
        if not v.strip():
            raise ValueError('Username must not be empty or whitespace')
        if len(v) < 3:
            raise ValueError('Username must be at least 3 characters')
        return v.strip()

    @field_validator('email')
    @classmethod
    def validate_email(cls, v: str):
        if '@' not in v or '.' not in v.split('@')[-1]:
            raise ValueError('Invalid email format')
        return v.lower().strip()

    @field_validator('password')
    @classmethod
    def hash_password(cls, v: str):
        if not v.strip():
            raise ValueError('Password must not be empty')
        if len(v) < 8:
            raise ValueError('Password must be at least 8 characters')
        hashed = bcrypt.hashpw(v.encode('utf-8'), bcrypt.gensalt())
        return hashed.decode('utf-8')