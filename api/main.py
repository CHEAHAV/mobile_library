from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles

app = FastAPI()

app.mount("/covers", StaticFiles(directory="uploads/book_pictures"), name="covers")
app.mount("/pdfs", StaticFiles(directory="uploads/book_pdfs"), name="pdfs")

from api.register import *