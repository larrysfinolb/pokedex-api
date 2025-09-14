# Install dependencies only when needed
FROM node:22-alpine AS deps

RUN apk add --no-cache libc6-compat
WORKDIR /app
COPY package.json pnpm-lock.yaml ./
RUN npm install -g pnpm && pnpm install --frozen-lockfile

# Build the app with cache dependencies
FROM node:22-alpine AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN pnpm build

# Production image, copy all the files and run the app
FROM node:22-alpine AS runner

WORKDIR /usr/src/app
COPY package.json pnpm-lock.yaml ./
RUN npm install -g pnpm && pnpm install --prod
COPY --from=builder /app/dist ./dist
CMD ["node", "dist/main.js"]