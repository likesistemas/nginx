#!/bin/bash

dockerize -template /etc/filebeat/filebeat.yml:/etc/filebeat/filebeat.yml

filebeat modules enable nginx

if [ "${FILEBEAT_SETUP}" = "true" ]; then
    filebeat setup
fi

service filebeat start
start