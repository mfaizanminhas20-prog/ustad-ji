"""
Pydantic schemas for Ustad Ji API.
"""

from pydantic import BaseModel, Field
from typing import Optional


class JobRequest(BaseModel):
    description: str = Field(
        ...,
        min_length=3,
        description="Natural language description of the problem.",
        examples=["My AC is leaking water"],
    )


class EstimatedPrice(BaseModel):
    matched: bool
    category: str
    baseline_price: int
    currency: str = "PKR"
    matched_keyword: Optional[str] = None
    message: str


class WorkerBid(BaseModel):
    worker_name: str
    status: str
    bid_amount: Optional[int] = None
    reason: str


class JobResponse(BaseModel):
    description: str
    estimated_price: EstimatedPrice
    worker_bid: WorkerBid