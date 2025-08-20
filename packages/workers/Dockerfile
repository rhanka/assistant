FROM node:24-alpine3.22 AS base
WORKDIR /app
COPY packages/workers/package.json packages/workers/package-lock.json packages/workers/tsconfig.json ./
COPY packages/config/tsconfig.base.json ./

# Install all dependencies (including devDependencies for testing)
RUN npm ci --legacy-peer-deps
# Security: Audit dependencies for HIGH/CRITICAL vulnerabilities
RUN npm audit --audit-level=high

# Copy source code
COPY packages/workers/src ./src
COPY packages/workers/tests ./tests

# Build stage (production only)
FROM base AS build
# Exclude test files from build
RUN find src -name "*.test.ts" -delete && \
    find src -name "*.spec.ts" -delete
RUN npm run build

# Test stage
FROM base AS test
# Tests can run here with all dependencies available
CMD ["npm", "run", "test:unit"]

# Production stage
FROM node:24-alpine3.22 AS production
WORKDIR /app
COPY packages/workers/package.json packages/workers/package-lock.json ./
COPY packages/config/tsconfig.base.json ./

# Install only production dependencies
RUN npm ci --only=production --legacy-peer-deps
# Security: Audit production dependencies for HIGH/CRITICAL vulnerabilities
RUN npm audit --audit-level=high

# Copy built application
COPY --from=build /app/dist ./dist
EXPOSE 3003
CMD ["npm", "run", "start"]

# Default target (for docker-compose compatibility)
FROM base AS default
EXPOSE 3003
CMD ["npm", "run", "start"]
