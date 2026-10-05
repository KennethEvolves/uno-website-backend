FROM node:22-alpine AS build

RUN apk update && apk add --no-cache build-base gcc autoconf automake zlib-dev libpng-dev bash vips-dev git python3 > /dev/null 2>&1

WORKDIR /opt/app

RUN npm install -g pnpm@10.33.0

RUN echo "node-linker=hoisted" > .npmrc

COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
ENV SHARP_IGNORE_GLOBAL_LIBVIPS=1
RUN pnpm install --frozen-lockfile

COPY . .
ENV NODE_ENV=production
RUN pnpm run build

FROM node:22-alpine

RUN apk add --no-cache vips-dev
ENV NODE_ENV=production

WORKDIR /opt/app

COPY --from=build /opt/app/node_modules ./node_modules
COPY --from=build /opt/app/dist ./dist
COPY --from=build /opt/app/database ./database
COPY --from=build /opt/app/public ./public
COPY --from=build /opt/app/src ./src
COPY --from=build /opt/app/package.json ./package.json
COPY --from=build /opt/app/tsconfig.json ./tsconfig.json

RUN chown -R node:node /opt/app
USER node

EXPOSE 1337

HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD wget --quiet --tries=1 --spider http://localhost:1337/_health || exit 1

CMD ["npm", "run", "start"]