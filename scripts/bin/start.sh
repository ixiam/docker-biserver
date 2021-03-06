#!/bin/sh

set -eu
export LC_ALL=C

# shellcheck disable=SC1091
. /usr/share/biserver/bin/set-utils.sh

########

export LD_LIBRARY_PATH="${LD_LIBRARY_PATH-}:${CATALINA_HOME:?}/lib"
# shellcheck disable=SC2155
export CATALINA_OPTS="$(cat <<-EOF
	-DDI_HOME="${BISERVER_HOME:?}"/"${SOLUTIONS_DIRNAME:?}"/system/kettle/ \
	-Dsun.rmi.dgc.client.gcInterval=3600000 \
	-Dsun.rmi.dgc.server.gcInterval=3600000 \
	-Dfile.encoding=utf8 \
	-Xms${CATALINA_OPTS_JAVA_XMS:?} \
	-Xmx${CATALINA_OPTS_JAVA_XMX:?} \
	${CATALINA_OPTS_EXTRA?}
EOF
)"

logInfo "Starting Pentaho BI Server..."
cd "${CATALINA_HOME:?}"/bin
exec ./catalina.sh run
