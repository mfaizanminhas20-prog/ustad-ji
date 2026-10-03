"""
Jobs Router — POST /post-job endpoint.
"""

from fastapi import APIRouter, HTTPException

from models.schemas import JobRequest, JobResponse
from services.rag_service import estimate_service_price
from services.agent_service import generate_auto_bid


router = APIRouter(tags=["Jobs"])


@router.post("/post-job", response_model=JobResponse)
def post_job(payload: JobRequest):
    """Estimate price for a job and get an AI worker's auto-bid."""
    try:
        estimated = estimate_service_price(payload.description)
        bid = generate_auto_bid(estimated)

        return {
            "description": payload.description,
            "estimated_price": estimated,
            "worker_bid": bid,
        }
    except Exception as exc:
        raise HTTPException(status_code=500, detail=f"Job processing failed: {exc}")