#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR
# shellcheck disable=SC2155

# README
# This script automatically installs a user-defined list of VS Code extensions.
#
# Pre-conditions:
# - VSCode must be installed and the `code` CLI tool must be available in $PATH.
# - --extensions-list must point to a text file with a list of extensions.
#
# The following switches are available:
# -v: Print major commands being executed.
# -vv: Print major commands being executed and their output.
# --extensions-list: Point to the text file containing the list of extensions to install.

set -Eeuo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
readonly ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
readonly REMAINING_EXTENSIONS_LIST="$TMPDIR/vscode.extensions.txt"
readonly VSC_DATA_DIR="$XDG_CACHE_HOME/code/data/"
readonly VSC_EXTENSIONS_DIR="$XDG_CACHE_HOME/code/extensions/"
VERBOSE="${VERBOSE:-0}"
extensions_list=""

source "$ROOT_DIR/etc/scripts/utils.sh"

parse_input_args () {
	while [[ $# -gt 0 ]]; do case $1 in
		--extensions-list) extensions_list="$2"; shift;;
		-v) VERBOSE=1; shift;;
		*) shift;;
	esac; done
}

check_preconds () {
	logi "Checking pre-conditions ..."

	if ! which -s code; then
		loge "\`code\` was not found but it's required by this script."
		exit 1
	fi

	[[ ! -f $extensions_list ]] &&
		loge "--extensions-list must point to a file." &&
		exit 1

	return 0
}


parse_input_args "$@"
check_preconds

if [[ ! -f $REMAINING_EXTENSIONS_LIST ]]; then
	logi "Loading extensions list ..."
	run cat "$extensions_list" >"$REMAINING_EXTENSIONS_LIST"
fi

while IFS='' read -r extension_id; do
	extension_author=${extension_id%%.*}
	extension_name=${extension_id##*.}
	logi "Installing $extension_name of $extension_author ..."
	run code \
		--user-data-dir "$VSC_DATA_DIR" \
		--extensions-dir "$VSC_EXTENSIONS_DIR" \
		--install-extension "$extension_id" \
		--force </dev/null

	# Remove the last extension that was successfully installed so it won't be
	# reprocessed in case this script is re-executed after a failure.
	run sed -i '' '1d' "$REMAINING_EXTENSIONS_LIST" </dev/null

done <<<"$(run cat "$REMAINING_EXTENSIONS_LIST")"

run rm -rf "$REMAINING_EXTENSIONS_LIST"
