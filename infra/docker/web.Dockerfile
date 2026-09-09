FROM node:20-alpine AS builder

WORKDIR /app

COPY package.json /app/package.json
COPY apps/web/package.json /app/apps/web/package.json
COPY packages/shared-types/package.json /app/packages/shared-types/package.json

RUN npm install

COPY apps/web /app/apps/web
COPY packages/shared-types /app/packages/shared-types

WORKDIR /app/apps/web

RUN npm run build

FROM node:20-alpine AS runner

ENV NODE_ENV=production
ENV PORT=3000
ENV HOSTNAME=0.0.0.0

WORKDIR /app

COPY --from=builder /app/apps/web/.next/standalone ./
COPY --from=builder /app/apps/web/.next/static ./.next/static

EXPOSE 3000

CMD ["node", "server.js"]
