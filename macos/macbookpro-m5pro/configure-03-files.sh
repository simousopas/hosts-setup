#!/usr/bin/env /bin/bash
# shellcheck disable=SC2155

set -Eeuo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
readonly ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
readonly VERBOSE="${VERBOSE:-0}"
readonly APP_SUPPORT_FOLDER="$HOME/Library/Application Support"
readonly VSCODE_CACHE_DIR="$XDG_CACHE_HOME/code/data/User"
readonly VSCODE_SETTINGS_DIR="$APP_SUPPORT_FOLDER/Code/User"

source "$SCRIPT_DIR/env.sh"
source "$ROOT_DIR/etc/scripts/utils.sh"

validate_host

logi "Installing dot files ..."
run rm -rf "$HOME/.gnupg/gpg.conf"
run rm -rf "$XDG_CONFIG_HOME/nvim/"*
run cp "$ROOT_DIR/etc/.bash_completion" "$HOME/"
run cp "$ROOT_DIR/etc/.inputrc" "$HOME/"
run cp "$ROOT_DIR/etc/git.config" "$XDG_CONFIG_HOME/git/config"
run cp "$ROOT_DIR/etc/gpg.conf" "$HOME/.gnupg/"
run cp "$ROOT_DIR/etc/fdignore" "$XDG_CONFIG_HOME/fd/ignore"
run cp "$ROOT_DIR/etc/keybindings.vscode.json" "$VSCODE_CACHE_DIR/keybindings.json"
run cp "$ROOT_DIR/etc/keybindings.vscode.json" "$VSCODE_SETTINGS_DIR/keybindings.json"
run cp "$ROOT_DIR/etc/lficons" "$XDG_CONFIG_HOME/lf/icons"
run cp "$ROOT_DIR/etc/lfpreview" "$HOME/.local/bin/"
run cp "$ROOT_DIR/etc/init.lua" "$XDG_CONFIG_HOME/nvim/"
run cp "$ROOT_DIR/etc/obs-mask.png" "$DOCUMENTS/Misc/"
run cp "$ROOT_DIR/etc/pip.conf" "$XDG_CONFIG_HOME/pip/"
run cp "$ROOT_DIR/etc/rgignore" "$XDG_CONFIG_HOME/rg/ignore"
run cp "$ROOT_DIR/etc/ssh.conf" "$HOME/.ssh/config"
run cp "$ROOT_DIR/etc/tokyonight-moon.tmTheme" "$XDG_CONFIG_HOME/bat/themes"
run cp "$ROOT_DIR/etc/zed.keymap.json" "$XDG_CONFIG_HOME/zed/keymap.json"
run cp "$ROOT_DIR/etc/macos/config.fish" "$XDG_CONFIG_HOME/fish/"
run cp "$ROOT_DIR/etc/macos/lfrc" "$XDG_CONFIG_HOME/lf/"
run cp "$SCRIPT_DIR/etc/mise.toml" "$XDG_CONFIG_HOME/mise/config.toml"
run touch "$HOME/.bash_sessions_disable"
run touch "$HOME/.hushlogin"
run touch "$XDG_CONFIG_HOME/lf/bookmarks"

logi "Setting permissions and patching some files ..."
run chmod u=rwx,g=,o= "$HOME/.gnupg"
run chmod u=r,g=,o= "$HOME/.gnupg/gpg.conf"
run chmod u=rwx,g=,o= "$HOME/.ssh"
run chmod u=rwx,g=,o= "$HOME/.ssh/sockets"
run chmod u+x "$HOME/.local/bin/lfpreview"
run sed -i '' "s|#EXTERNAL_VOLUME||" "$XDG_CONFIG_HOME/fish/config.fish"
run sed -i '' "s|#LIMA_HOME|$XDG_CONFIG_HOME/lima|" "$HOME/.bash_profile"
run sed -i '' "s|#LIMA_HOME|$XDG_CONFIG_HOME/lima|" "$XDG_CONFIG_HOME/fish/config.fish"

[[ -z "${HOMEBREW_PREFIX+x}" ]] && exit 0

logi "Patching some files that require 'envsubst' ..."
export zed_extensions="$(run cat "$SCRIPT_DIR/etc/zed.extensions.json")"
export font_size="11"
export terminal_window_height="35"
export terminal_window_width="150"
run rm -rf "$HOME/.gnupg/gpg-agent.conf"
run envsubst <"$ROOT_DIR/etc/macos/ghostty.conf" >"$XDG_CONFIG_HOME/ghostty/config"
run envsubst <"$ROOT_DIR/etc/macos/lfmarks" >"$HOME/.local/share/lf/marks"
run envsubst <"$ROOT_DIR/etc/gpg-agent.conf" >"$HOME/.gnupg/gpg-agent.conf"
run envsubst <"$ROOT_DIR/etc/settings.vscode.json" >"$TMPDIR/settings.vscode.json"
run envsubst <"$ROOT_DIR/etc/zed.settings.json" >"$XDG_CONFIG_HOME/zed/settings.json"
run cp "$TMPDIR/settings.vscode.json" "$VSCODE_CACHE_DIR/settings.json"
run cp "$TMPDIR/settings.vscode.json" "$VSCODE_SETTINGS_DIR/settings.json"
run rm "$TMPDIR/settings.vscode.json"
run chmod u=r,g=,o= "$HOME/.gnupg/gpg-agent.conf"
