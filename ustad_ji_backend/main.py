"""
Ustad Ji — FastAPI backend with SQLite persistence.
"""

from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from database import create_db_and_tables
from routers.jobs import router as jobs_router
from routers.api import router as api_router


@asynccontextmanager
async def lifespan(app: FastAPI):
    create_db_and_tables()
    print("[Ustad Ji] Database ready.", flush=True)
    yield


app = FastAPI(
    title="Ustad Ji API",
    description="AI labor marketplace backend with SQLite persistence.",
    version="2.0.0",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(jobs_router)
app.include_router(api_router)


@app.get("/")
def root():
    return {
        "service": "Ustad Ji API",
        "version": "2.0.0",
        "status": "running",
        "docs": "/docs",
        "db": "/api/health/db",
    }


@app.get("/health")
def health():
    return {"status": "ok"}


if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)