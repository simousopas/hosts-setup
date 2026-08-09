#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR
# shellcheck disable=SC2155

# README
# This scripts builds and installs AsahiLinux/macvdmtool.
#
# Pre-conditions:
# `git`, `make` and `cc` need to be available to clone and build macvdmtool.
#
# The following switch are available:
# -v: Print major commands being executed.
# --bin-dir: Directory where the macvdmtoll CLI program is going to be installed.
#	Defaults to "$HOME/.local/bin".
#	This location should be part of your $PATH if you intend to have `macvdmtool` available globally.
# --git-dir: Directory where the macvdmtool repo will be cloned to.
#	Defaults to "$CODE/github/".

set -Eeuo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
readonly ROOT_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"
readonly MACVDM_REPO="AsahiLinux/macvdmtool"
VERBOSE="${VERBOSE:-0}"
macvdm_bin_dir="$HOME/.local/bin"
macvdm_git_dir="$CODE/github/"

source "$ROOT_DIR/etc/scripts/utils.sh"

cleanup () {
	while [ "$(dirs -p | wc -l)" -gt 1 ]; do
		popd >/dev/null
	done
}

parse_input_args () {
	while [[ $# -gt 0 ]]; do case $1 in
		--bin-dir) macvdm_bin_dir="$2"; shift; shift;;
		--git-dir) macvdm_git_dir="$2"; shift; shift;;
		-v) VERBOSE=1; shift;;
		*) shift;;
	esac; done
}

check_preconds () {
	logi "Checking pre-conditions ..."

	if ! which -s git; then
		loge "\`git\` was not found but it's required to clone macvdm's repo."
		exit 1
	fi

	if ! which -s cc; then
		loge "\`cc\` was not found but it's to compile macvdm's source code."
		exit 1
	fi

	if ! which -s make; then
		loge "\`make\` was not found but it's to build macvdm's from source."
		exit 1
	fi

	if [[ ! -d $macvdm_bin_dir ]]; then
		loge "\$macvdm_bin_dir is referencing a location that's not a directory: '$macvdm_bin_dir'."
		exit 1
	fi
}

install_macvdm () {
	logi "Cloning macvdmtool repo from $macvdm_git_dir/macvdmtool ..."
	run git clone "https://github.com/$MACVDM_REPO" "$macvdm_git_dir/macvdmtool"

	logi "Building and installing macvdmtool in $macvdm_bin_dir/macvdmtool ..."
	run pushd "$macvdm_git_dir/macvdmtool"
	run make
	run mv macvdmtool "$macvdm_bin_dir/macvdmtool"
	run popd
}

update_macvdm () {
	logi "Updating preexisting setup ..."
	run git -C "$macvdm_git_dir/macvdmtool" clean -fddx
	run git -C "$macvdm_git_dir/macvdmtool" pull --prune

	logi "Building and installing macvdmtool in $macvdm_bin_dir/macvdmtool ..."
	run pushd "$macvdm_git_dir/macvdmtool"
	run make
	run mv macvdmtool "$macvdm_bin_dir/macvdmtool"
	run popd
}

trap 'cleanup' EXIT
parse_input_args "$@"
check_preconds
if [[
	-d "$macvdm_git_dir/macvmd" &&
	$(run git -C "$macvdm_git_dir/macvdmtool" rev-parse --is-inside-work-tree) == "true"
]]; then
	update_macvdm
else
	install_macvdm
fi
