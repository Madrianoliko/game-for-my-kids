#!/bin/sh
set -eu
if ! /usr/bin/gzip -dc "$SCRIPT_INPUT_FILE_1" > "$SCRIPT_OUTPUT_FILE_0"; then
    /bin/rm -f "$SCRIPT_OUTPUT_FILE_0"
    exit 1
fi
