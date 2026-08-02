#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR
# shellcheck disable=SC2155

# README
# This script installs/updates iSMC, a CLI tool that decode temperatura, fans,
# battery, power, voltage and current of Apple Silicon macs.
#
# Pre-conditions
# - `curl` must be available to download iSMC.
#
# The following switches are available:
# -v: Print major commands being executed.
# -vv: Print major commands being executed and their output.
# --bin-dir: Directory where the iSMC CLI program is going to be installed.
#	Defaults to "$HOME/.local/bin".
#	This location should be part of your $PATH if you intend to have `iSMC` available globally.
# --version: Select a specific version of iSMC to be installed.
# 	If no version is explicitly set or it's set to "latest", this script will
# 	query and use the latest one. All available version can be found here:
# 	https://github.com/dkorunic/iSMC/releases

set -Eeuo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
readonly ROOT_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"
readonly ISMC_DOWNLOAD_DIR="$TMPDIR/iSMC"
readonly ISMC_REPO="dkorunic/iSMC"
VERBOSE="${VERBOSE:-0}"
ismc_bin_dir="$HOME/.local/bin"
version=""

source "$ROOT_DIR/etc/scripts/utils.sh"

cleanup () {
	rm -rf "$TMPDIR/iSMC"
}

parse_input_args () {
	while [[ $# -gt 0 ]]; do case $1 in
		--bin-dir) ismc_bin_dir="$2" shift; shift;;
		--version) version="$2"; shift; shift;;
		-v) VERBOSE=1; shift;;
		*) shift;;
	esac; done
}

check_preconds () {
	logi "Checking pre-conditions ..."

	if ! which -s curl; then
		loge "\`curl\` is required to download iSMC."
		exit 1
	fi

	if [[ ! -d $ismc_bin_dir ]]; then
		loge "\$ismc_bin_dir is referencing a location that's not a directory: '$ismc_bin_dir'."
		exit 1
	fi

	return 0
}

install_ismc () {
	if [[ -z $version || $version == "latest" ]]; then
		logi "Querying iSMC's latest available version ..."
		version=$(
			run curl --fail --location --show-error --silent \
				--connect-timeout 13  --retry 5 --retry-delay 2 \
				--header "Accept:application/vnd.github.v3.raw" \
				"https://api.github.com/repos/${ISMC_REPO}/releases/latest" |
			run jq --raw-output '.name'
		)
		logi "The latest available version is $version"
	fi

	logi "Downloading iSMC to $TMPDIR/iSMC/iSMC.tar.gz ..."
	run mkdir -p "$ISMC_DOWNLOAD_DIR"
	run curl --fail --location --show-error --silent \
		--connect-timeout 13  --retry 5 --retry-delay 2 \
		--output "$ISMC_DOWNLOAD_DIR/iSMC.tar.gz" \
		"https://github.com/${ISMC_REPO}/releases/download/${version}/iSMC_Darwin_all.tar.gz"

	logi "Extracting iSMC ..."
	run tar --directory "$ISMC_DOWNLOAD_DIR" -xvf "$ISMC_DOWNLOAD_DIR/iSMC.tar.gz"

	logi "Installing iSMC at $ismc_bin_dir/iSMC ..."
	run rm -rf "$ismc_bin_dir/iSMC"
	run mv "$ISMC_DOWNLOAD_DIR/iSMC" "$ismc_bin_dir/"
}

trap 'cleanup' EXIT
parse_input_args "$@"
check_preconds
install_ismc
