#!/usr/bin/env /bin/bash
# shellcheck disable=SC2155
# shellcheck disable=SC2207

set -Eeuo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
readonly ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
readonly CONFIGURE_SCRIPTS=(
	"$SCRIPT_DIR"/configure-01-bash.sh
	"$SCRIPT_DIR"/configure-02-dirs.sh
	"$SCRIPT_DIR"/configure-03-files.sh
	"$SCRIPT_DIR"/configure-04-apps.sh
)
export VERBOSE=${VERBOSE:-0}
source "$SCRIPT_DIR/env.sh"
source "$ROOT_DIR/etc/scripts/utils.sh"

parse_input_args () {
	while [[ $# -gt 0 ]]; do case $1 in
		-v) VERBOSE=1; shift;;
		*) shift;;
	esac; done
}

validate_host
parse_input_args "$@"
for SCRIPT in "${CONFIGURE_SCRIPTS[@]}"; do
	logi "Starting ${SCRIPT##*/} ..."
	/bin/bash "$SCRIPT"
done

logi "I'm finished!"
