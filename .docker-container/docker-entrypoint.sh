#!/bin/bash
set -e
if [ -f tmp/pids/server.pid ]; then
  rm tmp/pids/server.pid
fi

echo $API_PORT
# bin/rails s -p $API_PORT -b $BIND_PORT

bin/dev

exec "$@"
