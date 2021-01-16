#!/bin/bash

# This script is used by terraform external data source[1] to parse input as
# valid json.
#
# While terraform has a standard function to decode json, if it fails, it will
# print the failed input. Therefore, we are not able to use the standard decoder
# on secrets or else the value of the secret is printed to the console.
#
# [1] https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/data_source#processing-json-in-shell-scripts

SECRET_NAME=$1
SECRET_VALUE=$2

set +e
echo "$SECRET_VALUE" | python -m json.tool >/dev/null
EXIT_CODE=$?
set -e

if [[ "$EXIT_CODE" -eq 0 ]]
then
  echo "$SECRET_VALUE"; exit 0;
else
  SECRET_VALUE_SIZE=$(echo $SECRET_VALUE | wc -c | awk '{ foo = $1 / 1024 ; print foo "kb" }')
  >&2 echo "The secret "$SECRET_NAME" is $SECRET_VALUE_SIZE and did not parse as valid json"; exit 1;
fi
