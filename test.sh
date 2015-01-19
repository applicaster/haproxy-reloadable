#!/bin/bash

PWD=`pwd`
TEST_CONFIG_DIR="$PWD/test/config"

cleanup() {
  docker kill haproxy-reloadable-test > /dev/null
  sleep 1
  docker rm haproxy-reloadable-test > /dev/null
}

# trap cleanup EXIT
cleanup

# Prepare config for first test
sed -i '' '/^#.*monitor-uri/s/^#//g'  "$TEST_CONFIG_DIR/haproxy.cfg"

echo "Running HAProxy"
C_PID=`docker run -d \
  --name haproxy-reloadable-test \
  -p 80 \
  -v "$TEST_CONFIG_DIR:/usr/local/etc/haproxy" \
  applicaster/haproxy-reloadable`

HOST=`boot2docker ip`
PORT=`docker port haproxy-reloadable-test 80 | tr ':' ' ' | awk '{print \$2}'`
URI="http://$HOST:$PORT/test"

echo "Check first configuration"
STATUS_CODE=`curl -s -o /dev/null -w "%{http_code}" $URI`
if [ "$STATUS_CODE" -ne "200" ]
then
  echo "expected status code 200, got $STATUS_CODE"
fi

# Prepare config for the second test
sed -i '' '/monitor-uri/ s/^#*/#/'  "$TEST_CONFIG_DIR/haproxy.cfg"

# Send reload signal
docker kill -s USR2 haproxy-reloadable-test > /dev/null
sleep 3

echo "Check second configuration"
STATUS_CODE=`curl -s -o /dev/null -w "%{http_code}" $URI`
if [ "$STATUS_CODE" -ne "503" ]
then
  echo "expected status code 503, got $STATUS_CODE"
fi
