from fastapi import HTTPException, Depends
from sqlalchemy.orm import Session
from api.hasing import Hash
from api.user.models import USER
from api.user.schemas import UserModel
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
            raise HTTPException(status_code=400, detail="Username already taken")
        elif "email" in error:
            raise HTTPException(status_code=400, detail="Email already registered")
        elif "phone" in error:
            raise HTTPException(status_code=400, detail="Phone already registered")
        else:
            raise HTTPException(status_code=400, detail=f"Database error: {error}")


@app.get("/user/get-all-user", tags=["USER"])
async def get_user(db: Session = Depends(get_db)):
    users = db.query(USER).all()
    if not users:
        raise HTTPException(status_code=404, detail="User not found...!")
    return users


@app.put("/user/{user_id}", tags=["USER"])
async def update_user(user_id: int, userModel: UserModel, db: Session = Depends(get_db)):
    try:
        user = db.query(USER).filter(USER.id == user_id).first()
        if not user:
            raise HTTPException(status_code=404, detail="User id not found. update not success...!")
        hashed_password = Hash.bcrypt(userModel.password)
        setattr(user, "username", userModel.username)
        setattr(user, "gender", userModel.gender)
        setattr(user, "phone", userModel.phone)
        setattr(user, "email", userModel.email)
        setattr(user, "password", hashed_password)
        db.commit()
        db.refresh(user)
        return {"message": f"Username {userModel.username} is updated...!"}
    except IntegrityError as e:
        db.rollback()
        error = str(e.orig).lower()
        if "username" in error:
            raise HTTPException(status_code=400, detail="Username already taken")
        elif "email" in error:
            raise HTTPException(status_code=400, detail="Email already registered")
        elif "phone" in error:
            raise HTTPException(status_code=400, detail="Phone already registered")
        else:
            raise HTTPException(status_code=400, detail=f"Database error: {error}")


@app.delete("/user/{user_id}", tags=["USER"])
async def delete_user(user_id: int, db: Session = Depends(get_db)):
    user = db.query(USER).filter(USER.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User id not found. delete not success...!")
    db.delete(user)
    db.commit()
    return {"message": f"User id: {user_id} deleted....!"}