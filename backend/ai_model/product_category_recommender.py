"""ML model for product-category recommendation."""

from __future__ import annotations

import os
from pathlib import Path
from typing import Dict, List

import joblib
import pandas as pd
from sklearn.compose import ColumnTransformer
from sklearn.ensemble import RandomForestClassifier
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import OneHotEncoder


_PHASES = ["menstrual", "follicular", "ovulation", "luteal"]
_FLOWS = ["spotting", "light", "medium", "heavy"]

_CATEGORY_KEYS = [
    "pads",
    "menstrual_cups",
    "femi_wash",
    "pain_relief",
    "pregnancy_supplements",
]


class ProductCategoryRecommender:
    """Train/load RandomForest model and infer a product category."""

    def __init__(self, model_path: str | None = None) -> None:
        default_path = Path(__file__).resolve().with_name("product_category_rf.joblib")
        self._model_path = Path(
            model_path or os.getenv("PRODUCT_ML_MODEL_PATH", str(default_path))
        )
        self._pipeline = self._load_or_train()

    def predict_category(
        self,
        *,
        cycle_phase: str,
        flow_level: str,
        pain_level: float,
        pregnancy_status: bool,
    ) -> str:
        features = pd.DataFrame(
            [
                {
                    "cycle_phase": cycle_phase,
                    "flow_level": flow_level,
                    "pain_level": float(pain_level),
                    "pregnancy_status": int(bool(pregnancy_status)),
                }
            ]
        )
        prediction = self._pipeline.predict(features)
        if len(prediction) == 0:
            return "pads"
        category = str(prediction[0]).strip()
        return category if category in _CATEGORY_KEYS else "pads"

    def _load_or_train(self):
        if self._model_path.exists():
            try:
                return joblib.load(self._model_path)
            except Exception:
                pass

        pipeline = self._train_pipeline()
        self._model_path.parent.mkdir(parents=True, exist_ok=True)
        joblib.dump(pipeline, self._model_path)
        return pipeline

    def _train_pipeline(self):
        training_data = self._build_training_data()
        features = training_data[
            ["cycle_phase", "flow_level", "pain_level", "pregnancy_status"]
        ]
        target = training_data["product_category"]

        preprocessor = ColumnTransformer(
            transformers=[
                (
                    "categorical",
                    OneHotEncoder(handle_unknown="ignore"),
                    ["cycle_phase", "flow_level"],
                ),
                ("numeric", "passthrough", ["pain_level", "pregnancy_status"]),
            ]
        )

        pipeline = Pipeline(
            steps=[
                ("preprocessor", preprocessor),
                (
                    "classifier",
                    RandomForestClassifier(
                        n_estimators=240,
                        max_depth=10,
                        random_state=42,
                        class_weight="balanced_subsample",
                    ),
                ),
            ]
        )
        pipeline.fit(features, target)
        return pipeline

    def _build_training_data(self) -> pd.DataFrame:
        rows: List[Dict[str, object]] = []

        for pregnancy in [0, 1]:
            for phase in _PHASES:
                for flow in _FLOWS:
                    for pain in range(0, 11):
                        rows.append(
                            {
                                "cycle_phase": phase,
                                "flow_level": flow,
                                "pain_level": pain,
                                "pregnancy_status": pregnancy,
                                "product_category": _label_for_sample(
                                    cycle_phase=phase,
                                    flow_level=flow,
                                    pain_level=float(pain),
                                    pregnancy_status=bool(pregnancy),
                                ),
                            }
                        )

        # Add extra anchors to keep the model stable on edge combinations.
        anchors = [
            ("menstrual", "heavy", 8, 0, "pads"),
            ("menstrual", "heavy", 9, 0, "pain_relief"),
            ("follicular", "light", 2, 0, "menstrual_cups"),
            ("ovulation", "spotting", 1, 0, "femi_wash"),
            ("luteal", "medium", 7, 0, "pain_relief"),
            ("luteal", "heavy", 5, 0, "pads"),
            ("follicular", "medium", 3, 1, "pregnancy_supplements"),
            ("ovulation", "light", 6, 1, "pain_relief"),
            ("menstrual", "light", 3, 1, "pregnancy_supplements"),
        ]
        for phase, flow, pain, preg, category in anchors:
            rows.append(
                {
                    "cycle_phase": phase,
                    "flow_level": flow,
                    "pain_level": pain,
                    "pregnancy_status": preg,
                    "product_category": category,
                }
            )

        return pd.DataFrame(rows)


def _label_for_sample(
    *,
    cycle_phase: str,
    flow_level: str,
    pain_level: float,
    pregnancy_status: bool,
) -> str:
    if pregnancy_status:
        if pain_level >= 7:
            return "pain_relief"
        return "pregnancy_supplements"

    if pain_level >= 8:
        return "pain_relief"

    if cycle_phase == "menstrual":
        if flow_level in ("heavy", "medium"):
            return "pads"
        if pain_level >= 6:
            return "pain_relief"
        return "menstrual_cups"

    if cycle_phase == "follicular":
        if flow_level in ("spotting", "light"):
            return "menstrual_cups"
        if pain_level >= 6:
            return "pain_relief"
        return "femi_wash"

    if cycle_phase == "ovulation":
        if pain_level >= 6:
            return "pain_relief"
        if flow_level in ("medium", "heavy"):
            return "pads"
        return "femi_wash"

    # luteal
    if pain_level >= 5:
        return "pain_relief"
    if flow_level == "heavy":
        return "pads"
    return "femi_wash"
