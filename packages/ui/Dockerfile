FROM node:20 AS base
WORKDIR /app
COPY packages/ui/package.json packages/ui/package-lock.json ./
COPY packages/config/tsconfig.base.json ./

# Install all dependencies (including devDependencies for testing)
RUN npm ci --legacy-peer-deps

# Copy source code
COPY packages/ui/src ./src
COPY packages/ui/svelte.config.js packages/ui/vite.config.ts packages/ui/tsconfig.json ./

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
COPY packages/ui/package.json packages/ui/package-lock.json ./
COPY packages/config/tsconfig.base.json ./

# Install only production dependencies
RUN npm ci --only=production --legacy-peer-deps

# Copy built application
COPY --from=build /app/build ./build

EXPOSE 5173
CMD ["npm", "run", "preview"]
