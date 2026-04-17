"""
preprocess.py
=============
Menstrual Health AI Pipeline — Data Loading, Cleaning & Feature Engineering

Datasets handled:
  1. menstrual cycle dataset  → FedCycleData071012 (2).csv   (cycle-level)
  2. Fertility Health Dataset → Fertility_Health_Dataset_2026.csv (couple-level)
  3. Menstrual Health & Productivity Dataset
       ├─ User_Profile.csv   (user-level)
       └─ Period_Log.csv     (cycle-level, merged with user profile)

Output
------
  load_and_preprocess() returns a dict:
    {
      "cycle_df"    : pd.DataFrame,   # from dataset 1 — for cycle length regression
      "fertility_df": pd.DataFrame,   # from dataset 2 — for pregnancy outcome classification
      "merged_df"   : pd.DataFrame,   # dataset 3 (user + period log) — irregularity classification
      "feature_cols": dict,           # feature column lists per task
      "label_encoders": dict,         # fitted LabelEncoders for categorical columns
      "scalers"     : dict,           # fitted StandardScalers per dataframe
    }
"""

import os
import warnings
import numpy as np
import pandas as pd
from sklearn.preprocessing import LabelEncoder, StandardScaler
from sklearn.impute import SimpleImputer

warnings.filterwarnings("ignore")

# ──────────────────────────────────────────────────────────────────────────────
# PATH CONFIGURATION
# ──────────────────────────────────────────────────────────────────────────────
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DATA_DIR = os.path.join(BASE_DIR, "data")

CYCLE_CSV       = os.path.join(DATA_DIR, "menstrual cycle dataset",
                                "FedCycleData071012 (2).csv")
FERTILITY_CSV   = os.path.join(DATA_DIR, "Fertility Health Dataset",
                                "Fertility_Health_Dataset_2026.csv")
USER_PROFILE_CSV = os.path.join(DATA_DIR, "Menstrual Health & Productivity Dataset",
                                 "User_Profile.csv")
PERIOD_LOG_CSV  = os.path.join(DATA_DIR, "Menstrual Health & Productivity Dataset",
                                "Period_Log.csv")


# ──────────────────────────────────────────────────────────────────────────────
# DATASET 1 — Menstrual Cycle Dataset (FedCycle)
# ──────────────────────────────────────────────────────────────────────────────
def _load_cycle_dataset() -> pd.DataFrame:
    """
    Load and clean the FedCycle menstrual cycle dataset.

    Target → LengthofCycle  (regression)
    Additional label → is_irregular  (classification: cycle < 21 or > 35 days)
    """
    df = pd.read_csv(CYCLE_CSV, low_memory=False)
    print(f"[Dataset 1] Loaded: {df.shape[0]} rows × {df.shape[1]} cols")

    # --- Select relevant features ---------------------------------------------
    feature_cols = [
        "Age", "BMI", "LengthofCycle", "LengthofMenses", "MeanCycleLength",
        "MeanMensesLength", "MeanBleedingIntensity", "TotalMensesScore",
        "LengthofLutealPhase", "EstimatedDayofOvulation",
        "TotalNumberofHighDays", "TotalNumberofPeakDays",
        "TotalDaysofFertility", "NumberofDaysofIntercourse",
        "IntercourseInFertileWindow", "UnusualBleeding",
        "CycleWithPeakorNot", "ReproductiveCategory",
        "Numberpreg", "Miscarriages", "Abortions",
    ]
    df = df[[c for c in feature_cols if c in df.columns]].copy()

    # --- Convert object columns to numeric where possible ---------------------
    for col in df.columns:
        if df[col].dtype == object:
            df[col] = pd.to_numeric(df[col], errors="coerce")

    # --- Drop rows with no target value ---------------------------------------
    df.dropna(subset=["LengthofCycle"], inplace=True)

    # --- Impute missing values (median for numerics) --------------------------
    imputer = SimpleImputer(strategy="median")
    df_imputed = pd.DataFrame(imputer.fit_transform(df), columns=df.columns)

    # --- Clip extreme cycle lengths (physiological range 15–60) --------------
    df_imputed["LengthofCycle"] = df_imputed["LengthofCycle"].clip(15, 60)

    # --- Derive irregularity label --------------------------------------------
    df_imputed["is_irregular"] = (
        (df_imputed["LengthofCycle"] < 21) | (df_imputed["LengthofCycle"] > 35)
    ).astype(int)

    print(f"[Dataset 1] After cleaning: {df_imputed.shape[0]} rows")
    return df_imputed


