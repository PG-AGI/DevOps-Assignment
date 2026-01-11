# =========================
# Stage 1: Build stage
# =========================
FROM node:18-alpine AS builder

# Set working directory
WORKDIR /app

# Copy package files first (better caching)
COPY package.json package-lock.json ./
RUN npm ci

# Copy application source
COPY . .

# Build Next.js app
RUN npm run build

# =========================
# Stage 2: Production stage
# =========================
FROM node:18-alpine

# Create non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Set working directory
WORKDIR /app

# Copy only required build output
COPY --from=builder /app/package.json ./
COPY --from=builder /app/package-lock.json ./
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/node_modules ./node_modules

# Switch to non-root user
USER appuser

# Environment variable for backend URL
ENV NEXT_PUBLIC_API_URL=http://localhost:8000

# Expose Next.js port
EXPOSE 3000

# Start Next.js in production mode
CMD ["npm", "start"]
