FROM node:alpine3.10 as BUILD
WORKDIR /app
COPY package.json .
RUN npm install
COPY . .
RUN npm run build

FROM nginx as START
EXPOSE 80
COPY --from=BUILD /app/dist /usr/share/nginx/html

