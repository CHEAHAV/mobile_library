from typing import cast

from fastapi import HTTPException, Depends
from fastapi.responses import Response
from sqlalchemy.orm import Session
from api.book.models import BOOK
from api.book.schemas import BookModel, BookResponse
from core.db import get_db
from main import app
from sqlalchemy.exc import IntegrityError


@app.post("/book/create", tags=["BOOK"])
async def create_book(bookModel: BookModel = Depends(BookModel.form), db: Session = Depends(get_db)):
    try:
        cover_data = await bookModel.cover_image.read()
        pdf_data   = await bookModel.file_path.read()
        new_book = BOOK(
            id          = bookModel.id,
            title       = bookModel.title,
            description = bookModel.description,
            author_name = bookModel.author_name,
            rating      = bookModel.rating,
            language    = bookModel.language,
            page        = bookModel.page,
            cover_image = cover_data,
            file_path   = pdf_data,
            cover_name  = bookModel.cover_image.filename,
            file_name   = bookModel.file_path.filename,
            category_id = bookModel.category_id
        )
        db.add(new_book)
        db.commit()
        return {"message": "Book created successfully!"}
    except IntegrityError as e:
        db.rollback()
        error = str(e.orig).lower()
        if "id" in error:
            raise HTTPException(status_code=400, detail="ID had already please use another ID...!")
        elif "file_path" in error:
            raise HTTPException(status_code=400, detail="File path had already please use another file...!")
        elif "cover_image" in error:
            raise HTTPException(status_code=400, detail="cover image had already please use another cover image...!")
        elif "rating"  in error:
            raise HTTPException(status_code=400, detail="Rating must be between 0 and 5")
        elif "page"  in error:
            raise HTTPException(status_code=400, detail="Page count must be greater than 0")
        elif "category_id" in error:
            raise HTTPException(status_code=400, detail="Category ID not found")
        else:
            raise HTTPException(status_code=400, detail=f"Database error: {error}")

@app.get("/book/all", tags=["BOOK"], response_model=list[BookResponse])
async def get_all_books(db: Session = Depends(get_db)):
    books = db.query(BOOK).all()
    if not books:
        raise HTTPException(status_code=404, detail="No books found!")
    return books


@app.get("/book/{book_id}/cover", tags=["BOOK"])
async def get_cover(book_id: str, db: Session = Depends(get_db)):
    book = db.query(BOOK).filter(BOOK.id == book_id).first()
    if not book or book.cover_image is None:
        raise HTTPException(status_code=404, detail="Cover not found!")
    return Response(
        content=cast(bytes, book.cover_image),
        media_type="image/jpeg"
    )


@app.get("/book/{book_id}/download", tags=["BOOK"])
async def download_book(book_id: str, db: Session = Depends(get_db)):
    book = db.query(BOOK).filter(BOOK.id == book_id).first()
    if not book or book.file_path is None:
        raise HTTPException(status_code=404, detail="PDF not found!")
    return Response(
        content=cast(bytes, book.file_path),
        media_type="application/pdf"
    )


@app.get("/book/{book_id}", tags=["BOOK"], response_model=BookResponse)
async def get_book(book_id: str, db: Session = Depends(get_db)):
    book = db.query(BOOK).filter(BOOK.id == book_id).first()
    if not book:
        raise HTTPException(status_code=404, detail="Book not found!")
    return book


@app.delete("/book/{book_id}", tags=["BOOK"])
async def delete_book(book_id: str, db: Session = Depends(get_db)):
    book = db.query(BOOK).filter(BOOK.id == book_id).first()
    if not book:
        raise HTTPException(status_code=404, detail="Book not found!")
    db.delete(book)
    db.commit()
    return {"message": f"Book id: {book_id} deleted successfully!"}


@app.put("/book/{book_id}", tags=["BOOK"])
async def update_book(book_id: str, bookModel: BookModel = Depends(BookModel.form), db: Session = Depends(get_db)):
    try:
        book = db.query(BOOK).filter(BOOK.id == book_id).first()
        if not book:
            raise HTTPException(status_code=404, detail="Book not found!")
        cover_data = await bookModel.cover_image.read()
        pdf_data   = await bookModel.file_path.read()
        setattr(book, "id", bookModel.id)
        setattr(book, "title", bookModel.title)
        setattr(book, "description", bookModel.description)
        setattr(book, "author_name", bookModel.author_name)
        setattr(book, "rating", bookModel.rating)
        setattr(book, "language", bookModel.language)
        setattr(book, "page", bookModel.page)
        setattr(book, "cover_image", cover_data)
        setattr(book, "file_path", pdf_data)
        setattr(book, "cover_name", bookModel.cover_image.filename)
        setattr(book, "file_name", bookModel.file_path.filename)
        setattr(book, "category_id", bookModel.category_id)
        db.commit()
        db.refresh(book)
        return {"message": f"Book title: {bookModel.title} updated successfully!"}
    except IntegrityError as e:
        db.rollback()
        error = str(e.orig).lower()
        if "id" in error:
            raise HTTPException(status_code=400, detail="ID had already please use another ID...!")
        elif "file_path" in error:
            raise HTTPException(status_code=400, detail="File path had already please use another file...!")
        elif "cover_image" in error:
            raise HTTPException(status_code=400, detail="Cover image had already please use another cover image")
        elif "rating"  in error:
            raise HTTPException(status_code=400, detail="Rating must be between 0 and 5")
        elif "page"  in error:
            raise HTTPException(status_code=400, detail="Page count must be greater than 0")
        elif "category_id" in error:
            raise HTTPException(status_code=400, detail="Category ID not found")
        else:
            raise HTTPException(status_code=400, detail=f"Database error: {error}")