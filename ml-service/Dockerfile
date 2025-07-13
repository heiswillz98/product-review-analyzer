FROM python:3.11-slim

WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

ENV TRANSFORMERS_CACHE=/app/.hf_cache


RUN mkdir -p $TRANSFORMERS_CACHE && \
    python -c "from transformers import pipeline; \
    pipeline('text-classification', model='SamLowe/roberta-base-go_emotions', top_k=1)"


# # Pre-download models into that cache
# RUN mkdir -p $TRANSFORMERS_CACHE && \
#     python -c "from transformers import AutoModelForSequenceClassification, AutoTokenizer; \
#     AutoModelForSequenceClassification.from_pretrained('distilbert-base-uncased-finetuned-sst-2-english', cache_dir='$TRANSFORMERS_CACHE'); \
#     AutoTokenizer.from_pretrained('distilbert-base-uncased-finetuned-sst-2-english', cache_dir='$TRANSFORMERS_CACHE')"


# Copy app code
COPY main.py .

# Run FastAPI app
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
