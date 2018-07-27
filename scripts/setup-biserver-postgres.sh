#!/bin/sh

set -eu
export LC_ALL=C

. /opt/scripts/set-utils.sh

########

psqlRun() { PGPASSWORD="${DBCON_PASSWORD}" psql -h "${DBCON_HOST}" -p "${DBCON_PORT}" -U "${DBCON_USER}" -d "${DBCON_DATABASE}" "$@"; }
psqlDbExists() { psqlRun -lqt | cut -d'|' -f1 | grep -qw -- "$1"; }

########

logInfo 'Checking PostgreSQL connection...'
if ! nc -zv "${DBCON_HOST}" "${DBCON_PORT}" || ! psqlRun -c '\conninfo'; then
	logFail 'PostgreSQL connection failed'
	exit 1
fi

########

sed -r \
	-e "s|%DBCON_USER%|${DBCON_USER_SUBST}|g" \
	-e "s|%DBCON_JACKRABBIT_USER%|${DBCON_JACKRABBIT_USER_SUBST}|g" \
	-e "s|%DBCON_JACKRABBIT_PASSWORD%|${DBCON_JACKRABBIT_PASSWORD_SUBST}|g" \
	-e "s|%DBCON_JACKRABBIT_DATABASE%|${DBCON_JACKRABBIT_DATABASE_SUBST}|g" \
	"${BISERVER_HOME}"/"${DATA_DIRNAME}"/postgresql/create_jcr_postgresql.sql.tmpl \
	> "${BISERVER_HOME}"/"${DATA_DIRNAME}"/postgresql/create_jcr_postgresql.sql

logInfo "Checking \"${DBCON_JACKRABBIT_DATABASE}\" database..."
if ! psqlDbExists "${DBCON_JACKRABBIT_DATABASE}"; then
	logInfo "Creating \"${DBCON_JACKRABBIT_DATABASE}\" database..."
	psqlRun -f "${BISERVER_HOME}"/"${DATA_DIRNAME}"/postgresql/create_jcr_postgresql.sql
fi

########

sed -r \
	-e "s|%DBCON_USER%|${DBCON_USER_SUBST}|g" \
	-e "s|%DBCON_HIBERNATE_USER%|${DBCON_HIBERNATE_USER_SUBST}|g" \
	-e "s|%DBCON_HIBERNATE_PASSWORD%|${DBCON_HIBERNATE_PASSWORD_SUBST}|g" \
	-e "s|%DBCON_HIBERNATE_DATABASE%|${DBCON_HIBERNATE_DATABASE_SUBST}|g" \
	"${BISERVER_HOME}"/"${DATA_DIRNAME}"/postgresql/create_repository_postgresql.sql.tmpl \
	> "${BISERVER_HOME}"/"${DATA_DIRNAME}"/postgresql/create_repository_postgresql.sql

logInfo "Checking \"${DBCON_HIBERNATE_DATABASE}\" database..."
if ! psqlDbExists "${DBCON_HIBERNATE_DATABASE}"; then
	logInfo "Creating \"${DBCON_HIBERNATE_DATABASE}\" database..."
	psqlRun -f "${BISERVER_HOME}"/"${DATA_DIRNAME}"/postgresql/create_repository_postgresql.sql
fi

########

sed -r \
	-e "s|%DBCON_USER%|${DBCON_USER_SUBST}|g" \
	-e "s|%DBCON_QUARTZ_USER%|${DBCON_QUARTZ_USER_SUBST}|g" \
	-e "s|%DBCON_QUARTZ_PASSWORD%|${DBCON_QUARTZ_PASSWORD_SUBST}|g" \
	-e "s|%DBCON_QUARTZ_DATABASE%|${DBCON_QUARTZ_DATABASE_SUBST}|g" \
	"${BISERVER_HOME}"/"${DATA_DIRNAME}"/postgresql/create_quartz_postgresql.sql.tmpl \
	> "${BISERVER_HOME}"/"${DATA_DIRNAME}"/postgresql/create_quartz_postgresql.sql

logInfo "Checking \"${DBCON_QUARTZ_DATABASE}\" database..."
if ! psqlDbExists "${DBCON_QUARTZ_DATABASE}"; then
	logInfo "Creating \"${DBCON_QUARTZ_DATABASE}\" database..."
	psqlRun -f "${BISERVER_HOME}"/"${DATA_DIRNAME}"/postgresql/create_quartz_postgresql.sql
fi

########

sed -r \
	-e "s|%INSTANCE_ID%|${INSTANCE_ID_SUBST}|g" \
	-e "s|%DBCON_DATABASE_TYPE%|${DBCON_DATABASE_TYPE_SUBST}|g" \
	-e "s|%DBCON_FILESYSTEM_CLASS%|${DBCON_FILESYSTEM_CLASS_SUBST}|g" \
	-e "s|%DBCON_DATASTORE_CLASS%|${DBCON_DATASTORE_CLASS_SUBST}|g" \
	-e "s|%DBCON_PERSISTENCEMANAGER_CLASS%|${DBCON_PERSISTENCEMANAGER_CLASS_SUBST}|g" \
	-e "s|%DBCON_DRIVER_CLASS%|${DBCON_DRIVER_CLASS_SUBST}|g" \
	-e "s|%DBCON_JACKRABBIT_URL%|${DBCON_JACKRABBIT_URL_SUBST}|g" \
	-e "s|%DBCON_JACKRABBIT_USER%|${DBCON_JACKRABBIT_USER_SUBST}|g" \
	-e "s|%DBCON_JACKRABBIT_PASSWORD%|${DBCON_JACKRABBIT_PASSWORD_SUBST}|g" \
	"${BISERVER_HOME}"/"${SOLUTIONS_DIRNAME}"/system/jackrabbit/repository.xml.db.tmpl \
	> "${BISERVER_HOME}"/"${SOLUTIONS_DIRNAME}"/system/jackrabbit/repository.xml

########

sed -r \
	-e "s|%DBCON_DIALECT_CLASS%|${DBCON_DIALECT_CLASS_SUBST}|g" \
	-e "s|%DBCON_DRIVER_CLASS%|${DBCON_DRIVER_CLASS_SUBST}|g" \
	-e "s|%DBCON_HIBERNATE_URL%|${DBCON_HIBERNATE_URL_SUBST}|g" \
	-e "s|%DBCON_HIBERNATE_USER%|${DBCON_HIBERNATE_USER_SUBST}|g" \
	-e "s|%DBCON_HIBERNATE_PASSWORD%|${DBCON_HIBERNATE_PASSWORD_SUBST}|g" \
	"${BISERVER_HOME}"/"${SOLUTIONS_DIRNAME}"/system/hibernate/postgresql.hibernate.cfg.xml.tmpl \
	> "${BISERVER_HOME}"/"${SOLUTIONS_DIRNAME}"/system/hibernate/postgresql.hibernate.cfg.xml

########

sed -r \
	-e "s|%INSTANCE_ID%|${INSTANCE_ID_SUBST}|g" \
	-e "s|%DBCON_DRIVERDELEGATE_CLASS%|${DBCON_DRIVERDELEGATE_CLASS_SUBST}|g" \
	"${BISERVER_HOME}"/"${SOLUTIONS_DIRNAME}"/system/quartz/quartz.properties.db.tmpl \
	> "${BISERVER_HOME}"/"${SOLUTIONS_DIRNAME}"/system/quartz/quartz.properties
