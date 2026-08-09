#!/usr/bin/env /bin/bash
# shellcheck disable=SC2155

set -Eeuo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
readonly ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
VERBOSE="${VERBOSE:-0}"

source "$SCRIPT_DIR/env.sh"
source "$ROOT_DIR/etc/scripts/utils.sh"

readonly ACTMON_KEY="com.apple.ActivityMonitor"
readonly ACTMON_FILE="$SCRIPT_DIR/etc/${ACTMON_KEY}.plist"
readonly ALTTAB_KEY="com.lwouis.alt-tab-macos"
readonly ALTTAB_FILE="$ROOT_DIR/etc/macos/${ALTTAB_KEY}.plist"
readonly BETTERDISPLAY_KEY="pro.betterdisplay.BetterDisplay"
readonly BETTERDISPLAY_FILE="$SCRIPT_DIR/etc/${BETTERDISPLAY_KEY}.plist"
readonly MACMOUSEFIX_KEY="com.nuebling.mac-mouse-fix"
readonly MACMOUSEFIX_FILE="$ROOT_DIR/etc/macos/${MACMOUSEFIX_KEY}.plist"
readonly MACMOUSEFIX_FILE_SOURCE="$HOME/Library/Application Support/${MACMOUSEFIX_KEY}/config.plist"
readonly OBS_DIR="$SCRIPT_DIR/etc/obs/"
readonly OBS_DIR_SOURCE="$HOME/Library/Application Support/obs-studio/basic"

# By default this script will install the settings.
# Call it with the `--save` switch to have it export the settings instead.
mode="install"

parse_input_args () {
	while [[ $# -gt 0 ]]; do case $1 in
		--save) mode="save"; shift;;
		-v) VERBOSE=1; shift;;
		*) shift;;
	esac; done
}

install_app_settings () {
	logi "Installing applications settings ..."
	run defaults import "$ACTMON_KEY" "$ACTMON_FILE"
	run defaults import "$ALTTAB_KEY" "$ALTTAB_FILE"
	run defaults import "$BETTERDISPLAY_KEY" "$BETTERDISPLAY_FILE"
	run cp "$MACMOUSEFIX_FILE" "$MACMOUSEFIX_FILE_SOURCE"
	# run rm -rf "$OBS_DIR_SOURCE"/*
	# run cp -R "$OBS_DIR"* "$OBS_DIR_SOURCE"
	return 0
}

save_app_settings () {
	logi "Exporting applications settings ..."
	run defaults export "$ACTMON_KEY" "$ACTMON_FILE"
	run defaults export "$ALTTAB_KEY" "$ALTTAB_FILE"
	run defaults export "$BETTERDISPLAY_KEY" "$BETTERDISPLAY_FILE"
	run cp "$MACMOUSEFIX_FILE_SOURCE" "$MACMOUSEFIX_FILE"
	run rm -rf "$OBS_DIR"
	run cp -R "$OBS_DIR_SOURCE" "$OBS_DIR"
	run find "$OBS_DIR" -name "*.bak" -type f -delete
	return 0
}

validate_host
parse_input_args "$@"

if [[ $mode = save ]]; then
	save_app_settings
else
	install_app_settings
fi
