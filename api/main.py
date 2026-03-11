from fastapi import FastAPI
from fastapi.responses import RedirectResponse

app = FastAPI()

from api.register import *

@app.get("/", tags= [""])
def root():
    return RedirectResponse(url="/docs")