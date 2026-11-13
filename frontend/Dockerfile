FROM node:20-alpine AS builder

WORKDIR /frontend
COPY package.json package-lock.json ./

# https://www.baeldung.com/ops/npm-install-vs-npm-ci 
RUN npm ci && npm cache clean --force # results in node_modules dir

# do not worry node_modules is ignored in .dockerignore
COPY . .
RUN npm run build # gives dist/ directory with index.html and other static assets

FROM nginx:1.30-alpine AS prod

# remove default site nginx conf, html files and copy custom config, html files
RUN rm -rf /etc/nginx/conf.d/default.conf /usr/share/nginx/html/*
COPY --from=builder /frontend/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=builder /frontend/dist /usr/share/nginx/html

# setup to run nginx as non-root user
RUN <<EOF
chown -R nginx:nginx /usr/share/nginx/html
chown -R nginx:nginx /var/cache/nginx
chown -R nginx:nginx /var/log/nginx
touch /var/run/nginx.pid
chown -R nginx:nginx /var/run/nginx.pid
EOF

USER nginx

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]