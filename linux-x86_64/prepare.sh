#!/bin/sh

set -e

BIN_DIR=$(realpath $(dirname $0))
if [ "x$(command -v clang)" != "x" ]; then
  CC=clang
elif [ "x$(command -v gcc)" != "x" ] ; then
  CC=gcc
else
  echo "Clang or GCC are needed"
  exit -1
fi

INC_DIRS=$($CC -xc -E -Wp,-v /dev/null 2>&1 | tr '\n' ' ' | sed 's/.*#include <\.\.\.> search starts here://' | sed 's/End of search list.*//' | sed -E 's/^\s*//' | sed -E 's/\s*$//' | sed -E 's/\s+/:/g')

if [ "x$C_INCLUDE_PATH" = "x" ]; then
  C_INCLUDE_PATH="$INC_DIRS"
else
  C_INCLUDE_PATH="$C_INCLUDE_PATH:$INC_DIRS"
fi

if [ "x$LD_LIBRARY_PATH" = "x" ]; then
  LD_LIBRARY_PATH="$BIN_DIR"
else
  LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$BIN_DIR"
fi

ENV_FILE=$BIN_DIR/env.sh
cat > $ENV_FILE <<EOF
export C_INCLUDE_PATH=$C_INCLUDE_PATH
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH
EOF

echo -e "Now load the env variable running:\n\nsource '$ENV_FILE'"
