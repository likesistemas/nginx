FROM debian:10-slim AS htpasswd
WORKDIR /
ARG PHP_FPM_PASSWORD=123456
RUN apt update && apt install apache2-utils -y
RUN htpasswd -bc fpm_passwd admin $PHP_FPM_PASSWORD
RUN htpasswd -bv fpm_passwd admin $PHP_FPM_PASSWORD

FROM nginx:latest

ENV PORTA_PHP=9000
ENV TIMEOUT_PHP=60s

ENV DOCKERIZE_VERSION v0.6.1
RUN apt-get update && apt-get install -y wget \
    && wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz

ENV PUBLIC_HTML="/var/www/public"
ENV SRC_CONFIG_TEMPLATES="/etc/nginx-templetes/"
ENV SRC_CONFIG="/etc/nginx/"

RUN rm -Rf /etc/nginx/conf.d/
COPY config/ ${SRC_CONFIG_TEMPLATES}

COPY --from=htpasswd /fpm_passwd /etc/nginx/fpm_passwd
COPY www/fpm_status.html /var/php/status.html

EXPOSE 80 443

COPY sh/ /docker-entrypoint.d/
RUN chmod +x /docker-entrypoint.d/*-configure-nginx.sh \
 && chmod +x /docker-entrypoint.d/*-wait-php.sh

WORKDIR $PUBLIC_HTML