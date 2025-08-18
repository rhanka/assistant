FROM node:20
WORKDIR /app
COPY packages/scheduler/package.json ./
COPY packages/scheduler/tsconfig.json ./
COPY packages/config/tsconfig.base.json ./
RUN npm install --legacy-peer-deps
# Security: Audit dependencies for HIGH/CRITICAL vulnerabilities
RUN npm audit --audit-level=high
COPY packages/scheduler/src ./src
COPY packages/scheduler/tests ./tests
RUN npm run build
EXPOSE 3002
CMD ["npm", "run", "start"]
