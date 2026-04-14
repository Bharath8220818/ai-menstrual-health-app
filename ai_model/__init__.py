"""
ai_model package
================
Menstrual Health AI/ML Pipeline

Public API
----------
    from ai_model.predict import predict
    from ai_model.train   import main as train_models
    from ai_model.preprocess import load_and_preprocess
"""

from ai_model.predict import predict  # noqa: F401

__all__ = ["predict"]
