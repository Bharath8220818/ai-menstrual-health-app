"""ML-powered product recommendation service with live product APIs."""

from __future__ import annotations

import json
import os
from typing import Any, Dict, List
from urllib.parse import urlencode, urlparse
from urllib.request import Request, urlopen

from ai_model.product_category_recommender import ProductCategoryRecommender


RECOMMENDATION_DISCLAIMER = (
    "This app suggests products. Purchases are made externally."
)

_CATEGORY_DISPLAY = {
    "pads": "Pads",
    "menstrual_cups": "Menstrual Cups",
    "femi_wash": "Femi-wash",
    "pain_relief": "Pain Relief Products",
    "pregnancy_supplements": "Pregnancy Supplements",
}

_CATEGORY_QUERY = {
    "pads": "best sanitary pads for women",
    "menstrual_cups": "best menstrual cup women",
    "femi_wash": "intimate femi wash women",
    "pain_relief": "period pain relief products women",
    "pregnancy_supplements": "prenatal pregnancy supplements folic acid",
}

_FALLBACK_PRODUCTS: Dict[str, List[Dict[str, str]]] = {
    "pads": [
        {
            "name": "Whisper Ultra Clean Sanitary Pads",
            "price": "Price unavailable",
            "link": "https://www.amazon.com/s?k=whisper+ultra+clean+sanitary+pads",
            "image": "https://via.placeholder.com/640x360.png?text=Sanitary+Pads",
        },
        {
            "name": "Stayfree Dry Max Pads",
            "price": "Price unavailable",
            "link": "https://www.flipkart.com/search?q=stayfree+dry+max+pads",
            "image": "https://via.placeholder.com/640x360.png?text=Pads",
        },
    ],
    "menstrual_cups": [
        {
            "name": "Sirona Reusable Menstrual Cup",
            "price": "Price unavailable",
            "link": "https://www.amazon.com/s?k=sirona+menstrual+cup",
            "image": "https://via.placeholder.com/640x360.png?text=Menstrual+Cup",
        },
        {
            "name": "Pee Safe Menstrual Cup",
            "price": "Price unavailable",
            "link": "https://www.flipkart.com/search?q=pee+safe+menstrual+cup",
            "image": "https://via.placeholder.com/640x360.png?text=Cup",
        },
    ],
    "femi_wash": [
        {
            "name": "VWash Plus Intimate Hygiene Wash",
            "price": "Price unavailable",
            "link": "https://www.amazon.com/s?k=vwash+intimate+wash",
            "image": "https://via.placeholder.com/640x360.png?text=Femi+Wash",
        },
        {
            "name": "Sirona Intimate Wash",
            "price": "Price unavailable",
            "link": "https://www.flipkart.com/search?q=sirona+intimate+wash",
            "image": "https://via.placeholder.com/640x360.png?text=Intimate+Wash",
        },
    ],
    "pain_relief": [
        {
            "name": "Heating Pad for Menstrual Cramps",
            "price": "Price unavailable",
            "link": "https://www.amazon.com/s?k=heating+pad+period+pain",
            "image": "https://via.placeholder.com/640x360.png?text=Pain+Relief",
        },
        {
            "name": "Meftal-Spas (Consult Doctor)",
            "price": "Price unavailable",
            "link": "https://pharmeasy.in/search/all?name=meftal%20spas",
            "image": "https://via.placeholder.com/640x360.png?text=Pain+Support",
        },
    ],
    "pregnancy_supplements": [
        {
            "name": "Prenatal Multivitamin Supplement",
            "price": "Price unavailable",
            "link": "https://www.amazon.com/s?k=prenatal+multivitamin",
            "image": "https://via.placeholder.com/640x360.png?text=Prenatal+Supplement",
        },
        {
            "name": "Folic Acid + Iron Supplement",
            "price": "Price unavailable",
            "link": "https://www.flipkart.com/search?q=folic+acid+iron+supplement",
            "image": "https://via.placeholder.com/640x360.png?text=Folic+Acid+Iron",
        },
    ],
}


_MODEL = ProductCategoryRecommender()


def recommend_products(payload: Dict[str, Any]) -> Dict[str, Any]:
    cycle_phase = _normalize_cycle_phase(payload.get("cycle_phase"))
    flow_level = _normalize_flow_level(payload.get("flow_level"))
    pain_level = _normalize_pain_level(payload.get("pain_level"))
    pregnancy_status = bool(payload.get("pregnancy_status", False))
    max_results = _safe_int(payload.get("max_results"), default=5, min_value=1, max_value=10)

    category_key = _MODEL.predict_category(
        cycle_phase=cycle_phase,
        flow_level=flow_level,
        pain_level=pain_level,
        pregnancy_status=pregnancy_status,
    )

    live_products = _fetch_live_products(category_key=category_key, limit=max_results)
    products = _merge_with_fallback(
        live_products=live_products,
        fallback_products=_FALLBACK_PRODUCTS.get(category_key, []),
        limit=max_results,
    )
    if len(products) < max_results:
        products.extend(
            _build_generic_fillers(
                category_key=category_key,
                existing_products=products,
                limit=max_results - len(products),
            )
        )

    return {
        "category": _CATEGORY_DISPLAY.get(category_key, "Pads"),
        "products": products,
        "disclaimer": RECOMMENDATION_DISCLAIMER,
    }


