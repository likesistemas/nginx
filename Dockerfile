FROM nginx:latest

ENV PUBLIC_HTML="/var/www/public"
ENV AUTO_CLONE_GIT="s"
ENV AUTO_REFRESH_GIT="s"

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

CMD /usr/local/bin/start