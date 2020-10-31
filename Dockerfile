FROM node:alpine3.10
WORKDIR /app
COPY package.json .
RUN npm install
COPY . .
EXPOSE 8080
CMD npm run build