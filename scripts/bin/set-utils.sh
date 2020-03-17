#!/bin/sh

set -eu
export LC_ALL=C

# Escape strings in sed
# See: https://stackoverflow.com/a/29613573
quoteRe() { printf -- '%s' "${1-}" | sed -e 's/[^^]/[&]/g; s/\^/\\^/g; $!a'\\''"$(printf '\n')"'\\n' | tr -d '\n'; }
quoteSubst() { printf -- '%s' "${1-}" | sed -e ':a' -e '$!{N;ba' -e '}' -e 's/[&/\]/\\&/g; s/\n/\\&/g'; }

# Check if a string matches a pattern
matches() { printf -- '%s' "${1:?}" | grep -q "${2:?}"; }

# Print log messages
logInfo() { printf -- '[INFO] %s\n' "$@"; }
logWarn() { >&2 printf -- '[WARN] %s\n' "$@"; }
logFail() { >&2 printf -- '[FAIL] %s\n' "$@"; }

# Enables a service
runitEnSv() {
	svdir=/usr/share/biserver/service
	ln -rs "${svdir:?}"/available/"${1:?}" "${svdir:?}"/enabled/
}

# Disables a service
runitDisSv() {
	svdir=/usr/share/biserver/service
	unlink "${svdir:?}"/enabled/"${1:?}"
}

# Runs a command redirecting its output to stdout and a file while keeping its exit code
runAndLog() {
	runCmd=${1:?}
	logFile=${2:?}

	logPipe=$(mktemp -u)
	mkfifo -m 600 "${logPipe:?}"

	tee "${logFile:?}" < "${logPipe:?}" & teePid=$!
	${runCmd:?} > "${logPipe:?}" 2>&1; exitCode=$?
	rm -f "${logPipe:?}"; wait "${teePid:?}"

	return "${exitCode:?}"
}
