#!/usr/bin/env /bin/bash
# shellcheck disable=SC2155
# shellcheck disable=SC2207

set -Eeuo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
readonly ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
readonly SETUP_SCRIPTS=(
	"$SCRIPT_DIR"/configure.sh
	"$SCRIPT_DIR"/bootstrap-01-defaults.sh
	"$SCRIPT_DIR"/bootstrap-01-rosetta.sh # Likely not necessary on macOS 27
	"$SCRIPT_DIR"/bootstrap-02-brew.sh
	"$SCRIPT_DIR"/bootstrap-02-brew-formulae.sh
	"$SCRIPT_DIR"/bootstrap-02-brew-casks.sh

	# Re-install dot files once more since part of the full setup needs tools
	# that are only available after Homebrew is installed.
	"$SCRIPT_DIR"/configure.sh

	"$SCRIPT_DIR"/bootstrap-03-hosts.sh
	"$SCRIPT_DIR"/bootstrap-04-pip.sh
	"$SCRIPT_DIR"/bootstrap-04-mise.sh
	"$SCRIPT_DIR"/bootstrap-04-ismc.sh
	"$SCRIPT_DIR"/bootstrap-04-vcpkg.sh
	"$SCRIPT_DIR"/bootstrap-04-nmap.sh
	"$SCRIPT_DIR"/bootstrap-04-vscode.sh
	"$SCRIPT_DIR"/bootstrap-05-env.sh
	"$SCRIPT_DIR"/bootstrap-05-misc.sh
)
# The presence of BASH_ENV will make further non-interactive/non-login Bash
# sessions to explicitly source $HOME/.bash_profile, which is fundamental for
# many bootstrap-*/configure-* scripts to work as intended.
export BASH_ENV="$HOME/.bash_profile"
export VERBOSE=0
source "$SCRIPT_DIR/env.sh"
source "$ROOT_DIR/etc/scripts/utils.sh"

parse_input_args () {
	while [[ $# -gt 0 ]]; do case $1 in
		-v) VERBOSE=1; shift;;
		*) shift;;
	esac; done
}

validate_xcode_clt () {
	readonly XCODE_CLT_PATH="$(run xcode-select --print-path 2>/dev/null || true)"
	[[ ! -d "$XCODE_CLT_PATH" ]] &&
		loge "XCode CLI Tools not available. Please install them first." &&
		return 1

	return 0
}


validate_xcode_clt
validate_host
parse_input_args "$@"
for SCRIPT in "${SETUP_SCRIPTS[@]}"; do
	logi "Starting ${SCRIPT##*/} ..."
	/bin/bash "$SCRIPT"
	echo ""
done

logi "I'm finished!"