def _fetch_live_products(*, category_key: str, limit: int) -> List[Dict[str, str]]:
    provider = os.getenv("PRODUCT_API_PROVIDER", "serpapi").strip().lower()

    if provider == "rapidapi":
        products = _fetch_from_rapidapi(category_key=category_key, limit=limit)
        if products:
            return products
        return _fetch_from_serpapi(category_key=category_key, limit=limit)

    products = _fetch_from_serpapi(category_key=category_key, limit=limit)
    if products:
        return products
    return _fetch_from_rapidapi(category_key=category_key, limit=limit)


def _fetch_from_serpapi(*, category_key: str, limit: int) -> List[Dict[str, str]]:
    api_key = os.getenv("SERPAPI_API_KEY", "").strip()
    if not api_key:
        return []

    query = _CATEGORY_QUERY.get(category_key, _CATEGORY_QUERY["pads"])
    params = {
        "engine": "google_shopping",
        "q": query,
        "api_key": api_key,
        "gl": os.getenv("PRODUCT_SEARCH_COUNTRY", "us"),
        "hl": os.getenv("PRODUCT_SEARCH_LANGUAGE", "en"),
        "num": str(max(limit * 2, 8)),
    }
    url = f"https://serpapi.com/search.json?{urlencode(params)}"

    payload = _http_get_json(url=url, headers={})
    if not isinstance(payload, dict):
        return []

    raw_items = payload.get("shopping_results")
    if not isinstance(raw_items, list):
        raw_items = payload.get("organic_results")
    if not isinstance(raw_items, list):
        raw_items = []

    return _normalize_product_items(raw_items, limit=limit)


def _fetch_from_rapidapi(*, category_key: str, limit: int) -> List[Dict[str, str]]:
    api_key = os.getenv("RAPIDAPI_KEY", "").strip()
    endpoint = os.getenv(
        "RAPIDAPI_ENDPOINT",
        "https://real-time-product-search.p.rapidapi.com/search",
    ).strip()
    host = os.getenv("RAPIDAPI_HOST", "").strip()

    if not api_key or not endpoint:
        return []

    parsed_url = urlparse(endpoint)
    if not host:
        host = parsed_url.netloc
    if not host:
        return []

    query = _CATEGORY_QUERY.get(category_key, _CATEGORY_QUERY["pads"])
    params = {
        "q": query,
        "country": os.getenv("PRODUCT_SEARCH_COUNTRY", "us"),
        "language": os.getenv("PRODUCT_SEARCH_LANGUAGE", "en"),
        "limit": str(max(limit * 2, 8)),
    }
    separator = "&" if "?" in endpoint else "?"
    url = f"{endpoint}{separator}{urlencode(params)}"

    headers = {
        "x-rapidapi-key": api_key,
        "x-rapidapi-host": host,
    }
    payload = _http_get_json(url=url, headers=headers)
    if not isinstance(payload, dict):
        return []

    candidates = _extract_candidate_items(payload)
    return _normalize_product_items(candidates, limit=limit)


def _http_get_json(url: str, headers: Dict[str, str], timeout_sec: int = 8) -> Any:
    try:
        request = Request(url=url, headers=headers)
        with urlopen(request, timeout=timeout_sec) as response:
            body = response.read().decode("utf-8", errors="ignore")
        return json.loads(body)
    except Exception:
        return {}


def _extract_candidate_items(payload: Dict[str, Any]) -> List[Dict[str, Any]]:
    possible_items: List[Any] = []
    for key in ("products", "results", "items", "shopping_results", "data"):
        value = payload.get(key)
        if isinstance(value, list):
            possible_items.extend(value)
        elif isinstance(value, dict):
            for nested_key in ("products", "results", "items", "shopping_results"):
                nested_value = value.get(nested_key)
                if isinstance(nested_value, list):
                    possible_items.extend(nested_value)

    cleaned: List[Dict[str, Any]] = []
    for item in possible_items:
        if isinstance(item, dict):
            cleaned.append(item)
    return cleaned


