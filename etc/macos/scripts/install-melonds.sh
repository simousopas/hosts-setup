#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR
# shellcheck disable=SC2155

# README
# This script installs/uninstalls the melonDS emulator.
#
# The following switches are available:
# -v: Print major commands being executed.
# -vv: Print major commands being executed and their output.
# --install-dir: Directory where the melonDS.app program is going to be installed.
#	Defaults to "/Applications".
# --uninstall: Uninstall the melonDS.app plus its cached files.
# --version: Select a specific version of melonDS to be installed.
# 	If no version is explicitly set or it's set to "latest", this script will
# 	query and use the latest one. All available version can be found here:
#	https://github.com/melonDS-emu/melonDS/releases

set -Eeuo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
readonly ROOT_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"
readonly MELONDS_DOWNLOAD_DIR="$TMPDIR/melonds"
readonly MELONDS_REPO="melonDS-emu/melonDS"
VERBOSE="${VERBOSE:-0}"
melonds_install_dir="/Applications"
uninstall=0
version=""

source "$ROOT_DIR/etc/scripts/utils.sh"

cleanup () {
	run rm -rf "$MELONDS_DOWNLOAD_DIR"
}

parse_input_args () {
	while [[ $# -gt 0 ]]; do case $1 in
		--install-dir) melonds_install_dir="$2"; shift; shift;;
		--uninstall) uninstall=1; shift;;
		--version) version="$2"; shift; shift;;
		-v) VERBOSE=1; shift;;
		*) shift;;
	esac; done
}

check_preconds () {
	logi "Checking pre-conditions ..."

	if ! which -s curl; then
		loge "\`curl\` is required to download melonDS."
		exit 1
	fi

	if [[ ! -d $melonds_install_dir ]]; then
		loge "\$melonds_install_dir is referencing a location that's not a directory: '$melonds_install_dir'."
		exit 1
	fi
}

uninstall_melonds () {
	logi "Uninstalling melonDS ..."
	run rm -rf "/$melonds_install_dir/melonDS.app"
	run rm -rf "$HOME/Library/Preferences/melonDS"
}

install_melonds () {
	if [[ -z $version || $version == "latest" ]]; then
		logi "Querying melonDS's latest version ..."
		version=$(
			run curl --fail --location --show-error --silent \
				--connect-timeout 13  --retry 5 --retry-delay 2 \
				--header "Accept:application/vnd.github.v3.raw" \
				"https://api.github.com/repos/${MELONDS_REPO}/releases/latest" |
			run jq --raw-output '.name'
		)
		version=${version#* }
		logi "The latest available version is $version"
	fi

	logi "Downloading melonDS to $MELONDS_DOWNLOAD_DIR/melonds.zip ..."
	run mkdir -p "$MELONDS_DOWNLOAD_DIR"
	run curl --fail --location --show-error --silent \
		--connect-timeout 13  --retry 5 --retry-delay 2 \
		--output "$MELONDS_DOWNLOAD_DIR/melonds.zip" \
		"https://github.com/${MELONDS_REPO}/releases/download/${version}/melonDS-${version}-macOS-universal.zip"

	logi "Extracting melonDS ..."
	run unzip "$MELONDS_DOWNLOAD_DIR/melonds.zip" -d "$MELONDS_DOWNLOAD_DIR"

	logi "Installing melonDS at $melonds_install_dir/melonDS.app ..."
	run rm -rf "$melonds_install_dir/melonDS.app"
	run mv "$MELONDS_DOWNLOAD_DIR/melonDS.app" "$melonds_install_dir/"
}

trap 'cleanup' EXIT
parse_input_args "$@"
check_preconds
if [[ $uninstall == 1 ]]; then
	uninstall_melonds
else
	install_melonds
fi
