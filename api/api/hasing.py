from passlib.context import CryptContext
from fastapi import HTTPException

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

class Hash:
    @staticmethod
    def bcrypt(password: str) -> str:
        if len(password) < 8:
            raise HTTPException(status_code=400, detail="Password must be at least 8 characters!")
        if len(password) > 72:
            raise HTTPException(status_code=400, detail="Password must be 72 characters or less!")
        return pwd_context.hash(password)

    @staticmethod
    def verify(hashed_password: str, plain_password: str) -> bool:
        return pwd_context.verify(plain_password, hashed_password)