# ──────────────────────────────────────────────────────────────────────────────
# DATASET 2 — Fertility Health Dataset
# ──────────────────────────────────────────────────────────────────────────────
def _load_fertility_dataset() -> tuple[pd.DataFrame, dict, dict]:
    """
    Load and preprocess the Fertility Health Dataset.

    Target → Pregnancy_Outcome  (binary classification: Success / Failure)
    Returns: (dataframe, label_encoders, scaler)
    """
    df = pd.read_csv(FERTILITY_CSV)
    print(f"[Dataset 2] Loaded: {df.shape[0]} rows × {df.shape[1]} cols")

    # --- Drop ID column -------------------------------------------------------
    df.drop(columns=["Couple_ID"], errors="ignore", inplace=True)

    # --- Categorical columns --------------------------------------------------
    cat_cols = ["Menstrual_Regularity", "PCOS", "Stress_Level",
                "Smoking", "Alcohol_Intake", "Treatment_Type", "Pregnancy_Outcome"]

    label_encoders: dict[str, LabelEncoder] = {}
    for col in cat_cols:
        if col in df.columns:
            df[col].fillna("Unknown", inplace=True)
            le = LabelEncoder()
            df[col] = le.fit_transform(df[col].astype(str))
            label_encoders[col] = le

    # --- Numeric columns — impute then scale ----------------------------------
    num_cols = [c for c in df.columns if c not in cat_cols]
    imputer  = SimpleImputer(strategy="median")
    df[num_cols] = imputer.fit_transform(df[num_cols])

    scaler = StandardScaler()
    df[num_cols] = scaler.fit_transform(df[num_cols])

    print(f"[Dataset 2] After cleaning: {df.shape[0]} rows")
    return df, label_encoders, {"fertility_scaler": scaler}


# ──────────────────────────────────────────────────────────────────────────────
# DATASET 3 — User Profile + Period Log (merge on user_id)
# ──────────────────────────────────────────────────────────────────────────────
def _load_merged_dataset() -> tuple[pd.DataFrame, dict, dict]:
    """
    Merge User_Profile.csv and Period_Log.csv on user_id.

    Target → cycle_irregular  (derived: cycle_length_days < 21 or > 35)
    Returns: (merged_dataframe, label_encoders, scaler)
    """
    user_df   = pd.read_csv(USER_PROFILE_CSV)
    period_df = pd.read_csv(PERIOD_LOG_CSV)
    print(f"[Dataset 3a] User Profile loaded:  {user_df.shape[0]} rows × {user_df.shape[1]} cols")
    print(f"[Dataset 3b] Period Log loaded:    {period_df.shape[0]} rows × {period_df.shape[1]} cols")

    # --- Merge on user_id -----------------------------------------------------
    merged = period_df.merge(user_df, on="user_id", how="left")
    print(f"[Dataset 3] Merged shape: {merged.shape[0]} rows × {merged.shape[1]} cols")

    # --- Drop columns not useful for ML --------------------------------------
    drop_cols = ["user_id", "start_date", "cycle_number", "state",
                 "cycle_phase"]          # high-cardinality / leakage risk
    merged.drop(columns=[c for c in drop_cols if c in merged.columns], inplace=True)

    # --- Derive target label --------------------------------------------------
    merged["cycle_irregular"] = (
        (merged["cycle_length_days"] < 21) | (merged["cycle_length_days"] > 35)
    ).astype(int)

    # --- Categorical columns --------------------------------------------------
    cat_cols = ["flow_level", "pms_symptoms", "ovulation_result",
                "diet_quality", "exercise_frequency",
                "alcohol_consumption", "smoking_status"]

    label_encoders: dict[str, LabelEncoder] = {}
    for col in cat_cols:
        if col in merged.columns:
            merged[col].fillna("Unknown", inplace=True)
            le = LabelEncoder()
            merged[col] = le.fit_transform(merged[col].astype(str))
            label_encoders[col] = le

    # --- Numeric columns — impute then scale ----------------------------------
    exclude = {"cycle_irregular"}
    num_cols = [c for c in merged.select_dtypes(include=[np.number]).columns
                if c not in exclude]

    imputer = SimpleImputer(strategy="median")
    merged[num_cols] = imputer.fit_transform(merged[num_cols])

    scaler = StandardScaler()
    merged[num_cols] = scaler.fit_transform(merged[num_cols])

    print(f"[Dataset 3] After cleaning: {merged.shape[0]} rows")
    return merged, label_encoders, {"merged_scaler": scaler}


