"""
train.py
========
Menstrual Health AI Pipeline — Model Training

Three RandomForest models are trained:
  1. RandomForestRegressor    → predict cycle length (regression)
  2. RandomForestClassifier   → detect irregular cycles (binary classification)
  3. RandomForestClassifier   → predict pregnancy outcome (binary classification)

All models + supporting objects (scalers, encoders) are saved to:
    ai_model/model.pkl   (single joblib bundle)

Usage
-----
    python ai_model/train.py
"""

import os
import sys
import time
import warnings
import joblib
import numpy as np

from sklearn.ensemble import RandomForestRegressor, RandomForestClassifier
from sklearn.model_selection import train_test_split, cross_val_score
from sklearn.metrics import (
    mean_absolute_error, r2_score,
    classification_report, accuracy_score, roc_auc_score
)

warnings.filterwarnings("ignore")

# ── ensure the project root is on the path so preprocess can be imported ─────
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from ai_model.preprocess import load_and_preprocess

# ──────────────────────────────────────────────────────────────────────────────
# OUTPUT PATH
# ──────────────────────────────────────────────────────────────────────────────
MODEL_PKL = os.path.join(os.path.dirname(os.path.abspath(__file__)), "model.pkl")


# ──────────────────────────────────────────────────────────────────────────────
# HELPER — print a banner
# ──────────────────────────────────────────────────────────────────────────────
def _banner(title: str) -> None:
    print(f"\n{'─'*60}")
    print(f"  {title}")
    print(f"{'─'*60}")


# ──────────────────────────────────────────────────────────────────────────────
# MODEL 1 — Regression: Predict Cycle Length
# ──────────────────────────────────────────────────────────────────────────────
def train_cycle_length_model(data: dict) -> RandomForestRegressor:
    """
    Train a RandomForestRegressor to predict menstrual cycle length (in days).

    Dataset   : FedCycle (cycle_df)
    Target    : LengthofCycle
    Metric    : MAE, R²
    """
    _banner("MODEL 1 — RandomForest Regression: Predict Cycle Length")

    df      = data["cycle_df"]
    fc      = data["feature_cols"]["cycle_length"]
    X       = df[fc["features"]].values
    y       = df[fc["target"]].values

    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42
    )

    model = RandomForestRegressor(
        n_estimators=200,
        max_depth=12,
        min_samples_split=4,
        min_samples_leaf=2,
        random_state=42,
        n_jobs=-1
    )

    t0 = time.time()
    model.fit(X_train, y_train)
    elapsed = time.time() - t0

    # ── Evaluation ────────────────────────────────────────────────────────────
    y_pred = model.predict(X_test)
    mae    = mean_absolute_error(y_test, y_pred)
    r2     = r2_score(y_test, y_pred)

    # 5-fold cross-validated MAE
    cv_mae = -cross_val_score(model, X, y,
                              cv=5, scoring="neg_mean_absolute_error",
                              n_jobs=-1).mean()

    print(f"  Training time : {elapsed:.2f}s")
    print(f"  Test MAE      : {mae:.3f} days")
    print(f"  Test R²       : {r2:.4f}")
    print(f"  CV MAE (5-fold): {cv_mae:.3f} days")

    # Top features
    feat_imp = sorted(zip(fc["features"], model.feature_importances_),
                      key=lambda x: x[1], reverse=True)[:8]
    print("  Top features  :")
    for feat, imp in feat_imp:
        print(f"    {feat:<35} {imp:.4f}")

    return model


# ──────────────────────────────────────────────────────────────────────────────
# MODEL 2 — Classification: Detect Irregular Cycles
# ──────────────────────────────────────────────────────────────────────────────
def train_irregularity_model(data: dict) -> RandomForestClassifier:
    """
    Train a RandomForestClassifier to detect irregular menstrual cycles.

    Dataset   : FedCycle (cycle_df)
    Target    : is_irregular  (0 = regular, 1 = irregular)
    Metric    : Accuracy, AUC-ROC, classification report
    """
    _banner("MODEL 2 — RandomForest Classification: Detect Irregular Cycles")

    df = data["cycle_df"]
    fc = data["feature_cols"]["irregularity"]
    X  = df[fc["features"]].values
    y  = df[fc["target"]].values

    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42, stratify=y
    )

    model = RandomForestClassifier(
        n_estimators=200,
        max_depth=10,
        min_samples_split=4,
        min_samples_leaf=2,
        class_weight="balanced",    # handle imbalance
        random_state=42,
        n_jobs=-1
    )

    t0 = time.time()
    model.fit(X_train, y_train)
    elapsed = time.time() - t0

    # ── Evaluation ────────────────────────────────────────────────────────────
    y_pred  = model.predict(X_test)
    y_prob  = model.predict_proba(X_test)[:, 1]
    acc     = accuracy_score(y_test, y_pred)
    auc     = roc_auc_score(y_test, y_prob)

    print(f"  Training time : {elapsed:.2f}s")
    print(f"  Test Accuracy : {acc:.4f}")
    print(f"  AUC-ROC       : {auc:.4f}")
    print(f"  Class distribution — train: {dict(zip(*np.unique(y_train, return_counts=True)))}")
    print("\n  Classification Report:")
    print(classification_report(y_test, y_pred,
                                target_names=["Regular", "Irregular"],
                                zero_division=0))

    # Top features
    feat_imp = sorted(zip(fc["features"], model.feature_importances_),
                      key=lambda x: x[1], reverse=True)[:8]
    print("  Top features  :")
    for feat, imp in feat_imp:
        print(f"    {feat:<35} {imp:.4f}")

    return model