def _normalize_product_items(
    items: List[Dict[str, Any]], *, limit: int
) -> List[Dict[str, str]]:
    normalized: List[Dict[str, str]] = []
    seen_names: set[str] = set()

    for item in items:
        name = _first_non_empty(
            item.get("title"),
            item.get("name"),
            item.get("product_title"),
        )
        link = _first_non_empty(
            item.get("product_link"),
            item.get("link"),
            item.get("product_url"),
            item.get("url"),
            item.get("serpapi_link"),
        )
        image = _first_non_empty(
            item.get("thumbnail"),
            item.get("image"),
            item.get("image_url"),
            item.get("product_photo"),
            item.get("photo"),
        )
        price = _format_price(
            _first_non_empty(
                item.get("price"),
                item.get("price_string"),
                item.get("offer_price"),
                item.get("current_price"),
                item.get("extracted_price"),
            )
        )

        if not name or not link:
            continue

        key = name.lower().strip()
        if key in seen_names:
            continue
        seen_names.add(key)

        normalized.append(
            {
                "name": name,
                "price": price,
                "link": link,
                "image": image or "https://via.placeholder.com/640x360.png?text=Product",
            }
        )
        if len(normalized) >= limit:
            break

    return normalized


def _merge_with_fallback(
    *,
    live_products: List[Dict[str, str]],
    fallback_products: List[Dict[str, str]],
    limit: int,
) -> List[Dict[str, str]]:
    merged: List[Dict[str, str]] = []
    seen_names: set[str] = set()

    for item in live_products + fallback_products:
        name = str(item.get("name", "")).strip()
        link = str(item.get("link", "")).strip()
        if not name:
            continue
        if not link:
            continue
        key = name.lower()
        if key in seen_names:
            continue
        seen_names.add(key)
        merged.append(
            {
                "name": name,
                "price": _format_price(item.get("price")),
                "link": link,
                "image": str(item.get("image", "")).strip()
                or "https://via.placeholder.com/640x360.png?text=Product",
            }
        )
        if len(merged) >= limit:
            break
    return merged


def _build_generic_fillers(
    *,
    category_key: str,
    existing_products: List[Dict[str, str]],
    limit: int,
) -> List[Dict[str, str]]:
    if limit <= 0:
        return []

    existing_names = {str(item.get("name", "")).strip().lower() for item in existing_products}
    query = _CATEGORY_QUERY.get(category_key, _CATEGORY_QUERY["pads"])
    display = _CATEGORY_DISPLAY.get(category_key, "Products")
    fillers: List[Dict[str, str]] = []

    for index in range(1, limit + 3):
        name = f"Explore {display} Option {index}"
        key = name.lower()
        if key in existing_names:
            continue
        existing_names.add(key)
        search_link = f"https://www.google.com/search?tbm=shop&{urlencode({'q': query})}"
        fillers.append(
            {
                "name": name,
                "price": "See latest price",
                "link": search_link,
                "image": f"https://via.placeholder.com/640x360.png?text={display.replace(' ', '+')}",
            }
        )
        if len(fillers) >= limit:
            break
    return fillers


def _format_price(value: Any) -> str:
    if value is None:
        return "Price unavailable"
    if isinstance(value, (int, float)):
        return f"${float(value):.2f}"
    text = str(value).strip()
    return text or "Price unavailable"


def _first_non_empty(*values: Any) -> str:
    for value in values:
        if value is None:
            continue
        text = str(value).strip()
        if text:
            return text
    return ""


def _normalize_cycle_phase(value: Any) -> str:
    text = str(value or "").strip().lower()
    if "men" in text or "period" in text:
        return "menstrual"
    if "fol" in text:
        return "follicular"
    if "ovu" in text or "fert" in text:
        return "ovulation"
    if "lut" in text or "pre" in text:
        return "luteal"
    return "menstrual"


def _normalize_flow_level(value: Any) -> str:
    if isinstance(value, (int, float)):
        if value <= 0:
            return "spotting"
        if value <= 2:
            return "light"
        if value <= 3:
            return "medium"
        return "heavy"

    text = str(value or "").strip().lower()
    if "heavy" in text:
        return "heavy"
    if "spot" in text:
        return "spotting"
    if "light" in text:
        return "light"
    if "med" in text:
        return "medium"
    return "medium"


def _normalize_pain_level(value: Any) -> float:
    if isinstance(value, (int, float)):
        return _clamp(float(value), 0.0, 10.0)

    text = str(value or "").strip().lower()
    if "severe" in text or "high" in text:
        return 8.0
    if "med" in text:
        return 5.0
    if "low" in text or "mild" in text:
        return 3.0
    if "none" in text:
        return 0.0

    try:
        return _clamp(float(text), 0.0, 10.0)
    except Exception:
        return 0.0


def _safe_int(value: Any, *, default: int, min_value: int, max_value: int) -> int:
    try:
        parsed = int(value)
    except Exception:
        parsed = default
    return max(min_value, min(max_value, parsed))


def _clamp(value: float, low: float, high: float) -> float:
    return max(low, min(high, value))
