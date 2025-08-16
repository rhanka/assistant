FROM node:20
WORKDIR /app
COPY packages/ui/package.json packages/ui/tsconfig.json ./
COPY packages/config/tsconfig.base.json ./
RUN npm install --legacy-peer-deps
COPY packages/ui/src ./src
COPY packages/ui/svelte.config.js packages/ui/vite.config.ts ./
EXPOSE 5173
CMD ["npm", "run", "dev"]
