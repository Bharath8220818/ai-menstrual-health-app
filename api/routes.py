from fastapi import APIRouter, HTTPException
from api.schemas import BasePredict, RecommendInput
from api import services

router = APIRouter()


@router.post("/predict/cycle")
async def post_predict_cycle(payload: BasePredict):
    try:
        return services.predict_cycle(payload.dict())
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc))


@router.post("/predict/irregular")
async def post_predict_irregular(payload: BasePredict):
    try:
        return services.predict_irregular(payload.dict())
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc))


@router.post("/predict/fertility")
async def post_predict_fertility(payload: BasePredict):
    try:
        return services.predict_fertility(payload.dict())
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc))


@router.post("/recommend")
async def post_recommend(payload: RecommendInput):
    try:
        return services.recommend(payload.dict())
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc))
