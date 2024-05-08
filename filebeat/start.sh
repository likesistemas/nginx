#!/bin/bash

if [ -z "${FILEBEAT_CLOUD_ID}" ] || [ -z "${FILEBEAT_CLOUD_AUTH}" ]; then
    echo "FILEBEAT_CLOUD_ID ou FILEBEAT_CLOUD_AUTH não configurado. Abortando..."
    exit 0
fi

dockerize -template /etc/filebeat/filebeat.yml:/etc/filebeat/filebeat.yml

filebeat modules enable nginx

if [ "${FILEBEAT_SETUP}" = "true" ]; then
    filebeat setup
fi

service filebeat start