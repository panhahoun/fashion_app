# Fashion Store API image (FastAPI + SQLite)
# Build: cd backend/deploy && docker compose up -d --build

FROM python:3.12-slim

WORKDIR /app

# Install deps first (caches this layer until requirements.txt changes).
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the application source (app/ only — run.py/test_api.py not needed in prod).
COPY app ./app

EXPOSE 8000

# Uvicorn serves on 8000 inside the container; compose maps it to
# 127.0.0.1:8001 on the host so it never collides with the NextGen API on 8000.
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]