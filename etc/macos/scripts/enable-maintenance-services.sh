#!/usr/bin/env bash
# shellcheck disable=SC2155

# README
# Enables a fundamental set of system services used to run updates in a macOS system.
# Once finished with the maintenance, run the appropriate disable-service-*.sh script.

set -Eeuo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
readonly ROOT_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"
VERBOSE="${VERBOSE:-0}"

source "$ROOT_DIR/etc/scripts/utils.sh"

parse_input_args () {
	while [[ $# -gt 0 ]]; do case $1 in
		-v) VERBOSE=1; shift;;
		*) shift;;
	esac; done
}

enable_maintenane_services () {
	logi "Enabling user services ..."
	local uid=$(id -u)
	run launchctl enable "gui/$uid/com.apple.appstoreagent"
	run launchctl enable "gui/$uid/com.apple.appstorecomponentsd"
	run launchctl enable "gui/$uid/com.apple.SoftwareUpdateNotificationManager"

	logi "Enabling system services ..."
	local macos_major_version="$(sw_vers -productVersion | grep -o '^\d*')"
	if [ $((macos_major_version)) -ne 26 ]; then
		run sudo launchctl enable "system/com.apple.security.syspolicy"
	fi
	run sudo launchctl enable "system/com.apple.appstored"
	run sudo launchctl enable "system/com.apple.AppStoreDaemon.StorePrivilegedODRService"
	run sudo launchctl enable "system/com.apple.AppStoreDaemon.StorePrivilegedTaskService"
	run sudo launchctl enable "system/com.apple.dasd"
	run sudo launchctl enable "system/com.apple.mobile.softwareupdated"
	run sudo launchctl enable "system/com.apple.softwareupdated"
}

parse_input_args "$@"
enable_maintenane_services
