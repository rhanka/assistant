FROM node:20
WORKDIR /app
COPY packages/workers/package.json ./
COPY packages/workers/tsconfig.json ./
COPY packages/config/tsconfig.base.json ./
RUN npm install --legacy-peer-deps
# Security: Audit dependencies for HIGH/CRITICAL vulnerabilities
RUN npm audit --audit-level=high
COPY packages/workers/src ./src
COPY packages/workers/tests ./tests
RUN npm run build
EXPOSE 3003
CMD ["npm", "run", "start"]
