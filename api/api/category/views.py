from fastapi import Depends, HTTPException
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session
from api.category.models import CATEGORY
from api.category.schemas import CategoryModel, CategoryRespone, CategoryResponeWithBooks
from core.db import get_db
from main import app


@app.post("/category/create", tags=["CATEGORY"])
async def create_category(categoryModel: CategoryModel = Depends(CategoryModel.form), db: Session = Depends(get_db)):
    try:
        new_category = CATEGORY(
            id           = categoryModel.id,
            category_name=categoryModel.category_name)
        db.add(new_category)
        db.commit()
        return {"message": f"Category '{categoryModel.category_name}' created successfully!"}
    except IntegrityError as e:
        db.rollback()
        error = str(e.orig).lower()
        if "id" in error:
            raise HTTPException(status_code=400, detail="ID had already please use another ID...!")
        elif "category_name" in error:
            raise HTTPException(status_code=400, detail="Category name must me 3 characters or more...!")


@app.get("/category/all", tags=["CATEGORY"], response_model=list[CategoryRespone])
async def get_all_categories(db: Session = Depends(get_db)):
    categories = db.query(CATEGORY).all()
    if not categories:
        raise HTTPException(status_code=404, detail="No categories found!")
    return categories


@app.get("/category/with-books", tags=["CATEGORY"], response_model=list[CategoryResponeWithBooks])
async def get_categories_with_books(db: Session = Depends(get_db)):
    categories = db.query(CATEGORY).all()
    if not categories:
        raise HTTPException(status_code=404, detail="No categories found!")
    result = [cat for cat in categories if len(cat.books) > 0]
    if not result:
        raise HTTPException(status_code=404, detail="No categories with books found!")
    return result


@app.get("/category/{category_id}", tags=["CATEGORY"], response_model=CategoryRespone)
async def get_category(category_id: str, db: Session = Depends(get_db)):
    category = db.query(CATEGORY).filter(CATEGORY.id == category_id).first()
    if not category:
        raise HTTPException(status_code=404, detail="Category not found!")
    return category


@app.put("/category/{category_id}", tags=["CATEGORY"])
async def update_category(category_id: str, categoryModel: CategoryModel = Depends(CategoryModel.form), db: Session = Depends(get_db)):
    try:
        category = db.query(CATEGORY).filter(CATEGORY.id == category_id).first()
        if not category:
            raise HTTPException(status_code=404, detail="Category not found!")
        setattr(category, "id", categoryModel.id)
        setattr(category, "category_name", categoryModel.category_name)
        db.commit()
        db.refresh(category)
        return {"message": f"Category id: {category_id} updated successfully!"}
    except IntegrityError as e:
        db.rollback()
        error = str(e.orig).lower()
        if "id" in error:
            raise HTTPException(status_code=400, detail="ID had already please use another ID...!")
        elif "category_name" in error:
            raise HTTPException(status_code=400, detail="Category name must me 3 characters or more...!")


@app.delete("/category/{category_id}", tags=["CATEGORY"])
async def delete_category(category_id: str, db: Session = Depends(get_db)):
    category = db.query(CATEGORY).filter(CATEGORY.id == category_id).first()
    if not category:
        raise HTTPException(status_code=404, detail="Category not found!")
    db.delete(category)
    db.commit()
    return {"message": f"Category id: {category_id} deleted successfully!"}