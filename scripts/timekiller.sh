#!/bin/bash

set -e

[[ -n $SERVETIME ]] || (echo "Set SERVETIME to the time the server should run"; exit 1)

# Say what is happening
echo -n "Starting $1 for $SERVETIME seconds at "
date

# Start process in background
exec $1 &

# Sleep for the specified time
sleep $SERVETIME

# Kill the background process and exit
kill -9 %1
