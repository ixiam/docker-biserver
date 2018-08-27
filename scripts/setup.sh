#!/bin/sh

set -eu
export LC_ALL=C

if [ -z "${SETUP_JSON-}" ]; then
	/opt/scripts/setup-biserver.sh
else
	/opt/scripts/setup-biserver-multi.sh
fi