"""
train_fertility.py
------------------
Train a RandomForestClassifier to predict Pregnancy_Outcome and
save the model and scaler separately for lightweight inference.

Saves:
  - ai_model/model_fertility.pkl
  - ai_model/scaler_fertility.pkl
  - ai_model/label_encoders_fertility.pkl

Usage:
  python ai_model/train_fertility.py
"""
import os
import sys
import time
import warnings
import joblib

from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score, roc_auc_score, classification_report

warnings.filterwarnings("ignore")

# ensure project root on path
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from ai_model.preprocess import load_and_preprocess


OUT_DIR = os.path.dirname(os.path.abspath(__file__))
MODEL_PATH = os.path.join(OUT_DIR, "model_fertility.pkl")
SCALER_PATH = os.path.join(OUT_DIR, "scaler_fertility.pkl")
ENCODERS_PATH = os.path.join(OUT_DIR, "label_encoders_fertility.pkl")


def main():
    print("\n=== TRAIN FERTILITY MODEL ===")
    data = load_and_preprocess()

    df = data["fertility_df"]
    fc = data["feature_cols"]["pregnancy_outcome"]

    X = df[fc["features"]].values
    y = df[fc["target"]].values

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
        n_jobs=-1,
    )

    t0 = time.time()
    model.fit(X_train, y_train)
    elapsed = time.time() - t0

    y_pred = model.predict(X_test)
    y_prob = model.predict_proba(X_test)[:, 1]
    acc = accuracy_score(y_test, y_pred)
    auc = roc_auc_score(y_test, y_prob)

    print(f"Trained fertility model in {elapsed:.2f}s — acc={acc:.4f}, auc={auc:.4f}")
    print("Classification report:")
    print(classification_report(y_test, y_pred, zero_division=0))

    # Save model and scaler/encoders
    scaler = data["scalers"].get("fertility_scaler")
    label_encoders = {k: v for k, v in data["label_encoders"].items() if k in ("Menstrual_Regularity", "PCOS", "Stress_Level", "Smoking", "Alcohol_Intake", "Treatment_Type", "Pregnancy_Outcome")}

    joblib.dump(model, MODEL_PATH, compress=3)
    if scaler is not None:
        joblib.dump(scaler, SCALER_PATH, compress=3)
    joblib.dump(label_encoders, ENCODERS_PATH, compress=3)

    size = os.path.getsize(MODEL_PATH) / (1024 * 1024)
    print(f"Saved model → {MODEL_PATH} ({size:.2f} MB)")
    if os.path.exists(SCALER_PATH):
        print(f"Saved scaler → {SCALER_PATH}")
    print(f"Saved label encoders → {ENCODERS_PATH}")


if __name__ == "__main__":
    main()
