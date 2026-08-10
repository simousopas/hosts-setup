#!/usr/bin/env /bin/bash
# shellcheck disable=SC2155

set -Eeuo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
readonly ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
readonly VERBOSE="${VERBOSE:-0}"

source "$SCRIPT_DIR/env.sh"
source "$ROOT_DIR/etc/scripts/utils.sh"

validate_host

if ! grep -q "$HOMEBREW_PREFIX/bin/bash" /etc/shells; then
	logi "Update the list of available shells ..."
	run echo "$HOMEBREW_PREFIX/bin/bash" | run sudo tee -a /etc/shells
	run echo "$HOMEBREW_PREFIX/bin/fish" | run sudo tee -a /etc/shells
fi

if grep -q "$HOMEBREW_PREFIX/bin/bash" /etc/shells &&
	[[ $(dscl . -read "/Users/$USER" UserShell | cut -d' ' -f2-) != "$HOMEBREW_PREFIX/bin/bash" ]] ; then
	logi "Setting the default user shell to $HOMEBREW_PREFIX/bin/bash ..."
	run chsh -s "$HOMEBREW_PREFIX/bin/bash" "$(whoami)"
fi

if [[ -f /etc/paths.d/homebrew ]]; then
	# Don't want /etc/paths.d/homebrew making any changes to $PATH.
	# Homebrew's envvars will be explicitly set in .bash_profile and config.fish
	logi "Removing /etc/paths.d/homebrew ..."
	run sudo rm /etc/paths.d/homebrew
fi

exit 0