# ──────────────────────────────────────────────────────────────────────────────
# FEATURE SELECTION — define which columns feed each model
# ──────────────────────────────────────────────────────────────────────────────
def _select_features(cycle_df: pd.DataFrame,
                     fertility_df: pd.DataFrame,
                     merged_df: pd.DataFrame) -> dict:
    """Return a dict mapping task name → (feature_columns, target_column)."""

    # Task 1 — Regression: predict LengthofCycle
    cycle_feature_cols = [c for c in cycle_df.columns
                          if c not in {"LengthofCycle", "is_irregular"}]

    # Task 2 — Classification: detect irregular cycle (from dataset 1)
    irregularity_feature_cols = [c for c in cycle_df.columns
                                 if c not in {"is_irregular", "LengthofCycle"}]

    # Task 3 — Classification: predict pregnancy outcome (from dataset 2)
    pregnancy_feature_cols = [c for c in fertility_df.columns
                              if c != "Pregnancy_Outcome"]

    return {
        "cycle_length": {
            "features"  : cycle_feature_cols,
            "target"    : "LengthofCycle",
            "dataframe" : "cycle_df",
        },
        "irregularity": {
            "features"  : irregularity_feature_cols,
            "target"    : "is_irregular",
            "dataframe" : "cycle_df",
        },
        "pregnancy_outcome": {
            "features"  : pregnancy_feature_cols,
            "target"    : "Pregnancy_Outcome",
            "dataframe" : "fertility_df",
        },
    }


# ──────────────────────────────────────────────────────────────────────────────
# PUBLIC API
# ──────────────────────────────────────────────────────────────────────────────
def load_and_preprocess() -> dict:
    """
    Master function: load all datasets, clean, merge, encode, scale, and
    return a unified dict ready for model training.

    Returns
    -------
    dict with keys:
        cycle_df        : pd.DataFrame  (cleaned FedCycle data)
        fertility_df    : pd.DataFrame  (cleaned Fertility Health data)
        merged_df       : pd.DataFrame  (merged User Profile + Period Log)
        feature_cols    : dict          (features & targets per task)
        label_encoders  : dict          (all fitted LabelEncoders)
        scalers         : dict          (all fitted StandardScalers)
    """
    print("=" * 60)
    print("  MENSTRUAL HEALTH AI — PREPROCESSING PIPELINE")
    print("=" * 60)

    # Load each dataset
    cycle_df                            = _load_cycle_dataset()
    fertility_df, fe_le, fe_scaler      = _load_fertility_dataset()
    merged_df, mg_le, mg_scaler         = _load_merged_dataset()

    # Combine label encoders and scalers
    all_label_encoders = {**fe_le, **mg_le}
    all_scalers        = {**fe_scaler, **mg_scaler}

    # Feature selection
    feature_cols = _select_features(cycle_df, fertility_df, merged_df)

    print("\n[Preprocessing Complete]")
    print(f"  cycle_df    : {cycle_df.shape}")
    print(f"  fertility_df: {fertility_df.shape}")
    print(f"  merged_df   : {merged_df.shape}")

    return {
        "cycle_df"      : cycle_df,
        "fertility_df"  : fertility_df,
        "merged_df"     : merged_df,
        "feature_cols"  : feature_cols,
        "label_encoders": all_label_encoders,
        "scalers"       : all_scalers,
    }


# ──────────────────────────────────────────────────────────────────────────────
# STANDALONE TEST
# ──────────────────────────────────────────────────────────────────────────────
if __name__ == "__main__":
    result = load_and_preprocess()
    for k, v in result.items():
        if isinstance(v, pd.DataFrame):
            print(f"\n{k}:\n{v.head(3)}")
        else:
            print(f"\n{k}: {v}")
