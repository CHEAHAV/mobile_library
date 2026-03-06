from fastapi import Depends, HTTPException
from sqlalchemy.orm import joinedload
from api.category.models import CATEGORY
from api.category.schemas import CategoryModel, CategoryRespone, CategoryResponeWithBooks
from core.db import db
from main import app

@app.post("/category/create_Category", tags=["CATEGORY"])
async def create_teacher(categoryModel: CategoryModel = Depends(CategoryModel.form)):
    
    new_category = CATEGORY(
        category_name = categoryModel.category_name,
    )
    db.add(new_category)
    db.commit()
    return{"message" : f"{categoryModel} is category created successfully...!"}

@app.get("/category/get_Category", tags= ["CATEGORY"], response_model= list[CategoryRespone])
async def get_Category():
    categorys = db.query(CATEGORY).all()
    if not categorys:
        raise HTTPException(status_code= 404, detail= "Category not found...!")
    return categorys

@app.get("/category/get_Category_books", tags=["CATEGORY"], response_model=list[CategoryResponeWithBooks])
async def get_teacherAndStudent():
    categorys = db.query(CATEGORY).all()
    if not categorys:
        raise HTTPException(status_code=404, detail="Category not found...!")
    return categorys

@app.delete("/category/{id}delete_categorybyid", tags= ["CATEGORY"])
async def delete_category_byid(category_id : str):
    category = db.query(CATEGORY).filter(CATEGORY.id == category_id).first()
    if not category:
        raise HTTPException(status_code= 404, detail= "Category not found...!")
    else:
        db.delete(category)
        db.commit()
        db.refresh(category)
        return f"Category id : {category_id} is deleted...!"
    
@app.put("/category{id}update_categorybyid", tags= ["CATEGORY"])
async def update_category_byid(category_id : str, categoryModel : CategoryModel = Depends(CategoryModel.form)):
    category_update = db.query(CATEGORY).filter(CATEGORY.id == category_id).first()
    if not category_update:
        raise HTTPException(status_code= 404, detail= "Category not fount...!")
    else:
        setattr(category_update, "category_name", categoryModel.category_name)
        db.commit()
        db.refresh(category_update)
        return{"message" : f"{categoryModel} is updated...!"}