FROM node:20
WORKDIR /app
COPY package.json tsconfig.json ./
RUN npm install
COPY prisma ./prisma
RUN npx prisma generate
COPY src ./src
EXPOSE 3001
CMD ["npm", "run", "dev"]
