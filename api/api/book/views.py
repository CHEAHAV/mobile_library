from fastapi import Depends, HTTPException
from api.book.models import BOOK
from api.book.schemas import BookModel, BookRespone
from core.db import db
from main import app
import os
from fastapi.responses import FileResponse


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
async def get_book(book_id: int):
    book = db.query(BOOK).filter(BOOK.id == book_id).first()
    if not book:
        raise HTTPException(status_code=404, detail="Book not found!")
    return book

@app.get("/book/{book_id}/download", tags=["BOOK"])
async def download_book(book_id: int):
    book = db.query(BOOK).filter(BOOK.id == book_id).first()
    if not book:
        raise HTTPException(status_code=404, detail="Book not found!")
    
    file_path = os.path.join("uploads/book_pdfs", str(book.file_path))
    if not os.path.exists(file_path):
        raise HTTPException(status_code=404, detail="PDF file not found!")
    
    return FileResponse(
        path=file_path,
        media_type="application/pdf",
        filename=str(book.file_path)
    )

@app.delete("/book/{book_id}", tags=["BOOK"])
async def delete_book_byid(book_id: int):
    book = db.query(BOOK).filter(BOOK.id == book_id).first()
    if not book:
        raise HTTPException(status_code=404, detail="Book not found...!")
    
    # delete cover image file
    cover_path = os.path.join("uploads/book_pictures", str(book.cover_image))
    if os.path.exists(cover_path):
        os.remove(cover_path)

    # delete pdf file
    pdf_path = os.path.join("uploads/book_pdfs", str(book.file_path))
    if os.path.exists(pdf_path):
        os.remove(pdf_path)

    db.delete(book)
    db.commit()
    return {"message": f"Book id: {book_id} is deleted!"}

@app.put("/book/{book_id}", tags=["BOOK"])
async def update_book_byid(book_id: int, bookModel: BookModel = Depends(BookModel.form)):
    book_update = db.query(BOOK).filter(BOOK.id == book_id).first()
    if not book_update:
        raise HTTPException(status_code=404, detail="Book not found...!")

    # deletes old files and saves new ones
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
    return {"message": f"Book id: {book_id} updated successfully!"}