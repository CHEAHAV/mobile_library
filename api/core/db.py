from sqlalchemy.orm import declarative_base, sessionmaker
from sqlalchemy import create_engine
from config import configs

Base = declarative_base()

engine = create_engine(
    configs.DATABASE_URL,
    pool_timeout=30,
    pool_pre_ping=True
)

Session = sessionmaker(bind = engine)
db = Session()