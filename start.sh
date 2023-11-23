#!/bin/bash


service cron start
source getcerts.sh
echo "****starting nginx"
nginx -g 'daemon off;'
echo "****ending nginx"