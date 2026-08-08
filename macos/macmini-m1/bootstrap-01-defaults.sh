#!/usr/bin/env /bin/bash
# shellcheck disable=SC2155

set -Eeuo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
readonly ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
readonly VERBOSE="${VERBOSE:-0}"

source "$SCRIPT_DIR/env.sh"
source "$ROOT_DIR/etc/scripts/utils.sh"

validate_host

logi "Setting defaults for the Desktop and keyboard ..."
run defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
run defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
run defaults write com.apple.dock autohide-delay -int 0
run defaults write com.apple.dock autohide-time-modifier -float 0.30
run defaults write com.apple.dock showAppExposeGestureEnabled -bool true
run defaults write com.apple.loginwindow TALLogoutSavesState -bool false
run defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true
run defaults write -g ApplePressAndHoldEnabled -bool false
run defaults write -g InitialKeyRepeat -int 10
run defaults write -g KeyRepeat -int 1
run defaults write -g NSWindowShouldDragOnGesture -bool true
run killall Dock
