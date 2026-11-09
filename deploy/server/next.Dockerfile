# Shared by every Next.js site. NEXT_PUBLIC_* values are read at build time,
# so they come in as build arguments.
FROM node:20-alpine AS build
WORKDIR /app
RUN apk add --no-cache libc6-compat
ENV NEXT_TELEMETRY_DISABLED=1
ARG NEXT_PUBLIC_API_URL
ENV NEXT_PUBLIC_API_URL=$NEXT_PUBLIC_API_URL
COPY package*.json ./
RUN npm ci
COPY . .
# `next start` compiles next.config.ts with TypeScript, a dev dependency.
# Keep it through the prune, or Next installs it at first start and the
# container restarts once.
RUN npm run build \
 && (cp -r node_modules/typescript /tmp/typescript 2>/dev/null || true) \
 && npm prune --omit=dev \
 && if [ -d /tmp/typescript ] && [ ! -d node_modules/typescript ]; then mv /tmp/typescript node_modules/typescript; fi

FROM node:20-alpine
WORKDIR /app
ENV NODE_ENV=production NEXT_TELEMETRY_DISABLED=1 PORT=3000 HOSTNAME=0.0.0.0
COPY --from=build /app ./
EXPOSE 3000
CMD ["npx", "next", "start", "-p", "3000"]
