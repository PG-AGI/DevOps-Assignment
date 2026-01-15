# =========================
# Stage 1: Install deps
# =========================
FROM node:20-alpine AS deps
WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci

# =========================
# Stage 2: Build
# =========================
FROM node:20-alpine AS builder
WORKDIR /app

# 🔴 BUILD ARG MUST BE DECLARED HERE
ARG NEXT_PUBLIC_API_URL
ENV NEXT_PUBLIC_API_URL=${NEXT_PUBLIC_API_URL}

COPY --from=deps /app/node_modules ./node_modules
COPY . .

# 🔍 PROOF (you will see this in logs)
RUN echo "NEXT_PUBLIC_API_URL=${NEXT_PUBLIC_API_URL}"

RUN npm run build

# =========================
# Stage 3: Runtime
# =========================
FROM node:20-alpine AS runner
WORKDIR /app

RUN addgroup -S appgroup && adduser -S appuser -G appgroup

ENV NODE_ENV=production
ENV PORT=3000

COPY --from=builder /app/.next ./.next
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json

USER appuser
EXPOSE 3000

CMD ["npm", "start"]
