FROM node:20 AS base
WORKDIR /app
COPY packages/api/package.json packages/api/package-lock.json packages/api/tsconfig.json ./
COPY packages/config/tsconfig.base.json ./

# Install all dependencies (including devDependencies for testing)
RUN npm ci --legacy-peer-deps
# Security: Audit dependencies for HIGH/CRITICAL vulnerabilities
RUN npm audit --audit-level=high

# Copy source code and generate Prisma client
COPY packages/api/prisma ./prisma
RUN npx prisma generate
COPY packages/api/src ./src

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
FROM node:20 AS production
WORKDIR /app
COPY packages/api/package.json packages/api/package-lock.json ./
COPY packages/config/tsconfig.base.json ./

# Install only production dependencies
RUN npm ci --only=production --legacy-peer-deps
# Security: Audit production dependencies for HIGH/CRITICAL vulnerabilities
RUN npm audit --audit-level=high

# Copy built application and Prisma client
COPY --from=build /app/dist ./dist
COPY --from=build /app/node_modules/.prisma ./node_modules/.prisma
# Copy Prisma schema for migrations
COPY packages/api/prisma ./prisma

EXPOSE 3001
CMD ["npm", "run", "start"]
