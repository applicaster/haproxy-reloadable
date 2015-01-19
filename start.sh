#!/bin/bash

PID_FILE=/var/run/haproxy.pid
CFG_FILE=/usr/local/etc/haproxy/haproxy.cfg
CMD=haproxy

$CMD -p $PID_FILE -f $CFG_FILE -Ds &
HAPROXY_PID=$!

sleep 0.5

echo "Started HAProxy $HAPROXY_PID"
echo "in PID file: $(cat $PID_FILE)"

reload() {
  CHILD_PIDS=`cat $PID_FILE`
  echo "Reloading HAProxy process $HAPROXY_PID ($CHILD_PIDS)"
  $CMD -p $PID_FILE -f $CFG_FILE -Ds -sf $CHILD_PIDS &
  HAPROXY_PID=$!
}

cleanup() {
  kill $(cat $PID_FILE)
}

trap reload SIGUSR2
trap cleanup EXIT

while true; do
  wait $HAPROXY_PID
  echo "Parent HAProxy closed $HAPROXY_PID"
  sleep 1
  cat "/proc/$HAPROXY_PID/cmdline" > /dev/null || exit 0
done