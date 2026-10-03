"""
Ustad Ji — FastAPI backend entrypoint.
"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from routers.jobs import router as jobs_router


app = FastAPI(
    title="Ustad Ji API",
    description="AI labor marketplace backend for the Ustad Ji hackathon MVP.",
    version="1.0.0",
)

# CORS — allow everything for the hackathon
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Register routers
app.include_router(jobs_router)


@app.get("/")
def root():
    return {
        "service": "Ustad Ji API",
        "status": "running",
        "docs": "/docs",
    }


@app.get("/health")
def health():
    return {"status": "ok"}


if __name__ == "__main__":
    import uvicorn

    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)