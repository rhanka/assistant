FROM node:24-alpine3.22 AS base
WORKDIR /app
# Install OpenSSL and other dependencies for Prisma
RUN apk add --no-cache openssl
# Security: Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001 -G nodejs
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
COPY packages/api/tests ./tests

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

# Production stage
FROM node:24-alpine3.22 AS production
WORKDIR /app
# Install OpenSSL and other dependencies for Prisma
RUN apk add --no-cache openssl
# Security: Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001 -G nodejs
COPY packages/api/package.json packages/api/package-lock.json ./
COPY packages/config/tsconfig.base.json ./

# Install only production dependencies
RUN npm ci --only=production --legacy-peer-deps
# Security: Audit dependencies for HIGH/CRITICAL vulnerabilities
RUN npm audit --audit-level=high

# Copy built application and Prisma client
COPY --from=build /app/dist ./dist
COPY --from=build /app/node_modules/.prisma ./node_modules/.prisma
# Copy Prisma schema for migrations
COPY packages/api/prisma ./prisma

# Security: Change ownership to non-root user and set proper permissions
RUN chown -R nodejs:nodejs /app && \
    chmod -R 755 /app && \
    chmod -R 755 /app/dist && \
    chmod -R 755 /app/node_modules/.prisma && \
    chmod -R 644 /app/prisma

# Security: Switch to non-root user
USER nodejs

EXPOSE 3001
CMD ["npm", "run", "start"]
