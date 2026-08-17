#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR
# shellcheck disable=SC2155

# README
# This script installs/uninstalls the SkyEmu emulator.
#
# The following switches are available:
# -v: Print major commands being executed.
# -vv: Print major commands being executed and their output.
# --install-dir: Directory where the SkyEmu.app program is going to be installed.
#	Defaults to "/Applications".
# --uninstall: Uninstall the SkyEmu.app plus its cached files.
# --version: Select a specific version of SkyEmu to be installed.
# 	If no version is explicitly set or it's set to "latest", this script will
# 	query and use the latest one. All available version can be found here:
#	https://github.com/skylersaleh/SkyEmu/releases

set -Eeuo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
readonly ROOT_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"
readonly SKYEMU_DOWNLOAD_DIR="$TMPDIR/skyemu"
readonly SKYEMU_REPO="skylersaleh/SkyEmu"
VERBOSE="${VERBOSE:-0}"
skyemu_install_dir="/Applications"
uninstall=0
version=""

source "$ROOT_DIR/etc/scripts/utils.sh"

cleanup () {
	run hdiutil detach "/Volumes/SkyEmu" || true
	run rm -rf "$SKYEMU_DOWNLOAD_DIR"
}

parse_input_args () {
	while [[ $# -gt 0 ]]; do case $1 in
		--install-dir) skyemu_install_dir="$2"; shift; shift;;
		--uninstall) uninstall=1; shift;;
		--version) version="$2"; shift; shift;;
		-v) VERBOSE=1; shift;;
		*) shift;;
	esac; done
}

check_preconds () {
	logi "Checking pre-conditions ..."

	if ! which -s curl; then
		loge "\`curl\` is required to download SkyEmu."
		exit 1
	fi

	if [[ ! -d $skyemu_install_dir ]]; then
		loge "\$skyemu_install_dir is referencing a location that's not a directory: '$skyemu_install_dir'."
		exit 1
	fi
}

uninstall_skyemu () {
	logi "Uninstalling SkyEmu ..."
	run rm -rf "/$skyemu_install_dir/SkyEmu.app"
	run rm -rf "$HOME/Library/Application Support/Sky/SkyEmu"
}

install_skyemu () {
	if [[ -z $version || $version == "latest" ]]; then
		logi "Querying SkyEmu's latest version ..."
		version=$(
			run curl --fail --location --show-error --silent \
				--connect-timeout 13  --retry 5 --retry-delay 2 \
				--header "Accept:application/vnd.github.v3.raw" \
				"https://api.github.com/repos/${SKYEMU_REPO}/releases/latest" |
			run jq --raw-output '.name'
		)
		version=${version#* }
		logi "The latest available version is $version"
	fi

	logi "Downloading SkyEmu to $SKYEMU_DOWNLOAD_DIR/skyemu.dmg ..."
	run mkdir -p "$SKYEMU_DOWNLOAD_DIR"
	run curl --fail --location --show-error --silent \
		--connect-timeout 13  --retry 5 --retry-delay 2 \
		--output "$SKYEMU_DOWNLOAD_DIR/SkyEmu.dmg" \
		"https://github.com/${SKYEMU_REPO}/releases/download/${version}/SkyEmu-${version}-macOS.dmg"

	logi "Installing SkyEmu at $skyemu_install_dir/SkyEmu.app ..."
	run hdiutil attach -nobrowse -readonly "${SKYEMU_DOWNLOAD_DIR}/SkyEmu.dmg"
	run rm -rf "$skyemu_install_dir/SkyEmu.app"
	run cp -R "/Volumes/SkyEmu/SkyEmu.app" "$skyemu_install_dir/"
}

trap 'cleanup' EXIT
parse_input_args "$@"
check_preconds
if [[ $uninstall == 1 ]]; then
	uninstall_skyemu
else
	install_skyemu
fi
