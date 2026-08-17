#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR
# shellcheck disable=SC2155

# README
# This script installs/uninstalls nmap.
# Why this instead of `brew install nmap`? Because it also installs `python@3.14`
# and `lua` for features I'm not interested in.
#
# The following switches are available:
# -v: Print major commands being executed.
# -vv: Print major commands being executed and their output.
# --uninstall: Uninstall the nmap plus its environment files.
# --version: Select a specific version of nmap to be installed.
# 	If no version is explicitly set or it's set to "latest", this script will
# 	query and use the latest one. All available version can be found here:
#	https://svn.nmap.org/nmap/CHANGELOG

set -Eeuo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
readonly ROOT_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"
readonly NMAP_DOWNLOAD_DIR="$TMPDIR/nmap"
VERBOSE="${VERBOSE:-0}"
uninstall=0
version=""

source "$ROOT_DIR/etc/scripts/utils.sh"

cleanup () {
	if [[ -d /Volumes/nmap-${version} ]]; then
		run hdiutil detach "/Volumes/nmap-${version}" || true
	fi
	run rm -rf "$NMAP_DOWNLOAD_DIR"
}

parse_input_args () {
	while [[ $# -gt 0 ]]; do case $1 in
		--uninstall) uninstall=1; shift;;
		--version) version="$2"; shift; shift;;
		-v) VERBOSE=1; shift;;
		*) shift;;
	esac; done
}

check_preconds () {
	logi "Checking pre-conditions ..."

	if ! which -s curl; then
		loge "\`curl\` is required to download nmap's installer."
		exit 1
	fi
}

uninstall_nmap () {
	logi "Uninstalling nmap ..."
	run sudo rm -rf "/etc/paths.d/org.insecure.nmap"*
	run sudo rm -rf "/Applications/ncat.app"
	run sudo rm -rf "/Applications/nmap.app"
	run sudo rm -rf "/Applications/nping.app"
	run sudo rm -rf "/Applications/Zenmap.app"
}

install_nmap () {
	if [[ -z $version || $version == "latest" ]]; then
		logi "Querying nmap's latest version ..."
		version=$(
			run curl --fail --location --show-error --silent \
				--connect-timeout 13 --retry 5 --retry-delay 2 \
				"https://svn.nmap.org/nmap/CHANGELOG" |
			run grep --extended-regex --only-matching '^Nmap \d\.\d+' |
			run grep --extended-regex --max-count 1 --only-matching '\d\.\d+'
		)
		logi "The latest available version is $version"
	fi

	logi "Downloading nmap to $NMAP_DOWNLOAD_DIR/nmap-${version}.dmg ..."
	run mkdir -p "$NMAP_DOWNLOAD_DIR"
	run curl --fail --location --show-error --silent \
		--connect-timeout 13  --retry 5 --retry-delay 2 \
		--output "$NMAP_DOWNLOAD_DIR/nmap-${version}.dmg" \
		"https://nmap.org/dist/nmap-${version}.dmg"

	logi "Mounting ${NMAP_DOWNLOAD_DIR}/nmap-${version}.dmg ..."
	run hdiutil attach -nobrowse -readonly "${NMAP_DOWNLOAD_DIR}/nmap-${version}.dmg"
	logi "Installing nmap version $version ..."
	run sudo installer -pkg "/Volumes/nmap-${version}/nmap-${version}.mpkg" -target /
}

trap 'cleanup' EXIT
parse_input_args "$@"
check_preconds
if [[ $uninstall == 1 ]]; then
	uninstall_nmap
else
	install_nmap
fi
