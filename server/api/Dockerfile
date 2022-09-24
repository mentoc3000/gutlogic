FROM node:16.17.0-alpine3.16

WORKDIR /usr/src/app

COPY package*.json ./

RUN npm ci

COPY . .

ENV GOOGLE_APPLICATION_CREDENTIALS /usr/src/app/firebase-adminsdk.json

EXPOSE 8080
CMD ["npm", "run", "start"]
