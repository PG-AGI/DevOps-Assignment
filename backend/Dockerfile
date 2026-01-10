# ---------- Builder stage ----------
FROM python:3.11-alpine AS builder

WORKDIR /app

# System deps needed to build Python packages with native extensions
RUN apk add --no-cache \
    build-base \
    gcc \
    musl-dev \
    libffi-dev \
    openssl-dev

COPY requirements.txt .

RUN pip install --upgrade pip \
    && pip wheel --no-cache-dir --no-deps -r requirements.txt -w /wheels

# ---------- Runtime stage ----------
FROM python:3.11-alpine

ENV PYTHONUNBUFFERED=1
ENV PORT=8000

# Runtime dependencies only (no compilers)
RUN apk add --no-cache \
    libffi \
    openssl \
    ca-certificates

# Create non-root user
RUN adduser -D appuser

WORKDIR /app

# Install dependencies from wheels
COPY --from=builder /wheels /wheels
RUN pip install --no-cache-dir /wheels/* \
    && rm -rf /wheels

COPY app ./app

USER appuser

EXPOSE 8000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
