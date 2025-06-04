#!/bin/bash
# WARNING: DO NOT USE THIS IN A PRODUCTION SERVER (unless....)

echo "WARNING: MEMORY EATER IS STARTING!"

MEMORY_HOG=()

while true; do
    MEMORY_HOG+=("$(head -c 10M </dev/zero | tr '\0' 'x')")
    echo "Appending 10M chunks to memory"
    sleep 0.5
done
