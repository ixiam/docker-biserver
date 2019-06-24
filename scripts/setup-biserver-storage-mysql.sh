#!/bin/sh

set -eu
export LC_ALL=C

. /opt/scripts/set-utils.sh
. /opt/scripts/set-utils-mysql.sh

########

if [ "${EXPORT_ENABLED}" = 'false' ]; then
	logInfo 'Checking MySQL connection...'
	CONNECTION_RETRIES=0; MAX_CONNECTION_RETRIES=60
	until
		mysqlConnect "${MYSQL_MAINTENANCE_DATABASE}" "${MYSQL_MAINTENANCE_USER}" "${MYSQL_MAINTENANCE_PASSWORD}" ||
		mysqlConnect "${MYSQL_JACKRABBIT_DATABASE}" "${MYSQL_JACKRABBIT_USER}" "${MYSQL_JACKRABBIT_PASSWORD}" ||
		mysqlConnect "${MYSQL_HIBERNATE_DATABASE}" "${MYSQL_HIBERNATE_USER}" "${MYSQL_HIBERNATE_PASSWORD}" ||
		mysqlConnect "${MYSQL_QUARTZ_DATABASE}" "${MYSQL_QUARTZ_USER}" "${MYSQL_QUARTZ_PASSWORD}"
	do
		if [ "${CONNECTION_RETRIES}" -gt "${MAX_CONNECTION_RETRIES}" ]; then
			logFail 'MySQL connection failed'
			exit 1
		fi
		CONNECTION_RETRIES=$((CONNECTION_RETRIES + 1))
		sleep 1
	done

	logInfo "Checking \"${MYSQL_JACKRABBIT_DATABASE}\" database..."
	if ! mysqlConnect "${MYSQL_JACKRABBIT_DATABASE}" "${MYSQL_JACKRABBIT_USER}" "${MYSQL_JACKRABBIT_PASSWORD}"; then
		logInfo "Creating \"${MYSQL_JACKRABBIT_DATABASE}\" database..."
		mysqlRun "${MYSQL_MAINTENANCE_DATABASE}" "${MYSQL_MAINTENANCE_USER}" "${MYSQL_MAINTENANCE_PASSWORD}" \
			< "${BISERVER_HOME}"/"${DATA_DIRNAME}"/mysql5/create_jcr_mysql.sql
	fi

	logInfo "Checking \"${MYSQL_HIBERNATE_DATABASE}\" database..."
	if ! mysqlConnect "${MYSQL_HIBERNATE_DATABASE}" "${MYSQL_HIBERNATE_USER}" "${MYSQL_HIBERNATE_PASSWORD}"; then
		logInfo "Creating \"${MYSQL_HIBERNATE_DATABASE}\" database..."
		mysqlRun "${MYSQL_MAINTENANCE_DATABASE}" "${MYSQL_MAINTENANCE_USER}" "${MYSQL_MAINTENANCE_PASSWORD}" \
			< "${BISERVER_HOME}"/"${DATA_DIRNAME}"/mysql5/create_repository_mysql.sql
	fi

	logInfo "Checking \"${MYSQL_QUARTZ_DATABASE}\" database..."
	if ! mysqlConnect "${MYSQL_QUARTZ_DATABASE}" "${MYSQL_QUARTZ_USER}" "${MYSQL_QUARTZ_PASSWORD}"; then
		logInfo "Creating \"${MYSQL_QUARTZ_DATABASE}\" database..."
		mysqlRun "${MYSQL_MAINTENANCE_DATABASE}" "${MYSQL_MAINTENANCE_USER}" "${MYSQL_MAINTENANCE_PASSWORD}" \
			< "${BISERVER_HOME}"/"${DATA_DIRNAME}"/mysql5/create_quartz_mysql.sql
	fi
fi
