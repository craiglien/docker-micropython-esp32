#!/bin/bash

set -e

[[ -n $OUTIP ]] || (echo "Set OUTIP to the IP address of the host"; exit 1)

# Get a random directory name
dirn=`python2 -c 'import uuid; print uuid.uuid4()' | head -c8`

# Make that directory
mkdir -p "srv/${dirn}"

# Copy firmware
cp micropython/ports/esp32/build/firmware.bin srv/${dirn}

# Make directory unreable
chmod 111 srv

# Change to serve from that directory
cd srv

# Server firmware
echo "Pull firmware here ----> http://${OUTIP}:8000/${dirn}/firmware.bin"
python -m SimpleHTTPServer 8000

