from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from transformers import pipeline
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI()

LABEL_GROUPS = {
    "positive": ["admiration", "approval", "gratitude", "joy", "love", "optimism", "excitement"],
    "negative": ["anger", "disgust", "fear", "sadness"],
    "neutral": ["confusion", "neutral", "surprise", "realization"]
}

try:
    logger.info("📦 Loading model...")
    classifier = pipeline("text-classification", model="SamLowe/roberta-base-go_emotions", top_k=1)
    logger.info("✅ Model loaded!")
except Exception as e:
    logger.exception("❌ Failed to load model")

class ReviewInput(BaseModel):
    text: str

@app.post("/predict")
def predict_sentiment(review: ReviewInput):
    try:
        raw = classifier(review.text)[0][0]  # top label
        label = raw["label"]
        score = round(raw["score"], 4)

        for group, labels in LABEL_GROUPS.items():
            if label.lower() in labels:
                return {"sentiment": group, "label": label.lower(), "confidence": score}

        return {"sentiment": "neutral", "label": label.lower(), "confidence": score}
    except Exception as e:
        logger.exception("❌ Prediction failed")
        raise HTTPException(status_code=500, detail=str(e))
