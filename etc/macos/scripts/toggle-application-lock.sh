#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR
# shellcheck disable=SC2155

# README
# This script automatically toggles read-only permissions for a set of apps
# to prevent them being updated automatically by their own update systems.
# Consecutive runs of this script will toggle those permissions back and forth.
#
# The following switches are available:
# -v: Print major commands being executed.
# -vv: Print major commands being executed and their output.
# --app-name: Only toggle this specific app.

set -Eeuo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
readonly ROOT_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"
VERBOSE="${VERBOSE:-0}"

source "$ROOT_DIR/etc/scripts/utils.sh"

parse_input_args () {
	while [[ $# -gt 0 ]]; do case $1 in
		--app-name) app_name="$2"; shift; shift;;
		-v) VERBOSE=1; shift;;
		*) shift;;
	esac; done
}

toggle_app_lock () {
	local apps_list=(
		"ares"
		"Azahar"
		"Brave Browser"
		"Bruno"
		"Docker"
		"Orion"
		"Google Chrome"
		"melonDS"
		"OBS"
		"Signal"
		"SkyEmu"
		"Spotify"
		"Visual Studio Code"
		"WhatsApp"
		"Xenia-edge"
		"Zed"
		"Zoom"
	)
	[[ -n ${app_name:-""} ]] && apps_list=("$app_name")

	for app in "${apps_list[@]}"; do
		local app_path="/Applications/${app}.app"
		[[ ! -d $app_path ]] && continue;

		local app_flags="$(run stat -f '%Sf' "$app_path")"

		if echo "$app_flags" | grep -q -E "schg|uchg"; then
			logi "Unlocking $app ..."
			run sudo chflags -R noschg "$app_path"
			run chflags -R nouchg "$app_path"
		else
			logi "Locking $app ..."
			run sudo chflags -R schg "$app_path"
			run chflags -R uchg "$app_path"
		fi
	done
}

parse_input_args "$@"
toggle_app_lock
