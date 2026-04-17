from pydantic import BaseModel, Field
from typing import Optional, List


class BasePredict(BaseModel):
    age: Optional[float] = None
    bmi: Optional[float] = None
    cycle_length: Optional[float] = None
    menses_length: Optional[float] = None
    mean_cycle_length: Optional[float] = None
    mean_menses_length: Optional[float] = None
    luteal_phase: Optional[float] = None
    estimated_ovulation: Optional[float] = None
    total_high_days: Optional[int] = None
    total_peak_days: Optional[int] = None
    total_fertility_days: Optional[int] = None
    intercourse_fertile: Optional[int] = None
    unusual_bleeding: Optional[int] = None
    num_pregnancies: Optional[int] = None
    miscarriages: Optional[int] = None
    abortions: Optional[int] = None
    trying_to_conceive: Optional[bool] = False
    male_age: Optional[float] = None
    menstrual_regularity: Optional[str] = None
    pcos: Optional[str] = None
    stress_level: Optional[str] = None
    smoking: Optional[str] = None
    alcohol: Optional[str] = None
    sperm_count: Optional[float] = None
    motility: Optional[float] = None
    trying_months: Optional[int] = None
    treatment_type: Optional[str] = None
    # Additional wellness fields for recommendations
    sleep_hours: Optional[float] = None
    weight_kg: Optional[float] = None
    exercise_minutes_per_day: Optional[float] = None
    symptoms: Optional[List[str]] = []
    cycle_day: Optional[int] = None


class RecommendInput(BasePredict):
    pass


class RecommendProductsInput(BaseModel):
    cycle_phase: str = Field(..., description="Current cycle phase")
    flow_level: str | int | float = Field(..., description="Flow level (light/medium/heavy or 0-5)")
    pain_level: str | int | float = Field(..., description="Pain level (low/medium/high or 0-10)")
    pregnancy_status: bool = Field(default=False, description="Whether user is pregnant")
    max_results: int = Field(default=5, ge=1, le=10)


class RecommendedProductItem(BaseModel):
    name: str
    price: str
    link: str
    image: str


class RecommendProductsResponse(BaseModel):
    category: str
    products: List[RecommendedProductItem]
    disclaimer: str


class ChatHistoryItem(BaseModel):
    role: str
    content: str


class ChatInput(BaseModel):
    message: str
    history: Optional[List[ChatHistoryItem]] = None
    profile: Optional[dict] = None
    cycle: Optional[dict] = None


class CycleResponse(BaseModel):
    cycle_length: float
    status: str


class IrregularResponse(BaseModel):
    is_irregular: bool
    probability: float


class PregnancyResponse(BaseModel):
    likelihood: str
    probability: Optional[float]
