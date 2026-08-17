#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR
# shellcheck disable=SC2155

# README
# This script installs/uninstalls the Azahar emulator.
#
# The following switches are available:
# -v: Print major commands being executed.
# -vv: Print major commands being executed and their output.
# --install-dir: Directory where the Azahar.app program is going to be installed.
#	Defaults to "/Applications".
# --uninstall: Uninstall the Azahar.app plus its cached files.
# --version: Select a specific version of Azahar to be installed.
# 	If no version is explicitly set or it's set to "latest", this script will
# 	query and use the latest one. All available version can be found here:
# 	https://github.com/azahar-emu/azahar/releases

set -Eeuo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
readonly ROOT_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"
readonly AZAHAR_DOWNLOAD_DIR="$TMPDIR/azahar"
readonly AZAHAR_REPO="azahar-emu/azahar"
readonly CPU_ARCH="$(uname -m)"
VERBOSE="${VERBOSE:-0}"
azahar_install_dir="/Applications"
uninstall=0
version=""

source "$ROOT_DIR/etc/scripts/utils.sh"

cleanup () {
	run rm -rf "$AZAHAR_DOWNLOAD_DIR"
}

parse_input_args () {
	while [[ $# -gt 0 ]]; do case $1 in
		--install-dir) azahar_install_dir="$2"; shift; shift;;
		--uninstall) uninstall=1; shift;;
		--version) version="$2"; shift; shift;;
		-v) VERBOSE=1; shift;;
		*) shift;;
	esac; done
}

check_preconds () {
	logi "Checking pre-conditions ..."

	if ! which -s curl; then
		loge "\`curl\` is required to download Azahar."
		exit 1
	fi

	if [[ ! -d $azahar_install_dir ]]; then
		loge "\$azahar_install_dir is referencing a location that's not a directory: '$azahar_install_dir'."
		exit 1
	fi
}

uninstall_azahar () {
	logi "Uninstalling Azahar ..."
	run rm -rf "/$azahar_install_dir/Azahar.app"
	run rm -rf "$HOME/Library/Application Support/Azahar"
}

install_azahar () {
	if [[ -z $version || $version == "latest" ]]; then
		logi "Querying Azahar's latest version ..."
		version=$(
			run curl --fail --location --show-error --silent \
				--connect-timeout 13  --retry 5 --retry-delay 2 \
				--header "Accept:application/vnd.github.v3.raw" \
				"https://api.github.com/repos/${AZAHAR_REPO}/releases/latest" |
			run jq --raw-output '.name'
		)
		version=${version#* }
		logi "The latest available version is $version"
	fi

	logi "Downloading Azahar to $AZAHAR_DOWNLOAD_DIR/azahar.zip ..."
	run mkdir -p "$AZAHAR_DOWNLOAD_DIR"
	run curl --fail --location --show-error --silent \
		--connect-timeout 13  --retry 5 --retry-delay 2 \
		--output "$AZAHAR_DOWNLOAD_DIR/azahar.zip" \
		"https://github.com/${AZAHAR_REPO}/releases/download/${version}/azahar-macos-${CPU_ARCH}-${version}.zip"

	logi "Extracting Azahar ..."
	run unzip "$AZAHAR_DOWNLOAD_DIR/azahar.zip" -d "$AZAHAR_DOWNLOAD_DIR"

	logi "Installing Azahar at $azahar_install_dir/Azahar.app ..."
	run rm -rf "$azahar_install_dir/Azahar.app"
	run ditto "$AZAHAR_DOWNLOAD_DIR/azahar-macos-${CPU_ARCH}-${version}/Azahar.app" "$azahar_install_dir/Azahar.app"
}

trap 'cleanup' EXIT
parse_input_args "$@"
check_preconds
if [[ $uninstall == 1 ]]; then
	uninstall_azahar
else
	install_azahar
fi
