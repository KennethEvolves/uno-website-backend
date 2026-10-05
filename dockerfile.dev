FROM node:22-alpine

RUN apk update && apk add --no-cache build-base gcc autoconf automake zlib-dev libpng-dev bash vips-dev git
ARG NODE_ENV=development
ENV NODE_ENV=${NODE_ENV}

WORKDIR /opt/

RUN npm install -g pnpm@10.33.0

COPY package.json pnpm-lock.yaml ./

RUN pnpm install --frozen-lockfile

ENV PATH=/opt/node_modules/.bin:$PATH

WORKDIR /opt/app
COPY . .
RUN chown -R node:node /opt/app
USER node
EXPOSE 1337
CMD ["pnpm", "run", "develop"]