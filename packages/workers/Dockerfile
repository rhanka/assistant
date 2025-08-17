FROM node:20
WORKDIR /app
COPY packages/workers/package.json ./
COPY packages/workers/tsconfig.json ./
COPY packages/config/tsconfig.base.json ./
RUN npm install --legacy-peer-deps
COPY packages/workers/src ./src
COPY packages/workers/tests ./tests
RUN npm run build
EXPOSE 3003
CMD ["npm", "run", "start"]
