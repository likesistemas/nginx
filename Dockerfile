FROM nginx:latest

ENV PORTA_PHP=9000
ENV TIMEOUT_PHP=60s

ENV DOCKERIZE_VERSION v0.6.1
RUN apt-get update && apt-get install -y wget \
    && wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz

ENV PUBLIC_HTML="/var/www/public"

COPY nginx.conf /var/www/nginx/
COPY conf.d/ /var/www/nginx/conf.d/
COPY include.d/ /var/www/nginx/include.d/
COPY site.d/ /var/www/nginx/site.d/
COPY ssl/ /var/www/nginx/ssl/

EXPOSE 80 443

COPY sh/ /usr/local/bin/
RUN chmod +x /usr/local/bin/configure-nginx \
 && chmod +x /usr/local/bin/renewssl \
 && chmod +x /usr/local/bin/start

CMD start