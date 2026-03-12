from fastapi import FastAPI
from fastapi.responses import RedirectResponse
from fastapi.middleware.cors import CORSMiddleware
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

@app.get("/", tags=[""])
def root():
    return RedirectResponse(url="/docs")