#!/usr/bin/env /bin/bash
# shellcheck disable=SC2155

set -Eeuo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
readonly ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
readonly VERBOSE="${VERBOSE:-0}"

source "$SCRIPT_DIR/env.sh"
source "$ROOT_DIR/etc/scripts/utils.sh"

validate_host

logi "Building bat's cache ..."
run bat cache --build

logi "Ignoring Focusrite Scarlett Solo automount ..."
run echo "UUID=DC798778-543D-396B-A11F-2EC42F3500F9 none msdos ro,noauto" |
	run sudo tee -a /etc/fstab

logi "Setting defaults for Fork ..."
run defaults write com.DanPristupov.Fork SUEnableAutomaticChecks 0
run defaults write com.DanPristupov.Fork applicationUpdateChannel 1
run defaults write com.DanPristupov.Fork defaultSourceFolder "$CODE"
run defaults write com.DanPristupov.Fork fetchAllTags 0
run defaults write com.DanPristupov.Fork fetchRemotesAutomatically 0
run defaults write com.DanPristupov.Fork updateSubmodulesOnCheckout 0
