# The NestJS API, built once and run with production dependencies only.
FROM node:20-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build && npm prune --omit=dev

FROM node:20-alpine
WORKDIR /app
ENV NODE_ENV=production
COPY --from=build /app/package*.json ./
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/dist ./dist
COPY --from=build /app/public ./public
EXPOSE 3000
# The scripts at the backend's root widen the compile root, so the entry point
# lands at dist/src/main.js rather than dist/main.js.
CMD ["node", "dist/src/main"]
