from fastapi import HTTPException, Depends
from sqlalchemy.orm import Session
from api.hasing import Hash
from api.user.models import USER
from api.user.schemas import UserModel, UserLogin,UserResponseLogin
from core.db import get_db
from main import app
from sqlalchemy.exc import IntegrityError


@app.post("/user/create", tags=["USER"])
async def create_user(userModel: UserModel, db: Session = Depends(get_db)):
    try:
        hashed_password = Hash.bcrypt(userModel.password)
        new_user = USER(
            username=userModel.username,
            gender=userModel.gender,
            phone=userModel.phone,
            email=userModel.email,
            password=hashed_password
        )
        db.add(new_user)
        db.commit()
        db.refresh(new_user)
        return {"message": f"User '{userModel.username}' ({userModel.email}) created successfully!"}
    except IntegrityError as e:
        db.rollback()
        error = str(e.orig).lower()
        if "username" in error:
            raise HTTPException(status_code=400, detail="Username already taken!")
        elif "email" in error:
            raise HTTPException(status_code=400, detail="Email already registered!")
        elif "phone" in error:
            raise HTTPException(status_code=400, detail="Phone already registered!")
        else:
            raise HTTPException(status_code=400, detail=f"Database error: {error}")


@app.get("/user/all", tags=["USER"])
async def get_all_users(db: Session = Depends(get_db)):
    users = db.query(USER).all()
    if not users:
        raise HTTPException(status_code=404, detail="No users found!")
    return users


@app.post("/user/login", tags=["USER"], response_model=UserResponseLogin)
async def login(userLogin: UserLogin, db: Session = Depends(get_db)):
    user = db.query(USER).filter(USER.username == userLogin.username).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found!")
    if not Hash.verify(str(user.password), userLogin.password):
        raise HTTPException(status_code=401, detail="Incorrect password!")
    return user


@app.put("/user/{user_id}", tags=["USER"])
async def update_user(user_id: int, userModel: UserModel, db: Session = Depends(get_db)):
    try:
        user = db.query(USER).filter(USER.id == user_id).first()
        if not user:
            raise HTTPException(status_code=404, detail="User not found!")
        hashed_password = Hash.bcrypt(userModel.password)
        setattr(user, "username", userModel.username)
        setattr(user, "gender", userModel.gender)
        setattr(user, "phone", userModel.phone)
        setattr(user, "email", userModel.email)
        setattr(user, "password", hashed_password)
        db.commit()
        db.refresh(user)
        return {"message": f"User '{userModel.username}' updated successfully!"}
    except IntegrityError as e:
        db.rollback()
        error = str(e.orig).lower()
        if "username" in error:
            raise HTTPException(status_code=400, detail="Username already taken!")
        elif "email" in error:
            raise HTTPException(status_code=400, detail="Email already registered!")
        elif "phone" in error:
            raise HTTPException(status_code=400, detail="Phone already registered!")
        else:
            raise HTTPException(status_code=400, detail=f"Database error: {error}")


@app.delete("/user/{user_id}", tags=["USER"])
async def delete_user(user_id: int, db: Session = Depends(get_db)):
    user = db.query(USER).filter(USER.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found!")
    db.delete(user)
    db.commit()
    return {"message": f"User id: {user_id} deleted successfully!"}