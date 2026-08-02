#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR
# shellcheck disable=SC2155

# README
# This script installs/updates Microsoft's C++ package manager (vcpkg).
#
# Pre-conditions:
# - $VCPKG_ROOT must point to the location where the vcpkg git repo will be placed.
# - `git` must be installed in order to handle vcpkg's git repo.
# - `curl` and `jq` must be available if --version is not explicitly set.
#
# The following switches are available:
# -v: Print major commands being executed.
# -vv: Print major commands being executed and their output.
# --bin-dir: Directory where the vcpkg CLI program is going to be installed.
#	Defaults to "$HOME/.local/bin".
#	This location should be part of your $PATH if you intend to have `vcpkg` available globally.
# --version: Select a specific version of vcpkg to be installed.
# 	If no version is explicitly set, this script will query and use the latest one.
#	All available version can be found here: https://github.com/microsoft/vcpkg/tags

set -Eeuo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
readonly ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
readonly VCPKG_REPO="microsoft/vcpkg"
VERBOSE="${VERBOSE:-0}"
vcpkg_bin_dir="$HOME/.local/bin"
vcpkg_version=""

source "$ROOT_DIR/etc/scripts/utils.sh"

cleanup () {
	rm -rf "$TMPDIR/vcpkg"
	while [ "$(dirs -p | wc -l)" -gt 1 ]; do
		popd >/dev/null
	done
}

parse_input_args () {
	while [[ $# -gt 0 ]]; do case $1 in
		--bin-dir) vcpkg_bin_dir="$2"; shift; shift;;
		--version) vcpkg_version="$2"; shift; shift;;
		-v) VERBOSE=1; shift;;
		*) shift;;
	esac; done
}

check_preconds () {
	logi "Checking pre-conditions ..."

	[[ -z $VCPKG_ROOT ]] &&
		loge "This script requires \$VCPKG_ROOT to be set upfront." &&
		exit 1

	if ! which -s git; then
		loge "\`git\` was not found but it's required by this script."
		exit 1
	fi

	if [[ -z $vcpkg_version ]] && ! which -s curl; then
		loge "When --version is not specified \`curl\` is required to fetch vcpkg release metadata."
		exit 1
	fi

	if [[ -z $vcpkg_version ]] && ! which -s jq; then
		loge "When --version is not specified \`jq\` is required to parse vcpkg release metadata."
		exit 1
	fi

	if [[ ! -d $vcpkg_bin_dir ]]; then
		loge "\$vcpkg_bin_dir is referencing a location that's not a directory: '$vcpkg_bin_dir'."
		exit 1
	fi

	return 0
}

install_vcpkg () {
	logi "Cloning version @$vcpkg_version..."
	run git clone --branch "$vcpkg_version" "https://github.com/$VCPKG_REPO" "$TMPDIR/vcpkg"

	logi "Bootstrapping vcpkg ..."
	run pushd "$TMPDIR/vcpkg"
	run ./bootstrap-vcpkg.sh
	run popd

	logi "Installing vcpkg ..."
	[[ -d $VCPKG_ROOT ]] && run rm -rf "$VCPKG_ROOT"
	run mv "$TMPDIR/vcpkg" "$VCPKG_ROOT"
	run ln -fs "$VCPKG_ROOT/vcpkg" "$vcpkg_bin_dir/vcpkg"
}

update_vcpkg () {
	logi "Updating preexisting setup ..."
	run pushd "$VCPKG_ROOT"
	run git checkout master
	run git pull --prune
	run git checkout "$vcpkg_version"

	logi "Bootstrapping and installing vcpkg ..."
	run ./bootstrap-vcpkg.sh
	run ln -fs "$VCPKG_ROOT/vcpkg" "$vcpkg_bin_dir/vcpkg"
	run popd
}


trap 'cleanup EXIT' EXIT
parse_input_args "$@"
check_preconds

if [[ -z "$vcpkg_version" ]]; then
	logi "Querying vcpkg latest available version ..."
	vcpkg_version=$(
		run curl --fail --location --show-error --silent \
			--connect-timeout 13 --retry 5 --retry-delay 2 \
			--header "Accept:application/vnd.github.v3.raw" \
			"https://api.github.com/repos/$VCPKG_REPO/releases/latest" |
		run jq --raw-output '.tag_name'
	)
	logi "The latest available version is $vcpkg_version"
fi

if [[ -d $VCPKG_ROOT && $(git -C "$VCPKG_ROOT" rev-parse --is-inside-work-tree) == "true" ]]; then
	update_vcpkg
else
	install_vcpkg
fi
