FROM python:18-alpine AS builder
WORKDIR /app
#install dependencies first
COPY package.json yarn.lock* package-lock.json* ./
RUN npm install

# copy souce and build 
COPY . .
RUN npm run build 

FROM node:18-alpine AS runner
WORKDIR /app

# Set environment to production
ENV NODE_ENV production

# Copy only the necessary files from builder
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json

EXPOSE 3000

CMD ["npm", "start"]