# ──────────────────────────────────────────────────────────────────────────────
# MODEL 3 — Classification: Predict Pregnancy Outcome
# ──────────────────────────────────────────────────────────────────────────────
def train_pregnancy_model(data: dict) -> RandomForestClassifier:
    """
    Train a RandomForestClassifier to predict pregnancy outcome
    (Success / Failure).

    Dataset   : Fertility Health Dataset (fertility_df)
    Target    : Pregnancy_Outcome  (encoded by LabelEncoder)
    Metric    : Accuracy, AUC-ROC, classification report
    """
    _banner("MODEL 3 — RandomForest Classification: Predict Pregnancy Outcome")

    df = data["fertility_df"]
    fc = data["feature_cols"]["pregnancy_outcome"]
    X  = df[fc["features"]].values
    y  = df[fc["target"]].values

    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42, stratify=y
    )

    model = RandomForestClassifier(
        n_estimators=300,
        max_depth=8,
        min_samples_split=5,
        min_samples_leaf=3,
        class_weight="balanced",
        random_state=42,
        n_jobs=-1
    )

    t0 = time.time()
    model.fit(X_train, y_train)
    elapsed = time.time() - t0

    # ── Evaluation ────────────────────────────────────────────────────────────
    y_pred = model.predict(X_test)
    y_prob = model.predict_proba(X_test)[:, 1]
    acc    = accuracy_score(y_test, y_pred)
    auc    = roc_auc_score(y_test, y_prob)

    # Decode label names for the report
    le = data["label_encoders"].get("Pregnancy_Outcome")
    class_names = list(le.classes_) if le else ["Class 0", "Class 1"]

    print(f"  Training time : {elapsed:.2f}s")
    print(f"  Test Accuracy : {acc:.4f}")
    print(f"  AUC-ROC       : {auc:.4f}")
    print("\n  Classification Report:")
    print(classification_report(y_test, y_pred,
                                target_names=class_names,
                                zero_division=0))

    # Top features
    feat_imp = sorted(zip(fc["features"], model.feature_importances_),
                      key=lambda x: x[1], reverse=True)[:8]
    print("  Top features  :")
    for feat, imp in feat_imp:
        print(f"    {feat:<35} {imp:.4f}")

    return model


# ──────────────────────────────────────────────────────────────────────────────
# SAVE — bundle all artefacts into model.pkl
# ──────────────────────────────────────────────────────────────────────────────
def save_models(cycle_model, irregularity_model, pregnancy_model, data: dict) -> None:
    """
    Persist all trained models together with their encoders/scalers
    into a single model.pkl bundle for easy loading in predict.py.

    Bundle keys
    -----------
    cycle_length_model      : RandomForestRegressor
    irregularity_model      : RandomForestClassifier
    pregnancy_model         : RandomForestClassifier
    label_encoders          : dict[str, LabelEncoder]
    scalers                 : dict[str, StandardScaler]
    feature_cols            : dict (task → feature list + target name)
    cycle_df_columns        : list[str]   (ordered columns used for cycle models)
    fertility_df_columns    : list[str]   (ordered columns used for pregnancy model)
    """
    bundle = {
        "cycle_length_model"    : cycle_model,
        "irregularity_model"    : irregularity_model,
        "pregnancy_model"       : pregnancy_model,
        "label_encoders"        : data["label_encoders"],
        "scalers"               : data["scalers"],
        "feature_cols"          : data["feature_cols"],
        "cycle_df_columns"      : list(data["cycle_df"].columns),
        "fertility_df_columns"  : list(data["fertility_df"].columns),
        "merged_df_columns"     : list(data["merged_df"].columns),
    }

    joblib.dump(bundle, MODEL_PKL, compress=3)
    size_mb = os.path.getsize(MODEL_PKL) / (1024 * 1024)
    print(f"\n  ✓ Models saved → {MODEL_PKL}  ({size_mb:.2f} MB)")


# ──────────────────────────────────────────────────────────────────────────────
# MAIN
# ──────────────────────────────────────────────────────────────────────────────
def main() -> None:
    print("=" * 60)
    print("  MENSTRUAL HEALTH AI — TRAINING PIPELINE")
    print("=" * 60)

    # Step 1 — preprocess all datasets
    data = load_and_preprocess()

    # Step 2 — train the three models
    cycle_model        = train_cycle_length_model(data)
    irregularity_model = train_irregularity_model(data)
    pregnancy_model    = train_pregnancy_model(data)

    # Step 3 — save all models in one bundle
    _banner("SAVING MODELS")
    save_models(cycle_model, irregularity_model, pregnancy_model, data)

    print("\n" + "=" * 60)
    print("  TRAINING COMPLETE  ✓")
    print("=" * 60)


if __name__ == "__main__":
    main()
