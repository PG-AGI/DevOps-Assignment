# =========================
# Stage 1: Build stage
# =========================
FROM python:3.11-slim AS builder

# Set working directory
WORKDIR /app

# Install build dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY app app

# =========================
# Stage 2: Runtime stage
# =========================
FROM python:3.11-slim

# Create non-root user (security best practice)
RUN useradd -m appuser

# Set working directory
WORKDIR /app

# Copy only required files from builder stage
COPY --from=builder /usr/local/lib/python3.11 /usr/local/lib/python3.11
COPY --from=builder /usr/local/bin /usr/local/bin
COPY app app

# Switch to non-root user
USER appuser

# Environment-based configuration
ENV HOST=0.0.0.0
ENV PORT=8000

# Expose application port
EXPOSE 8000

# Start FastAPI using Uvicorn
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
