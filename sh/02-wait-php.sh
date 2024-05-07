#!/bin/bash

if [ -n "$HOST_PHP" ]; then
	dockerize \
		-wait tcp://${HOST_PHP}:${PORTA_PHP} \
		-timeout ${TIMEOUT_PHP} \
	&& start_nginx
else
	start_nginx
fi