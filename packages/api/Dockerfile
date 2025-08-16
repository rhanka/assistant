FROM node:20
WORKDIR /app
COPY packages/api/package.json packages/api/tsconfig.json ./
COPY tsconfig.base.json ./
RUN npm install --legacy-peer-deps
COPY packages/api/prisma ./prisma
RUN npx prisma generate
COPY packages/api/src ./src
RUN npm run build
EXPOSE 3001
CMD ["npm", "run", "start"]
