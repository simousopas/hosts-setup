#!/usr/bin/env /bin/bash
# shellcheck disable=SC2155

set -Eeuo pipefail

readonly HOMEBREW_INSTALL_SCRIPT_URL="https://raw.githubusercontent.com/Homebrew/install/master/install.sh"
readonly SCRIPT_DIR="$(cd "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
readonly ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
readonly VERBOSE="${VERBOSE:-0}"

source "$SCRIPT_DIR/env.sh"
source "$ROOT_DIR/etc/scripts/utils.sh"

validate_host

if [[ -z "$(command -v brew)" ]]; then
	logi "Installing Homebrew ..."
	/bin/bash -c "$(
		run curl --fail --location --silent --show-error \
			"$HOMEBREW_INSTALL_SCRIPT_URL"
	)"
else
	logi "Homebrew is already installed at $(command -v brew)."
fi
