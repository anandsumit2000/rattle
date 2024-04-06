## Stage 1: BUILD

FROM node:slim as BUILD_IMAGE

WORKDIR /app

COPY . /app

RUN npm install

CMD [ "npm", "run", "build" ]

## Stage 2: 

FROM node:slim as DEPLOYMENT_IMAGE

WORKDIR /app

COPY --from=BUILD_IMAGE /app/ /app/

COPY package.json .

COPY vite.config.js .

EXPOSE 5000

CMD [ "npm", "run", "preview" ]
