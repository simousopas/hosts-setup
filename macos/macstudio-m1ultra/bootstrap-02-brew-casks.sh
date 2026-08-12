#!/usr/bin/env /bin/bash
# shellcheck disable=SC2155

set -Eeuo pipefail

readonly HOMEBREW_CASKS=(
	alt-tab betterdisplay brave-browser bruno dbeaver-community
	font-jetbrains-mono-nerd-font fork geekbench ghostty iina mac-mouse-fix obs
	spotify transmission utm visual-studio-code visualdiffer zed
)
readonly SCRIPT_DIR="$(cd "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
readonly ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
readonly VERBOSE="${VERBOSE:-0}"

source "$SCRIPT_DIR/env.sh"
source "$ROOT_DIR/etc/scripts/utils.sh"

validate_host

logi "Installing Homebrew's casks ..."
# Executing w/o the `run` harness because it has a rich TUI.
brew install --cask "${HOMEBREW_CASKS[@]}"
