#!/usr/bin/env /bin/bash
# shellcheck disable=SC2155

set -Eeuo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
readonly ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
readonly VERBOSE="${VERBOSE:-0}"

source "$SCRIPT_DIR/env.sh"
source "$ROOT_DIR/etc/scripts/utils.sh"

validate_host

/bin/bash "$ROOT_DIR/etc/macos/scripts/install-macvdmtool.sh"
