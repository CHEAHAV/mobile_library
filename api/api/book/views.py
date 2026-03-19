import os
import io
from pathlib import Path
from typing import cast
import urllib.parse
from fastapi import Depends, HTTPException, Request
from fastapi.responses import Response, StreamingResponse  # ← add StreamingResponse
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError

from api.book.models import BOOK
from api.book.schemas import BookModel, BookResponse, save_file, update_file
from core.db import get_db
from main import app


def download_book(request: Request, filename: str) -> str:
    base = str(request.base_url).rstrip("/")
    return f"{base}/uploads/{filename}"


def _handle_integrity(e: IntegrityError):
    error = str(e.orig).lower()
    if "category_id" in error:
        raise HTTPException(status_code=400, detail="Category ID not found")
    raise HTTPException(status_code=400, detail=f"Database error: {error}")


@app.post("/book/create", tags=["BOOK"])
async def create_book(
    bookModel : BookModel = Depends(BookModel.form),
    db        : Session   = Depends(get_db),
):
    try:
        cover_data    = await bookModel.cover_image.read()
        relative_path = await save_file(bookModel.file_path)

        new_book = BOOK(
            title       = bookModel.title,
            description = bookModel.description,
            author_name = bookModel.author_name,
            rating      = bookModel.rating,
            language    = bookModel.language,
            page        = bookModel.page,
            cover_image = cover_data,
            cover_name  = bookModel.cover_image.filename,
            file_path   = relative_path,
            category_id = bookModel.category_id,
        )
        db.add(new_book)
        db.commit()
        return {"message": "Book created successfully!"}

    except IntegrityError as e:
        db.rollback()
        _handle_integrity(e)


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
    return Response(content=cast(bytes, book.cover_image), media_type="image/jpeg")


@app.get("/book/{book_id}/download", tags=["BOOK"])
async def getdownload_book(book_id: str, request: Request, db: Session = Depends(get_db)):
    book = db.query(BOOK).filter(BOOK.id == book_id).first()
    if not book or book.file_path is None:
        raise HTTPException(status_code=404, detail="PDF not found!")
    return {
        "file_name" : Path(str(book.file_path)).name,
        "file_url"  : download_book(request, str(book.file_path)),
    }


# ── NEW: serve PDF bytes directly (fixes CORS issue with StaticFiles) ─────────
@app.get("/book/{book_id}/pdf", tags=["BOOK"])
async def get_pdf_bytes(book_id: str, db: Session = Depends(get_db)):
    book = db.query(BOOK).filter(BOOK.id == book_id).first()
    if not book or book.file_path is None:
        raise HTTPException(status_code=404, detail="PDF not found!")

    full_path = Path("uploads/file_path") / str(book.file_path)
    if not full_path.exists():
        raise HTTPException(status_code=404, detail="PDF file missing on server!")

    # ← URL-encode the filename so non-ASCII chars (Khmer etc.) don't crash
    encoded_name = urllib.parse.quote(full_path.name)

    return StreamingResponse(
        io.BytesIO(full_path.read_bytes()),
        media_type="application/pdf",
        headers={
            "Content-Disposition": f"inline; filename*=UTF-8''{encoded_name}"
        }
    )
# ──────────────────────────────────────────────────────────────────────────────


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
    if book.file_path is not None:
        full = Path("uploads/file_path") / str(book.file_path)
        if full.exists():
            full.unlink()
    db.delete(book)
    db.commit()
    return {"message": f"Book id: {book_id} deleted successfully!"}


@app.put("/book/{book_id}", tags=["BOOK"])
async def update_book(
    book_id   : str,
    bookModel : BookModel = Depends(BookModel.form),
    db        : Session   = Depends(get_db),
):
    try:
        book = db.query(BOOK).filter(BOOK.id == book_id).first()
        if not book:
            raise HTTPException(status_code=404, detail="Book not found!")

        cover_data    = await bookModel.cover_image.read()
        old_path      = str(book.file_path) if book.file_path is not None else None
        relative_path = await update_file(bookModel.file_path, old_path)

        setattr(book, "title",       bookModel.title)
        setattr(book, "description", bookModel.description)
        setattr(book, "author_name", bookModel.author_name)
        setattr(book, "rating",      bookModel.rating)
        setattr(book, "language",    bookModel.language)
        setattr(book, "page",        bookModel.page)
        setattr(book, "cover_image", cover_data)
        setattr(book, "cover_name",  bookModel.cover_image.filename)
        setattr(book, "file_path",   relative_path)
        setattr(book, "category_id", bookModel.category_id)

        db.commit()
        db.refresh(book)
        return {"message": f"Book ID: {book_id} updated successfully!"}

    except IntegrityError as e:
        db.rollback()
        _handle_integrity(e)