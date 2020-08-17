FROM node:12.11-alpine
LABEL maintainer="Kubermatic <support@kubermatic.com>"

ENV PATH "$PATH:/app/node_modules/.bin/"
ENV NODE_PATH=/app/node_modules/

ADD package.json /app/
RUN cd app && yarn install --prod --non-interactive && yarn cache clean
