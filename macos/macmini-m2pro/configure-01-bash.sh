#!/usr/bin/env /bin/bash
# shellcheck disable=SC2155

set -Eeuo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
readonly ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
readonly VERBOSE="${VERBOSE:-0}"

source "$SCRIPT_DIR/env.sh"
source "$ROOT_DIR/etc/scripts/utils.sh"

validate_host

logi "Patching and installing .bash_profile ..."
run cp "$ROOT_DIR/etc/macos/.bash_profile" "$HOME/"
run sed -i '' "s|#EXTERNAL_VOLUME|/Volumes/E1|" "$HOME/.bash_profile"
run ln -fs "$HOME/.bash_profile" "$HOME/.bashrc"
