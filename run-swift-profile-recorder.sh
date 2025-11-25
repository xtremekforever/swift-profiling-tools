#!/bin/bash

BINARY_NAME=$1
if [ -z "$BINARY_NAME" ]; then
  echo "Usage: $0 <binary-name>"
  exit 1
fi

ARGUMENTS="$2"

NUMBER_OF_SAMPLES=${NUMBER_OF_SAMPLES:=1000}
TIME_INTERVAL=${TIME_INTERVAL:=10}

# Cleanup old sock
rm /tmp/${BINARY_NAME}.sock

echo "Running ${BINARY_NAME} with ProfileRecorderServer enabled..."
PROFILE_RECORDER_SERVER_URL_PATTERN=unix:///tmp/${BINARY_NAME}.sock ${BINARY_NAME} $ARGUMENTS &

# Give some time for the app to start
sleep 1s

echo "Grabbing profile with ${NUMBER_OF_SAMPLES} samples and ${TIME_INTERVAL}ms interval..."
curl --unix-socket /tmp/${BINARY_NAME}.sock \
    -sd "{\"numberOfSamples\":${NUMBER_OF_SAMPLES},\"timeInterval\":\"${TIME_INTERVAL}ms\"}" \
    http://localhost/sample | swift demangle --compact > ${BINARY_NAME}.perf
echo "Profile saved to ${BINARY_NAME}.perf"

pkill -P $$

# Cleanup old sock
rm /tmp/${BINARY_NAME}.sock
