#!/bin/sh

set -eu
export LC_ALL=C

. /opt/scripts/set-utils.sh
. /opt/scripts/set-utils-postgres.sh

########

if [ "${EXPORT_ENABLED}" = 'false' ]; then
	logInfo 'Checking PostgreSQL connection...'
	CONNECTION_RETRIES=0; MAX_CONNECTION_RETRIES=60
	until
		psqlConnect "${POSTGRES_MAINTENANCE_DATABASE}" "${POSTGRES_MAINTENANCE_USER}" "${POSTGRES_MAINTENANCE_PASSWORD}" ||
		psqlConnect "${POSTGRES_JACKRABBIT_DATABASE}" "${POSTGRES_JACKRABBIT_USER}" "${POSTGRES_JACKRABBIT_PASSWORD}" ||
		psqlConnect "${POSTGRES_HIBERNATE_DATABASE}" "${POSTGRES_HIBERNATE_USER}" "${POSTGRES_HIBERNATE_PASSWORD}" ||
		psqlConnect "${POSTGRES_QUARTZ_DATABASE}" "${POSTGRES_QUARTZ_USER}" "${POSTGRES_QUARTZ_PASSWORD}"
	do
		if [ "${CONNECTION_RETRIES}" -gt "${MAX_CONNECTION_RETRIES}" ]; then
			logFail 'PostgreSQL connection failed'
			exit 1
		fi
		CONNECTION_RETRIES=$((CONNECTION_RETRIES + 1))
		sleep 1
	done

	logInfo "Checking \"${POSTGRES_JACKRABBIT_DATABASE}\" database..."
	if ! psqlConnect "${POSTGRES_JACKRABBIT_DATABASE}" "${POSTGRES_JACKRABBIT_USER}" "${POSTGRES_JACKRABBIT_PASSWORD}"; then
		logInfo "Creating \"${POSTGRES_JACKRABBIT_DATABASE}\" database..."
		psqlRun "${POSTGRES_MAINTENANCE_DATABASE}" "${POSTGRES_MAINTENANCE_USER}" "${POSTGRES_MAINTENANCE_PASSWORD}" \
			-f "${BISERVER_HOME}"/"${DATA_DIRNAME}"/postgresql/create_jcr_postgresql.sql
	fi

	logInfo "Checking \"${POSTGRES_HIBERNATE_DATABASE}\" database..."
	if ! psqlConnect "${POSTGRES_HIBERNATE_DATABASE}" "${POSTGRES_HIBERNATE_USER}" "${POSTGRES_HIBERNATE_PASSWORD}"; then
		logInfo "Creating \"${POSTGRES_HIBERNATE_DATABASE}\" database..."
		psqlRun "${POSTGRES_MAINTENANCE_DATABASE}" "${POSTGRES_MAINTENANCE_USER}" "${POSTGRES_MAINTENANCE_PASSWORD}" \
			-f "${BISERVER_HOME}"/"${DATA_DIRNAME}"/postgresql/create_repository_postgresql.sql
	fi

	logInfo "Checking \"${POSTGRES_QUARTZ_DATABASE}\" database..."
	if ! psqlConnect "${POSTGRES_QUARTZ_DATABASE}" "${POSTGRES_QUARTZ_USER}" "${POSTGRES_QUARTZ_PASSWORD}"; then
		logInfo "Creating \"${POSTGRES_QUARTZ_DATABASE}\" database..."
		psqlRun "${POSTGRES_MAINTENANCE_DATABASE}" "${POSTGRES_MAINTENANCE_USER}" "${POSTGRES_MAINTENANCE_PASSWORD}" \
			-f "${BISERVER_HOME}"/"${DATA_DIRNAME}"/postgresql/create_quartz_postgresql.sql
	fi
fi
