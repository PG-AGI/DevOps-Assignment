# -------- Stage 1: Build --------
FROM node:20-alpine AS builder

# Set working directory
WORKDIR /app

# Copy package files and install dependencies
COPY package*.json ./

# Clean install for reproducibility
RUN npm ci

# Copy all frontend source code
COPY . .

# Build Next.js app
RUN npm run build

# -------- Stage 2: Production --------
FROM node:20-alpine

# Create a non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

# Copy built app and node_modules from builder
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/node_modules ./node_modules


# Switch to non-root user
USER appuser

# Expose Next.js default port
EXPOSE 3000

# Environment variable (optional)
ENV NODE_ENV=production

# Start Next.js app
CMD ["npm", "start"]