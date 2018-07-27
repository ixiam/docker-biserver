#!/bin/sh

set -eu
export LC_ALL=C

if [ -n "${SETUP_JSON}" ]; then
	/opt/scripts/setup-biserver-multi.sh
else
	/opt/scripts/setup-biserver.sh
fi
