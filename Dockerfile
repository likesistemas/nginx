FROM debian:10-slim AS ssl
WORKDIR /ssl/
RUN apt-get update && apt-get install -y libnss3-tools curl
RUN curl -JLO "https://dl.filippo.io/mkcert/latest?for=linux/amd64"
RUN chmod +x mkcert-v*-linux-amd64
RUN mv mkcert-v*-linux-amd64 /usr/local/bin/mkcert
RUN mkcert -key-file privkey.pem -cert-file fullchain.pem localhost 127.0.0.1 ::1

FROM debian:10-slim AS htpasswd
WORKDIR /
ARG PHP_FPM_PASSWORD=123456
RUN apt-get update && apt-get install apache2-utils -y
RUN htpasswd -bc fpm_passwd admin $PHP_FPM_PASSWORD
RUN htpasswd -bv fpm_passwd admin $PHP_FPM_PASSWORD

FROM debian:10-slim AS dockerize
ENV DOCKERIZE_VERSION v0.8.0
RUN apt-get update \
 && apt-get install -y wget \
 && wget -O - https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz | tar xzf - -C /usr/local/bin \
 && apt-get autoremove -yqq --purge wget && rm -rf /var/lib/apt/lists/*

FROM nginx:latest

ENV PORTA_PHP=9000
ENV TIMEOUT_PHP=60s

COPY --from=dockerize /usr/local/bin/dockerize /usr/local/bin/dockerize

ENV PUBLIC_HTML="/var/www/public"
ENV SRC_CONFIG_TEMPLATES="/etc/nginx-templetes/"
ENV SRC_CONFIG="/etc/nginx/"

RUN rm -Rf /etc/nginx/conf.d/
COPY config/ ${SRC_CONFIG_TEMPLATES}

COPY --from=htpasswd /fpm_passwd /etc/nginx/fpm_passwd
COPY www/fpm_status.html /var/php/status.html

COPY --from=ssl /ssl/ /etc/nginx/ssl/

EXPOSE 80 443

COPY sh/ /docker-entrypoint.d/
RUN chmod +x /docker-entrypoint.d/*-configure-nginx.sh \
 && chmod +x /docker-entrypoint.d/*-wait-php.sh

WORKDIR $PUBLIC_HTML