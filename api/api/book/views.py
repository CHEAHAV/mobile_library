from fastapi import HTTPException, Depends
from fastapi.responses import Response
from api.book.models import BOOK
from api.book.schemas import BookModel, BookRespone
from api.category.models import CATEGORY
from core.db import db
from main import app


@app.post("/book/create", tags=["BOOK"])
async def create_book(bookModel: BookModel = Depends(BookModel.form)):
    cover_data = await bookModel.cover_image.read()
    pdf_data   = await bookModel.file_path.read()
    new_book = BOOK(
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


@app.get("/book/all", tags=["BOOK"], response_model=list[BookRespone])
async def get_books():
    books = db.query(BOOK).all()
    if not books:
        raise HTTPException(status_code=404, detail="No books found!")
    return books


@app.get("/book/{book_id}/cover", tags=["BOOK"])
async def get_cover(book_id: int):
    book = db.query(BOOK).filter(BOOK.id == book_id).first()
    if not book or not book.cover_image is None:
        raise HTTPException(status_code=404, detail="Cover not found!")
    return Response(
        content=bytes(book.cover_image),
        media_type="image/jpeg"   # works for both jpg and png
    )


@app.get("/book/{book_id}/download", tags=["BOOK"])
async def download_book(book_id: int):
    book = db.query(BOOK).filter(BOOK.id == book_id).first()
    if not book or not book.file_path is None:
        raise HTTPException(status_code=404, detail="PDF not found!")
    
    # no Content-Disposition header — avoids Khmer encoding error
    return Response(
        content=bytes(book.file_path),
        media_type="application/pdf"
    )


@app.get("/book/{book_id}", tags=["BOOK"], response_model=BookRespone)
async def get_book(book_id: int):
    book = db.query(BOOK).filter(BOOK.id == book_id).first()
    if not book:
        raise HTTPException(status_code=404, detail="Book not found!")
    return book


@app.delete("/book/{book_id}", tags=["BOOK"])
async def delete_book(book_id: int):
    book = db.query(BOOK).filter(BOOK.id == book_id).first()
    if not book:
        raise HTTPException(status_code=404, detail="Book not found!")
    db.delete(book)
    db.commit()
    return {"message": f"Book id: {book_id} deleted successfully!"}


@app.put("/book/{book_id}", tags=["BOOK"])
async def update_book(book_id: int, bookModel: BookModel = Depends(BookModel.form)):
    book = db.query(BOOK).filter(BOOK.id == book_id).first()
    if not book:
        raise HTTPException(status_code=404, detail="Book not found!")
    cover_data = await bookModel.cover_image.read()
    pdf_data   = await bookModel.file_path.read()
    setattr(book, "title", bookModel.title)
    setattr(book, "description", bookModel.description)
    setattr(book, "author_name", bookModel.author_name)
    setattr(book, "rating", bookModel.rating)
    setattr(book, "language", bookModel.language)
    setattr(book, "page", bookModel.page)
    setattr(book, "cover_image", cover_data)
    setattr(book, "file_path", pdf_data)
    setattr(book, "cover_name",bookModel.cover_image.filename)
    setattr(book, "file_name", bookModel.file_path.filename)
    setattr(book, "category_id", bookModel.category_id)
    db.commit()
    db.refresh(book)
    return {"message": f"Book title: {bookModel.title} updated successfully!"}