FROM node:20-alpine AS base

ENV NEXT_TELEMETRY_DISABLED=1

WORKDIR /app

# Install dependencies (including devDependencies for build)
FROM base AS deps

RUN apk add --no-cache libc6-compat

COPY package.json package-lock.json* ./

# Install all dependencies including devDependencies
RUN npm ci

# Build the app
FROM base AS builder

WORKDIR /app

COPY --from=deps /app/node_modules ./node_modules
COPY . .

RUN npm run build

# Production image, copy all the files and run next
FROM base AS runner

WORKDIR /app

ENV NODE_ENV=production

COPY --from=builder /app/public ./public
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/node_modules ./node_modules

EXPOSE 3000

CMD ["npm", "run", "start"]

