#!/usr/bin/env /bin/bash
# shellcheck disable=SC2155

set -Eeuo pipefail

readonly HOMEBREW_FORMULAE=(
	7zip aria2 bat bash bash-completion@2 bzip2 coreutils eza fd fio fish fzf
	gettext git-delta gsed jq lf lima miniserve mise neovim pbzip2 pigz pinentry
	ripgrep shellcheck tokei tree typst xz zstd
)
readonly SCRIPT_DIR="$(cd "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
readonly ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
readonly VERBOSE="${VERBOSE:-0}"

source "$SCRIPT_DIR/env.sh"
source "$ROOT_DIR/etc/scripts/utils.sh"

validate_host

logi "Installing Homebrew's formulae ..."
# Executing w/o the `run` harness because it has a rich TUI.
brew install "${HOMEBREW_FORMULAE[@]}"
brew unlink openssl@3
