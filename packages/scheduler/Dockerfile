FROM node:20
WORKDIR /app
COPY packages/scheduler/package.json ./
COPY packages/scheduler/tsconfig.json ./
COPY packages/config/tsconfig.base.json ./
RUN npm install --legacy-peer-deps
COPY packages/scheduler/src ./src
RUN npm run build
EXPOSE 3002
CMD ["npm", "run", "start"]
