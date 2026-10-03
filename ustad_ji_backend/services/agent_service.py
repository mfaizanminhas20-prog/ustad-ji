"""
Agent Service — AI worker auto-bid simulation.
"""

from typing import Dict, Any


def generate_auto_bid(
    estimated_price: Dict[str, Any],
    worker_name: str = "Ali AC Services",
    min_profit_margin: float = 0.10,
) -> Dict[str, Any]:
    """
    Automatically generate a worker bid from an estimated price.

    Strategy:
      - If match found → bid 5% below baseline (competitive but profitable).
      - If no match  → ignore (agent doesn't take unknown jobs).
    """
    matched = estimated_price.get("matched", False)
    baseline = estimated_price.get("baseline_price", 0)

    if not matched:
        return {
            "worker_name": worker_name,
            "status": "ignored",
            "bid_amount": None,
            "reason": "No confident price estimate — skipping job.",
        }

    bid_amount = int(round(baseline * 0.95))

    return {
        "worker_name": worker_name,
        "status": "bid_placed",
        "bid_amount": bid_amount,
        "reason": (
            f"Agent matched category '{estimated_price.get('category')}' "
            f"and placed a competitive bid {baseline - bid_amount} PKR under baseline."
        ),
    }