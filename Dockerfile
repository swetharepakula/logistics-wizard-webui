FROM node:6-alpine

ADD blueprints /app/blueprints
ADD config /app/config
ADD server /app/server
ADD src /app/src
ADD bin /app/bin

ADD package.json /app
ADD nodemon.json /app
ADD .editorconfig /app
ADD .eslintignore /app
ADD .reduxrc /app
ADD .babelrc /app
ADD .storybook /app/.storybook


RUN apk add --no-cache --virtual .gyp python make g++
RUN cd /app; npm install
RUN npm install http-server -g

ENV NODE_ENV development
ENV PORT 8080
EXPOSE 8080

WORKDIR "/app"
CMD npm run deploy:prod && cd dist && http-server
