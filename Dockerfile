# Postiz-libre multi-stage Dockerfile
# Build context: .
# Build: docker build -f Dockerfile --target <stage> .
# Targets: base, deps, builder, backend, frontend, orchestrator, runtime

FROM node:24-bookworm-slim AS base
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 make g++ pkg-config libpixman-1-dev libcairo2-dev libpango1.0-dev libjpeg-dev libgif-dev \
    && rm -rf /var/lib/apt/lists/*
RUN npm install -g pnpm@10.22.0
ENV NPM_CONFIG_CACHE=/cache/npm
WORKDIR /app

# ── deps ──
FROM base AS deps
COPY pnpm-lock.yaml pnpm-workspace.yaml package.json ./
COPY apps/backend/package.json apps/backend/
COPY apps/frontend/package.json apps/frontend/
COPY apps/orchestrator/package.json apps/orchestrator/
COPY apps/extension/package.json apps/extension/
COPY apps/commands/package.json apps/commands/
COPY apps/sdk/package.json apps/sdk/
COPY libraries/nestjs-libraries/src/database/prisma/schema.prisma libraries/nestjs-libraries/src/database/prisma/
COPY apps/frontend/scripts/fetch-gtm.mjs apps/frontend/scripts/
COPY .npmrc ./
RUN pnpm install --frozen-lockfile

# ── builder ──
FROM deps AS builder
COPY . .
RUN NODE_OPTIONS="--max-old-space-size=4096" NEXT_BUILD_WORKERS=4 pnpm run build

# ── backend ──
FROM base AS backend
COPY --from=builder /app/apps/backend/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
ENV NODE_OPTIONS="--max-old-space-size=384"
EXPOSE 3000
CMD ["node", "--experimental-require-module", "dist/main.js"]

# ── frontend ──
FROM base AS frontend
COPY --from=builder /app/apps/frontend/.next ./apps/frontend/.next
COPY --from=builder /app/apps/frontend/public ./apps/frontend/public
COPY --from=builder /app/apps/frontend/next.config.js ./apps/frontend/next.config.js
COPY --from=builder /app/apps/frontend/package.json ./apps/frontend/package.json
COPY --from=builder /app/node_modules ./node_modules
WORKDIR /app/apps/frontend
ENV NODE_OPTIONS="--max-old-space-size=384"
EXPOSE 4200
CMD ["../../node_modules/.bin/next", "start", "-p", "4200"]

# ── orchestrator ──
FROM base AS orchestrator
COPY --from=builder /app/apps/orchestrator/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
ENV NODE_OPTIONS="--max-old-space-size=256"
ENV ORCHESTRATOR_PORT=3002
EXPOSE 3002
CMD ["node", "--experimental-require-module", "dist/main.js"]

# ── runtime ──
# Single image for all services. Set SERVICE=backend|frontend|orchestrator|db-init
FROM base AS runtime
COPY --from=builder /app/apps/backend/dist ./apps/backend/dist
COPY --from=builder /app/apps/frontend/.next ./apps/frontend/.next
COPY --from=builder /app/apps/frontend/public ./apps/frontend/public
COPY --from=builder /app/apps/frontend/next.config.js ./apps/frontend/next.config.js
COPY --from=builder /app/apps/frontend/package.json ./apps/frontend/package.json
COPY --from=builder /app/apps/orchestrator/dist ./apps/orchestrator/dist
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./
COPY --from=builder /app/.npmrc ./
COPY --from=builder /app/libraries/nestjs-libraries/src/database/prisma/schema.prisma ./libraries/nestjs-libraries/src/database/prisma/
ENV NODE_OPTIONS="--max-old-space-size=384"
CMD ["sh", "-c", "case $SERVICE in \
  backend) exec node --experimental-require-module apps/backend/dist/main.js ;; \
  frontend) exec node_modules/.bin/next start -p 4200 ;; \
  orchestrator) exec node --experimental-require-module apps/orchestrator/dist/main.js ;; \
  db-init) exec pnpm run prisma-db-push ;; \
  *) echo 'Set SERVICE=backend|frontend|orchestrator|db-init' && exit 1 ;; \
  esac"]
