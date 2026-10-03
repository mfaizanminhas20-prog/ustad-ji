"""
RAG Service — mock knowledge base for repair price estimation.
"""

import re
from typing import Dict, Any, List, Tuple


MOCK_REPAIR_DB: List[Dict[str, Any]] = [
    {
        "keywords": ["ac leaking", "ac leak", "ac water", "air conditioner leak", "ac dripping"],
        "price": 1500,
        "category": "AC Repair",
    },
    {
        "keywords": ["ac not cooling", "ac broken", "ac repair", "air conditioner"],
        "price": 2000,
        "category": "AC Repair",
    },
    {
        "keywords": ["pipe broken", "broken pipe", "pipe leak", "water pipe", "leaking pipe"],
        "price": 800,
        "category": "Plumbing",
    },
    {
        "keywords": ["tap leaking", "faucet leak", "tap drip", "water tap"],
        "price": 400,
        "category": "Plumbing",
    },
    {
        "keywords": ["short circuit", "short-circuit", "electric short", "wiring", "spark"],
        "price": 1200,
        "category": "Electrical",
    },
    {
        "keywords": ["switch board", "socket", "plug point", "switch repair"],
        "price": 500,
        "category": "Electrical",
    },
    {
        "keywords": ["fan not working", "fan broken", "ceiling fan"],
        "price": 600,
        "category": "Fan Repair",
    },
    {
        "keywords": ["geyser", "water heater"],
        "price": 2000,
        "category": "Geyser Repair",
    },
    {
        "keywords": ["fridge", "refrigerator", "fridge not cooling"],
        "price": 2500,
        "category": "Refrigerator Repair",
    },
    {
        "keywords": ["washing machine", "washer", "machine not spinning"],
        "price": 1800,
        "category": "Washing Machine Repair",
    },
    {
        "keywords": ["door lock", "lock broken", "lock repair"],
        "price": 700,
        "category": "Carpentry",
    },
]


DEFAULT_RESPONSE: Dict[str, Any] = {
    "matched": False,
    "category": "General Service",
    "baseline_price": 1000,
    "currency": "PKR",
    "matched_keyword": None,
    "message": "No exact match. A technician will confirm the price on-site.",
}


def _normalize(text: str) -> str:
    return re.sub(r"\s+", " ", text.lower().strip())


def estimate_service_price(problem_description: str) -> Dict[str, Any]:
    """Match free-text description against mock DB and return baseline price."""
    if not problem_description or not isinstance(problem_description, str):
        return {**DEFAULT_RESPONSE, "message": "Empty or invalid description."}

    normalized_input = _normalize(problem_description)
    best: Tuple[int, Dict[str, Any] | None, str] = (0, None, "")

    for entry in MOCK_REPAIR_DB:
        for keyword in entry["keywords"]:
            nk = _normalize(keyword)
            if nk in normalized_input:
                score = len(nk.split())
                if score > best[0]:
                    best = (score, entry, keyword)

    score, entry, matched_keyword = best
    if entry is None:
        return DEFAULT_RESPONSE

    return {
        "matched": True,
        "category": entry["category"],
        "baseline_price": entry["price"],
        "currency": "PKR",
        "matched_keyword": matched_keyword,
        "message": f"Estimated baseline price for {entry['category']}.",
    }