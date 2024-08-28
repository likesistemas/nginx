#!/bin/bash

step() {
  echo -e "\e[30mnginx\e[0m >> \e[33m${1}\e[0m"
}

mkdir -p ${SRC_CONFIG}
cp -R ${SRC_CONFIG_TEMPLATES}/. ${SRC_CONFIG}

PASTA_NGINX_SITE=${SRC_CONFIG}/site.d;
PASTA_NGINX_CONF=${SRC_CONFIG}/conf.d;
PASTA_NGINX_INCLUDE=${SRC_CONFIG}/include.d;

if [ -d "/var/nginx/conf.d/" ]; then
	step "Copiando config extras...";
	cp -Rv /var/nginx/conf.d/*.conf ${PASTA_NGINX_CONF}
fi;

if [ -d "/var/nginx/site.d/extras/" ]; then
	step "Copiando config site.d extras...";
	cp -Rv /var/nginx/site.d/extras/*.conf ${PASTA_NGINX_SITE}/extras/
fi;

# CONFIGURANDO LIMITS
if [ -n "$LIMIT_NO_FILE" ]; then
	step "Configurando Limits '${LIMIT_NO_FILE}'...";
	sed -i "s/worker_rlimit_nofile 1024;/worker_rlimit_nofile ${LIMIT_NO_FILE};/g" ${SRC_CONFIG}/nginx.conf;
fi;

# CONFIGURANDO HOST\PORTA PHP
if [ -n "$HOST_PHP" ]; then
	step "Configurando Host\Porta PHP...";

	if [ -n "$EXTENSAO_PHP" ]; then	
		sed -i "14a		location ~ \.php$ { include site.d/php.conf; }" ${PASTA_NGINX_SITE}/default.conf;
	else
		sed -i "12a		include site.d/php.conf;" ${PASTA_NGINX_SITE}/default.conf;
	fi;

	if [ -n "$HOST_PHP" ]; then
		sed -i "s/fastcgi_pass php:/fastcgi_pass ${HOST_PHP}:/g" ${PASTA_NGINX_SITE}/php.conf;
	fi;

	if [ -n "$PORTA_PHP" ]; then
		sed -i "s/9000/${PORTA_PHP}/g" ${PASTA_NGINX_SITE}/php.conf;
	fi;

	if [ -n "$INDEX_PHP" ]; then
		sed -i "s/9000/${PORTA_PHP}/g" ${PASTA_NGINX_SITE}/php.conf;
	fi;

	cat ${PASTA_NGINX_SITE}/php.conf;
	echo -e "\n\n";
fi;

# INDEX FILE
if [ -n "$INDEX_FILE" ]; then
  sed -i "s/sistema\.php/${INDEX_FILE}/g" ${PASTA_NGINX_SITE}/tryfiles.conf;
  sed -i "s/sistema\.php/${INDEX_FILE}/g" ${PASTA_NGINX_SITE}/rewrite.conf;
  sed -i "s/sistema\.php/${INDEX_FILE}/g" ${PASTA_NGINX_SITE}/php.conf;
fi;

# CONFIGURANDO TRY FILES
if [ "$TRYFILES" == "1" ]; then
	step "Configurando tryfiles...";
	sed -i "12a		include site.d/tryfiles.conf;" ${PASTA_NGINX_SITE}/default.conf;

	cat ${PASTA_NGINX_SITE}/tryfiles.conf;
	echo -e "\n\n";
fi;

# CONFIGURANDO REWRITE
if [ "$REWRITE" == "1" ]; then
	step "Configurando rewrite...";
	sed -i "14a		include site.d/rewrite.conf;" ${PASTA_NGINX_SITE}/default.conf;

	if [ -n "$REWRITE_ROLE" ]; then
		sed -i '1d' ${PASTA_NGINX_SITE}/rewrite.conf;
 		echo "rewrite ${REWRITE_ROLE};" >> ${PASTA_NGINX_SITE}/rewrite.conf;
	else
		if [ -n "$REWRITE_EXT" ]; then
			sed -i "s/php|html/${REWRITE_EXT}/g" ${PASTA_NGINX_SITE}/rewrite.conf;
		fi;
	fi;

	cat ${PASTA_NGINX_SITE}/rewrite.conf;
	echo -e "\n\n";
fi;

# CONFIGURANDO SSL
SSL_CERTIFICATE="/etc/nginx/ssl/fullchain.pem"
SSL_CERTIFICATE_KEY="/etc/nginx/ssl/privkey.pem"

if [ "${SSL}" == "true" ] && [ -f "${SSL_CERTIFICATE}" ] && [ -f "${SSL_CERTIFICATE_KEY}" ]; then
	step "Configurando SSL...";
	sed -i "10a		include site.d/ssl.conf;" ${PASTA_NGINX_SITE}/default.conf;
fi

# CONFIGURANDO PARA ELB
if [ -n "$REALIP_FROM" ]; then
	step "Configurando Real IP...";
	REALIP_FROM_CONFIG=${PASTA_NGINX_CONF}/realip.conf
	echo "real_ip_header X-Forwarded-For;" >> $REALIP_FROM_CONFIG
	echo "set_real_ip_from ${REALIP_FROM};" >> $REALIP_FROM_CONFIG
fi

if [ -z "$HTTP_IPV6" ] || [ "$HTTP_IPV6" == "true" ]; then
	step "Habilitando IPV6 do HTTP";
	echo "listen    [::]:80;" >> ${PASTA_NGINX_INCLUDE}/80.conf;

	cat ${PASTA_NGINX_INCLUDE}/80.conf;
	echo -e "\n\n";
fi;

if [ -z "$HTTPS_IPV6" ] || [ "$HTTPS_IPV6" == "true" ]; then
	step "Habilitando IPV6 do HTTPS";
	echo "listen [::]:443 ssl;" >> ${PASTA_NGINX_INCLUDE}/ssl.conf;

	cat ${PASTA_NGINX_INCLUDE}/ssl.conf;
	echo -e "\n\n";
fi;

step "Configurações do Nginx";
cat ${SRC_CONFIG}/nginx.conf;

echo -e "\n\n";
step "Configurações do Site";
cat ${PASTA_NGINX_SITE}/default.conf;