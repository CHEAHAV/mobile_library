from fastapi import Depends, HTTPException
from api.book.models import BOOK
from api.book.schemas import BookModel, BookRespone
from core.db import db
from main import app


@app.post("/book/create", tags=["BOOK"])
async def create_book(bookModel: BookModel = Depends(BookModel.form)):
    save_cover_image = await bookModel.save_cover_image()
    save_pdf = await bookModel.save_pdf()

    new_book = BOOK(
        title=bookModel.title,
        description=bookModel.description,
        author_name = bookModel.author_name,
        rating=bookModel.rating,
        language=bookModel.language,
        page=bookModel.page,
        cover_image=save_cover_image,
        file_path=save_pdf,
        category_id=bookModel.category_id
    )
    db.add(new_book)
    db.commit()
    return {"message": "Book created successfully!"}


@app.get("/book/all", tags=["BOOK"], response_model=list[BookRespone])
async def get_books():
    books = db.query(BOOK).all()
    if not books:
        raise HTTPException(status_code=404, detail="No books found!")
    return books


@app.get("/book/{book_id}", tags=["BOOK"], response_model=BookRespone)
async def get_book(book_id: str):
    book = db.query(BOOK).filter(BOOK.id == book_id).first()
    if not book:
        raise HTTPException(status_code=404, detail="Book not found!")
    return book

@app.delete("/book/{id}delete_bookbyid", tags=["BOOK"])
async def delete_book_byid(book_id : str):
    book = db.query(BOOK).filter(BOOK.id == book_id).first()
    if not book:
        raise HTTPException(status_code= 404, detail= "Book not found...!")
    else:
        db.delete(book)
        db.commit()
        return f"Book id : {book_id} is deleted...!"

@app.put("/book/{id}update_bookbyid", tags= ["BOOK"])
async def update_book_byid(book_id : str, bookModel : BookModel = Depends(BookModel.form)):
    book_update = db.query(BOOK).filter(BOOK.id == book_id).first()
    if not book_update:
        raise HTTPException(status_code= 404, detail= "Book not found...!")
    else:
        update_image = await bookModel.update_cover_image(str(book_update.cover_image))
        update_pdf = await bookModel.update_pdf(str(book_update.file_path))
        
        setattr(book_update, "title", bookModel.title)
        setattr(book_update, "description", bookModel.description)
        setattr(book_update, "author_name", bookModel.author_name)
        setattr(book_update, "rating", bookModel.rating)
        setattr(book_update, "language", bookModel.language)
        setattr(book_update, "page", bookModel.page)
        setattr(book_update, "cover_image", update_image)
        setattr(book_update, "file_path", update_pdf)
        setattr(book_update, "category_id", bookModel.category_id)
        db.commit()
        db.refresh(book_update)
        return{"message" : f"{bookModel} is update...!"}