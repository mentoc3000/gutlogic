FROM node:16.17.0-alpine3.16

WORKDIR /usr/src/app

COPY package*.json ./

RUN npm ci

COPY . .

# Allow writing to irritants db file to support temperary tables
RUN chmod a+rw ./data
RUN chmod a+rw ./data/irritants.sqlite3

ENV GOOGLE_APPLICATION_CREDENTIALS /usr/src/app/firebase-adminsdk.json

EXPOSE 8080
CMD ["npm", "run", "start"]
