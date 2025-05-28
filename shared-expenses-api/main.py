from fastapi import FastAPI, Depends, HTTPException
import os
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.sql import text
from typing import AsyncGenerator

# Database URL from environment variable
DATABASE_URL = os.getenv("DATABASE_URL")

if not DATABASE_URL:
    raise RuntimeError("DATABASE_URL environment variable not set")

# Create an async engine instance
engine = create_async_engine(DATABASE_URL, echo=True)

app = FastAPI()

# Dependency to get an AsyncSession
async def get_db_session() -> AsyncGenerator[AsyncSession, None]:
    async with AsyncSession(engine) as session:
        try:
            yield session
        except Exception:
            await session.rollback()
            raise
        finally:
            await session.close()

@app.get("/")
def read_root():
    return {"message": "Bienvenido al backend de gestión de gastos"}

@app.get("/db-check")
async def db_check(session: AsyncSession = Depends(get_db_session)):
    try:
        # Execute a simple query to check the connection
        result = await session.execute(text("SELECT 1"))
        if result.scalar_one() == 1:
            return {"message": "Database connection successful!"}
        else:
            # This case should ideally not be reached if the query is just "SELECT 1"
            raise HTTPException(status_code=500, detail="Database connection check failed: Unexpected result from SELECT 1")
    except Exception as e:
        # Log the exception for debugging if you have a logger setup
        # logger.error(f"Database connection error: {e}")
        raise HTTPException(status_code=500, detail=f"Database connection failed: {str(e)}")
