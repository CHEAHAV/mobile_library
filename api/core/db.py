from sqlalchemy.orm import declarative_base, sessionmaker
from sqlalchemy import create_engine
from config import configs
import time

Base = declarative_base()

def create_engine_with_retry(retries=5, delay=3):
    for i in range(retries):
        try:
            engine = create_engine(
                configs.DATABASE_URL,
                pool_timeout=30,
                pool_pre_ping=True
            )
            engine.connect()
            print("Database connected successfully")
            return engine
        except Exception as e:
            print(f"DB connection failed ({i+1}/{retries}): {e}")
            time.sleep(delay)
    raise Exception("❌ Could not connect to the database after retries")

engine = create_engine_with_retry()
Session = sessionmaker(bind=engine)

def get_db():
    db = Session()
    try:
        yield db
    finally:
        db.close()