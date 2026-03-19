import os

from fastapi import FastAPI
from fastapi.responses import HTMLResponse, RedirectResponse
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from core.db import Base, engine

# import models first so SQLalchemy registers them
from api.book.models import BOOK
from api.category.models import CATEGORY
from api.user.models import USER

# create tables before routes are loaded
Base.metadata.create_all(bind=engine)

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

from api.register import *


os.makedirs("uploads/file_path", exist_ok=True)
app.mount("/uploads", StaticFiles(directory="uploads"), name="uploads")  # added missing mount

# @app.get("/", tags=[""])
# def root():
#     return RedirectResponse(url="/docs")

@app.get("/", response_class=HTMLResponse, tags=[""])
async def home_page():
    html = """
        <center>
            <h1>Welcome To Library API</h1>
            <p><a href="/docs">Visit Backend API Document</a></p>
        </center>
    """
    return HTMLResponse(content=html, status_code=200)