# Stage 1: Build
FROM python:3.12-slim AS builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --upgrade pip && pip install --user -r requirements.txt

# Stage 2: Run
FROM python:3.12-slim
WORKDIR /app
COPY --from=builder /root/.local /root/.local
COPY app/ ./app/
ENV PATH=/root/.local/bin:$PATH
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
