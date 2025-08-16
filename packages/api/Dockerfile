FROM node:20
WORKDIR /app
COPY packages/api/package.json packages/api/tsconfig.json ./
COPY tsconfig.base.json ./
RUN npm install
COPY packages/api/prisma ./prisma
RUN npx prisma generate
COPY packages/api/src ./src
EXPOSE 3001
CMD ["npm", "run", "dev"]
