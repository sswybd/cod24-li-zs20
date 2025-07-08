"""Database configuration and session management."""

from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from functools import wraps
from typing import Callable, Any

from .config import settings

engine = create_engine(settings.database_url, connect_args={"check_same_thread": False})
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()


def get_db():
    """Dependency to get database session."""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


def with_transaction(func: Callable) -> Callable:
    """Decorator for transaction management."""
    @wraps(func)
    def wrapper(*args, **kwargs) -> Any:
        db = SessionLocal()
        try:
            result = func(db, *args, **kwargs)
            db.commit()
            return result
        except Exception as e:
            db.rollback()
            raise e
        finally:
            db.close()
    return wrapper