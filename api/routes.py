from fastapi import APIRouter, HTTPException, Query
from api.schemas import (
    BasePredict,
    RecommendInput,
    RecommendProductsInput,
    RecommendProductsResponse,
    ChatInput,
    CalculateHealthInput,
)
from api import services

router = APIRouter()


@router.get("/health")
async def get_health():
    return {
        "status": "ok",
        "service": "menstrual-health-ai-api",
        "version": "2.0.0",
        "features": ["cycle-tracking", "fertility", "pregnancy", "nutrition", "alerts", "notifications", "mental-health", "product-recommendations"]
    }


@router.post("/predict/cycle")
async def post_predict_cycle(payload: BasePredict):
    try:
        return services.predict_cycle(payload.dict(exclude_none=True))
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc))


@router.post("/predict/irregular")
async def post_predict_irregular(payload: BasePredict):
    try:
        return services.predict_irregular(payload.dict(exclude_none=True))
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc))


@router.post("/predict/fertility")
async def post_predict_fertility(payload: BasePredict):
    try:
        return services.predict_fertility(payload.dict(exclude_none=True))
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc))


@router.post("/predict")
async def post_predict(payload: BasePredict):
    try:
        return services.predict_all(payload.dict(exclude_none=True))
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc))


@router.post("/recommend")
async def post_recommend(payload: RecommendInput):
    try:
        return services.recommend(payload.dict(exclude_none=True))
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc))


@router.post("/recommend-products", response_model=RecommendProductsResponse)
async def post_recommend_products(payload: RecommendProductsInput):
    try:
        return services.recommend_products(payload.dict(exclude_none=True))
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc))


@router.post("/chat")
async def post_chat(payload: ChatInput):
    try:
        return services.chat(payload.dict(exclude_none=True))
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc))


# ────────────────────────────────────────────────────────────────────────────
# NEW ADVANCED ENDPOINTS (v2.0)
# ────────────────────────────────────────────────────────────────────────────

@router.post("/cycle-intelligence")
async def get_cycle_intelligence(payload: BasePredict):
    """Advanced cycle analysis with trend detection"""
    try:
        return services.get_cycle_intelligence(payload.dict(exclude_none=True))
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc))


@router.post("/nutrition-plan")
async def get_nutrition_plan(payload: BasePredict):
    """Generate personalized nutrition plan"""
    try:
        return services.get_nutrition_plan(payload.dict(exclude_none=True))
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc))


@router.post("/fertility-insights")
async def get_fertility_insights(payload: BasePredict):
    """Get advanced fertility prediction and insights"""
    try:
        return services.get_fertility_insights(payload.dict(exclude_none=True))
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc))


@router.post("/pregnancy-insights")
async def get_pregnancy_insights(payload: BasePredict):
    """Get comprehensive pregnancy health tracking"""
    try:
        return services.get_pregnancy_insights(payload.dict(exclude_none=True))
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc))


@router.post("/mental-health")
async def get_mental_health_status(payload: BasePredict):
    """Track mental health metrics and get wellness suggestions"""
    try:
        return services.get_mental_health_status(payload.dict(exclude_none=True))
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc))


@router.post("/health-alerts")
async def get_health_alerts(payload: BasePredict):
    """Generate smart health alerts"""
    try:
        return services.get_health_alerts(payload.dict(exclude_none=True))
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc))


@router.post("/notifications")
async def get_notifications(payload: BasePredict):
    """Generate personalized notifications"""
    try:
        return services.get_notifications(payload.dict(exclude_none=True))
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc))


@router.post("/daily-recommendations")
async def get_daily_recommendations(payload: BasePredict):
    """Get comprehensive daily health recommendations"""
    try:
        return services.get_daily_health_recommendations(payload.dict(exclude_none=True))
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc))


# ────────────────────────────────────────────────────────────────────────────
# HEALTH CALCULATOR  (water intake + nutrition + BMI + pregnancy stage)
# ────────────────────────────────────────────────────────────────────────────

@router.post("/calculate-health")
async def calculate_health(payload: CalculateHealthInput):
    """
    One-shot health calculator.
    Returns: water_liters, nutrition (calories/protein/calcium/iron),
             bmi, pregnancy_stage, and phase-specific tips.
    """
    try:
        return services.calculate_health(payload.dict(exclude_none=True))
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc))


# ────────────────────────────────────────────────────────────────────────────
# GET /recommend-products?category=pads   (frontend-friendly GET route)
# ────────────────────────────────────────────────────────────────────────────

@router.get("/recommend-products")
async def get_products_by_category(
    category: str = Query(default="pads", description="Product category"),
    limit: int = Query(default=5, ge=1, le=10),
):
    """
    Returns product list for a given category string.
    Supports: pads, menstrual_cups, femi_wash, pain_relief,
              pregnancy_supplements, intimate_hygiene, hair_care, wellness
    """
    try:
        from api.product_recommendation_service import (
            recommend_products as _rec,
            _FALLBACK_PRODUCTS,
            _CATEGORY_DISPLAY,
            RECOMMENDATION_DISCLAIMER,
        )
        # Map user-friendly aliases
        alias_map = {
            "menstrual": "pads",
            "cups": "menstrual_cups",
            "wash": "femi_wash",
            "intimate": "femi_wash",
            "pain": "pain_relief",
            "pregnancy": "pregnancy_supplements",
            "prenatal": "pregnancy_supplements",
            "hair": "pads",     # fallback; hair category uses generic search
            "wellness": "pads",
        }
        cat_key = alias_map.get(category.lower(), category.lower())
        result = _rec({
            "cycle_phase": "menstrual",
            "flow_level": "medium",
            "pain_level": "low",
            "pregnancy_status": cat_key == "pregnancy_supplements",
            "max_results": limit,
        })
        # Override category label to match requested name
        result["requested_category"] = category
        return result
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc))

