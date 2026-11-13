FROM node:20-alpine AS builder

WORKDIR /backend
COPY package.json package-lock.json ./
RUN npm ci --omit=dev && npm cache clean --force

FROM node:20-alpine AS prod

WORKDIR /backend

RUN addgroup -S backend && adduser -S backend -G backend

RUN apk add --no-cache dumb-init

COPY --from=builder /backend/node_modules ./node_modules
COPY src/ ./src/

RUN chown -R backend:backend /backend

USER backend

EXPOSE 5000

ENTRYPOINT ["dumb-init", "--"]
CMD ["node", "src/index.js"]