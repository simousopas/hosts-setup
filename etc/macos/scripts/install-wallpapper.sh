#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR
# shellcheck disable=SC2155

# README
# This scripts builds and installs mczachurski/wallpapper
#
# Pre-conditions:
# `git` and `swiftc` need to be available to clone and build wallpappper.
#
# The following switch are available:
# -v: Print major commands being executed.
# --bin-dir: Directory where the wallpapper CLI program is going to be installed.
#	Defaults to "$HOME/.local/bin".
	#	This location should be part of your $PATH if you intend to have `wallpapper` available globally.
# --git-dir: Directory where the wallpapper repo will be cloned to.
#	Defaults to "$CODE/github/".

set -Eeuo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
readonly ROOT_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"
readonly WALLPAPPER_REPO="mczachurski/wallpapper"
VERBOSE="${VERBOSE:-0}"
wallpapper_bin_dir="$HOME/.local/bin"
wallpapper_git_dir="$CODE/github/"

source "$ROOT_DIR/etc/scripts/utils.sh"

cleanup () {
	while [ "$(dirs -p | wc -l)" -gt 1 ]; do
		popd >/dev/null
	done
}

parse_input_args () {
	while [[ $# -gt 0 ]]; do case $1 in
		--bin-dir) wallpapper_bin_dir="$2"; shift; shift;;
		--git-dir) wallpapper_git_dir="$2"; shift; shift;;
		-v) VERBOSE=1; shift;;
		*) shift;;
	esac; done
}

check_preconds () {
	logi "Checking pre-conditions ..."

	if ! which -s git; then
		loge "\`git\` was not found but it's required to clone wallpapper's repo."
		exit 1
	fi

	if ! which -s swiftc; then
		loge "\`cc\` was not found but it's to compile wallpapper's source code."
		exit 1
	fi

	if [[ ! -d $wallpapper_bin_dir ]]; then
		loge "\$wallpapper_bin_dir is referencing a location that's not a directory: '$wallpapper_bin_dir'."
		exit 1
	fi
}

install_wallpapper () {
	logi "Cloning https://github.com/$WALLPAPPER_REPO to $wallpapper_git_dir/wallpapper ..."
	run git clone "https://github.com/$WALLPAPPER_REPO" "$wallpapper_git_dir/wallpapper"

	logi "Building and installing wallpapper ..."
	run pushd "$wallpapper_git_dir/wallpapper"
	run ./build.sh
	run mv ./output/wallpapper "$wallpapper_bin_dir/"
	run popd
}

update_wallpapper () {
	logi "Updating preexisting setup ..."
	run git -C "$wallpapper_git_dir/wallpapper" clean -fddx
	run git -C "$wallpapper_git_dir/wallpapper" pull --prune

	logi "Building and installing wallpapper in $wallpapper_bin_dir/wallpapper ..."
	run pushd "$wallpapper_git_dir/wallpapper"
	run ./build.sh
	run mv ./output/wallpapper "$wallpapper_bin_dir/"
	run popd
}

trap 'cleanup' EXIT
parse_input_args "$@"
check_preconds
if [[
	-d "$wallpapper_git_dir/wallpapper" &&
	$(run git -C "$wallpapper_git_dir/wallpapper" rev-parse --is-inside-work-tree) == "true"
]]; then
	update_wallpapper
else
	install_wallpapper
fi
