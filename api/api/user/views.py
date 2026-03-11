from fastapi import HTTPException
from api.hasing import Hash
from api.user.models import USER
from api.user.schemas import UserModel
from core.db import db
from main import app
from sqlalchemy.exc import IntegrityError

@app.post("/user/create", tags=["USER"])
async def create_user(userModel: UserModel):
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
        return {
            "message": f"User '{userModel.username}' ({userModel.email}) created successfully!"
        }

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
            raise HTTPException(status_code=400, detail="User already exists")

@app.get("/user/get-all-user", tags= ["USER"])
async def get_user():
    users = db.query(USER).all()
    if not users:
        raise HTTPException(status_code= 404, detail= "User not found...!")
    return users

@app.put("/user/{id}", tags= ["USER"])
async def update_user(user_id: int, userModel : UserModel):
    try:
        user = db.query(USER).filter(USER.id == user_id).first()
        if not user:
            raise HTTPException(status_code= 404, detail= "user id not found. update not success...!")
        hashed_password = Hash.bcrypt(userModel.password)
        setattr(user, "username", userModel.username)
        setattr(user, "gender", userModel.gender)
        setattr(user, "phone", userModel.phone)
        setattr(user, "email", userModel.email)
        setattr(user, "password", hashed_password)
        db.commit()
        db.refresh(user)
        return {"message" : f"Username {userModel.username} is updated...!"}
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
            raise HTTPException(status_code=400, detail="User already exists")

@app.delete("/user/{id}", tags=["USER"])
async def delete_user(user_id : int):
    user = db.query(USER).filter(USER.id == user_id).first()
    if not user:
        raise HTTPException(status_code= 404, detail= "User id not found. delete not success...!")
    db.delete(user)
    db.commit()
    return {"message" : f"User id : {user_id} deleted....!"}