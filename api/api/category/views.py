from fastapi import Depends, HTTPException
from api.category.models import CATEGORY
from api.category.schemas import CategoryModel, CategoryRespone, CategoryResponeWithBooks
from core.db import db
from main import app


@app.post("/category/create", tags=["CATEGORY"])
async def create_category(categoryModel: CategoryModel = Depends(CategoryModel.form)):
    new_category = CATEGORY(category_name=categoryModel.category_name)
    db.add(new_category)
    db.commit()
    return {"message": f"Category '{categoryModel.category_name}' created successfully!"}


@app.get("/category/all", tags=["CATEGORY"], response_model=list[CategoryRespone])
async def get_categories():
    categories = db.query(CATEGORY).all()
    if not categories:
        raise HTTPException(status_code=404, detail="No categories found!")
    return categories


# ✅ only return categories that have books
@app.get("/category/with-books", tags=["CATEGORY"], response_model=list[CategoryResponeWithBooks])
async def get_categories_with_books():
    categories = db.query(CATEGORY).all()
    if not categories:
        raise HTTPException(status_code=404, detail="No categories found!")
    # ✅ filter only categories that have at least 1 book
    result = [cat for cat in categories if len(cat.books) > 0]
    if not result:
        raise HTTPException(status_code=404, detail="No categories with books found!")
    return result


@app.get("/category/{category_id}", tags=["CATEGORY"], response_model=CategoryRespone)
async def get_category(category_id: int):
    category = db.query(CATEGORY).filter(CATEGORY.id == category_id).first()
    if not category:
        raise HTTPException(status_code=404, detail="Category not found!")
    return category


@app.put("/category/{category_id}", tags=["CATEGORY"])
async def update_category(category_id: int, categoryModel: CategoryModel = Depends(CategoryModel.form)):
    category = db.query(CATEGORY).filter(CATEGORY.id == category_id).first()
    if not category:
        raise HTTPException(status_code=404, detail="Category not found!")
    category.category_name = categoryModel.category_name
    db.commit()
    db.refresh(category)
    return {"message": f"Category id: {category_id} updated successfully!"}


@app.delete("/category/{category_id}", tags=["CATEGORY"])
async def delete_category(category_id: int):
    category = db.query(CATEGORY).filter(CATEGORY.id == category_id).first()
    if not category:
        raise HTTPException(status_code=404, detail="Category not found!")
    db.delete(category)
    db.commit()
    return {"message": f"Category id: {category_id} deleted successfully!"}