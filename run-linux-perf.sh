#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

BINARY_NAME=$1
if [ -z "$BINARY_NAME" ]; then
  echo "Usage: $0 <binary-name>"
  exit 1
fi

ARGUMENTS="$2"

sudo perf record -F 99 --call-graph dwarf -- ${BINARY_NAME} $ARGUMENTS
sudo perf script | swift demangle > ${BINARY_NAME}.perf
$SCRIPT_DIR/FlameGraph/stackcollapse-perf.pl ${BINARY_NAME}.perf | $SCRIPT_DIR/FlameGraph/flamegraph.pl > ${BINARY_NAME}.svg
