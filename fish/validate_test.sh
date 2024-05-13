#!/usr/bin/env bash

# Depends on fish cmake test target outputs. Args 2, 3, and 4 should
# be the test performance log, cmake log, and test output respectively.

echo "$2:"
cat $2
echo "$3:"
cat $3
echo "$4:"
cat $4

if ! [ -f $2 ]; then
  echo "$2 does not exist."
  exit 1
fi
if ! [ -f $3 ]; then
  echo "$3 does not exist."
  exit 1
fi
if ! [ -f $4 ]; then
  echo "$4 does not exist."
  exit 1
fi

echo "Passed"
exit 0
