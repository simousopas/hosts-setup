#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR
# shellcheck disable=SC2155

# README
# This script automatically install MongoDB Shell and MongoDB Tools.
#
# Pre-conditions:
# - `curl` and `jq` must installed if the MongoDB Shell/Tools version to be
#   installed is set to "latest".
# - `curl` and `unzip` must installed to download and extract MongoDB
#   Shell/Tools packages.
# - MongoDB Shell/Tools installation location must be a valid directory.
#
# The following switches are available:
# -v: Print major commands being executed.
# -vv: Print major commands being executed and their output.
# --shell-bin-dir: Directory where to install MongoDB Shell utils.
# 	Defaults to "$HOME/.local/bin".
# --shell-version: MongoDB Shell version to install. If set to "latest"
#   it will find and download the latest available version.
# 	The list of releases can be found here: https://github.com/mongodb-js/mongosh/releases
# --tools-bin-dir: Directory where to install MongoDB Tools utils.
# 	Defaults to "$HOME/.local/bin".
# --tools-version: MongoDB Tools version to install. If set to "latest"
#   it will download the latest available version.
# 	The list of releases can be found here: https://github.com/mongodb/mongo-tools/tags
set -Eeuo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
readonly ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
readonly CPU_ARCH="$(uname -m)"
readonly MONGODB_SHELL_REPO="mongodb-js/mongosh"
VERBOSE="${VERBOSE:-0}"
mongodb_shell_bin_dir="$HOME/.local/bin"
mongodb_shell_version=""
mongodb_tools_bin_dir="$HOME/.local/bin"
mongodb_tools_version=""

source "$ROOT_DIR/etc/scripts/utils.sh"

cleanup () {
	rm -rf "${TMPDIR}mongodb"*
	rm -rf "${TMPDIR}mongosh"*
}

parse_input_args () {
	while [[ $# -gt 0 ]]; do case $1 in
		--shell-bin-dir) mongodb_shell_bin_dir="$2"; shift; shift;;
		--shell-version) mongodb_shell_version="$2"; shift; shift;;
		--tools-bin-dir) mongodb_tools_bin_dir="$2"; shift; shift;;
		--tools-version) mongodb_tools_version="$2"; shift; shift;;
		-v) VERBOSE=1; shift;;
		*) shift;;
	esac; done
}

check_preconds () {
	if [[ $mongodb_shell_version == "latest" ]] && ! which -s curl; then
		loge "When --shell-version is set to 'latest' \`curl\` is required to fetch the latest release."
		exit 1
	fi

	if [[ $mongodb_shell_version == "latest" ]] && ! which -s jq; then
		loge "When --shell-version is set to 'latest' \`jq\` is required to fetch the latest release."
		exit 1
	fi

	if [[ -n $mongodb_shell_version ]] && ! which -s curl; then
		loge "When --shell-version is set, \`curl\` is required to download its package."
		exit 1
	fi

	if [[ -n $mongodb_tools_version ]] && ! which -s curl; then
		loge "When --tools-version is set, \`curl\` is required to download its package."
		exit 1
	fi

	if [[
		-n $mongodb_shell_version &&
		-n $mongodb_shell_bin_dir &&
		! -d $mongodb_shell_bin_dir ]]; then
		loge "--shell-bin-dir is set but doesn't point to a valid directory: $mongodb_shell_bin_dir"
		exit 1
	fi

	if [[
		-n $mongodb_shell_version &&
		-n $mongodb_tools_bin_dir &&
		! -d $mongodb_tools_bin_dir ]]; then
		loge "--tools-bin-dir is set but doesn't point to a valid directory: $mongodb_tools_bin_dir"
		exit 1
	fi
}

install_mongodb_shell () {
	if [[ $mongodb_shell_version == "latest" ]]; then
		logi "Querying MongoDB Shell latest available version ..."
		mongodb_shell_version=$(
			run curl --fail --location --show-error --silent \
				--connect-timeout 13  --retry 5 --retry-delay 2 \
				--header "Accept:application/vnd.github.v3.raw" \
				"https://api.github.com/repos/${MONGODB_SHELL_REPO}/releases/latest" |
			run jq --raw-output '.name'
		)
		logi "MongoDB Shell latest version is ${mongodb_shell_version}"
	fi

	logi "Downloading MongoDB Shell ..."
	local _cpu_arch="$CPU_ARCH"
	[[ "$_cpu_arch" == "x86_64" ]] && _cpu_arch="x64"
	run curl --fail --location --show-error --silent \
		--connect-timeout 13  --retry 5 --retry-delay 2 \
		--header "Accept:application/vnd.github.v3.raw" \
		--output "${TMPDIR}mongosh.zip" \
		"https://github.com/${MONGODB_SHELL_REPO}/releases/download/v${mongodb_shell_version}/mongosh-${mongodb_shell_version}-darwin-${_cpu_arch}.zip"

	logi "Extracting ${TMPDIR}mongosh.zip ..."
	run unzip "${TMPDIR}mongosh.zip" -d "$TMPDIR"

	logi "Installing MongoDB Shell in $mongodb_shell_bin_dir/ ..."
	run rm -rf "$mongodb_shell_bin_dir/mongosh"
	run mv "${TMPDIR}mongosh-${mongodb_shell_version}-darwin-${_cpu_arch}/bin/mongosh" "$mongodb_shell_bin_dir/"
}

install_mongodb_tools () {
	[[ "$mongodb_tools_version" == "latest" ]] && mongodb_tools_version="100.18.0"

	logi "Downloading MongoDB Tools version ${mongodb_tools_version} ..."
	run curl --fail --location --show-error --silent \
		--connect-timeout 13  --retry 5 --retry-delay 2 \
		--output "${TMPDIR}mongodb-tools.zip" \
		"https://fastdl.mongodb.org/tools/db/mongodb-database-tools-macos-${CPU_ARCH}-${mongodb_tools_version}.zip"

	logi "Extracting ${TMPDIR}mongodb-tools.zip ..."
	run unzip "${TMPDIR}mongodb-tools.zip" -d "$TMPDIR"

	logi "Installing MongoDB Tools in $mongodb_tools_bin_dir/ ..."
	run rm -rf "$HOME/.local/bin"/mongo{dump,export,files,import,restore,stat,top}
	run mv "${TMPDIR}mongodb-database-tools-macos-${CPU_ARCH}-${mongodb_tools_version}/bin/mongo"* "$mongodb_tools_bin_dir/"
}


trap 'cleanup' EXIT
parse_input_args "$@"
check_preconds
[[ -n $mongodb_shell_version ]] && install_mongodb_shell
[[ -n $mongodb_tools_version ]] && install_mongodb_tools
