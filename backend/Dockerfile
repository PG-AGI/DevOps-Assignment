# -------- Stage 1: Build Stage --------
FROM python:3.11-slim AS builder

# Set workdir
WORKDIR /app

# Install pip tools
RUN python -m pip install --upgrade pip

# Copy requirements first (for caching)
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir --upgrade pip \
    pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# -------- Stage 2: Production Stage --------
FROM python:3.11-slim

# Create a non-root user
RUN useradd -m appuser

# Set workdir
WORKDIR /app

# Copy installed packages from builder
COPY --from=builder /usr/local /usr/local

# Copy app code
COPY --from=builder /app .

# Change to non-root user
USER appuser

# Expose port
EXPOSE 8000

# Set environment variables (example)
ENV ENVIRONMENT=production
ENV PORT=8000

# Command to run
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
