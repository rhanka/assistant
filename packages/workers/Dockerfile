FROM node:24-alpine3.22 AS base
WORKDIR /app
# Security: Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001 -G nodejs
COPY packages/workers/package.json packages/workers/package-lock.json packages/workers/tsconfig.json ./
COPY packages/config/tsconfig.base.json ./

# Install all dependencies (including devDependencies for testing)
RUN npm ci --legacy-peer-deps
# Security: Audit dependencies for HIGH/CRITICAL vulnerabilities
RUN npm audit --audit-level=high

# Copy source code
COPY packages/workers/src ./src
COPY packages/workers/tests ./tests

# Security: Change ownership to non-root user
RUN chown -R nodejs:nodejs /app

# Build stage (production only)
FROM base AS build
# Exclude test files from build
RUN find src -name "*.test.ts" -delete && \
    find src -name "*.spec.ts" -delete
RUN npm run build

# Test stage
FROM base AS test
# Tests can run here with all dependencies available
USER nodejs
CMD ["npm", "run", "test:unit"]

# Development stage
FROM base AS dev
USER nodejs
CMD ["npm", "run", "dev"]

# Production stage
FROM node:24-alpine3.22 AS production
WORKDIR /app
# Security: Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001 -G nodejs
COPY packages/workers/package.json packages/workers/package-lock.json ./
COPY packages/config/tsconfig.base.json ./

# Install only production dependencies
RUN npm ci --only=production --legacy-peer-deps
# Security: Audit production dependencies for HIGH/CRITICAL vulnerabilities
RUN npm audit --audit-level=high

# Copy built application
COPY --from=build /app/dist ./dist

# Security: Change ownership to non-root user and set proper permissions
RUN chown -R nodejs:nodejs /app && \
    chmod -R 755 /app && \
    chmod -R 755 /app/dist

# Security: Switch to non-root user
USER nodejs

EXPOSE 3003
CMD ["npm", "run", "start"]

# Default target (for docker-compose compatibility)
FROM base AS default
USER nodejs
EXPOSE 3003
CMD ["npm", "run", "start"]
