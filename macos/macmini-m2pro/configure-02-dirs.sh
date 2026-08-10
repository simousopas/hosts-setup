#!/usr/bin/env /bin/bash
# shellcheck disable=SC2155

set -Eeuo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
readonly ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
readonly VERBOSE="${VERBOSE:-0}"

source "$SCRIPT_DIR/env.sh"
source "$ROOT_DIR/etc/scripts/utils.sh"

validate_host

logi "Creating the directories structure ..."
run mkdir -p "$HOME"/{.bash_completion.d,.gnupg,.ssh/sockets}
run mkdir -p "$HOME"/.local/{bin,share/lf}
run mkdir -p "$HOME"/Library/{KeyBindings,LaunchAgents}
run mkdir -p "$HOME"/Library/Application\ Support/Code/User
run mkdir -p "$HOME"/Library/Application\ Support/com.nuebling.mac-mouse-fix
run mkdir -p "$HOME"/Library/Application\ Support/obs-studio/basic
run mkdir -p "$XDG_CACHE_HOME"/code/{data/User,extensions}
run mkdir -p "$XDG_CONFIG_HOME"/{bat/themes,fd,fish/completions}
run mkdir -p "$XDG_CONFIG_HOME"/{ghostty,git,lf,lima}
run mkdir -p "$XDG_CONFIG_HOME"/{mise,nvim,pip,rg,zed}
run mkdir -p "$CODE"

if [[ -d $EXTERNAL_VOLUME ]]; then
	run mkdir -p "$EXTERNAL_VOLUME"/.cache/{container,lima}
	run mkdir -p "$EXTERNAL_VOLUME"/Developer/{github,simousopas}
	run mkdir -p "$EXTERNAL_VOLUME"/Documents/{Captures,Misc,Remote}
	run mkdir -p "$EXTERNAL_VOLUME"/Downloads/{Brave,Misc,Safari,Torrents}

	run ln -fhs "$EXTERNAL_VOLUME"/.cache/container "$XDG_CACHE_HOME/container"
	run ln -fhs "$XDG_CACHE_HOME"/container "$HOME/Library/Application Support/com.apple.container"
	run ln -fhs "$EXTERNAL_VOLUME"/.cache/lima "$XDG_CACHE_HOME/lima"
	run ln -fhs "$XDG_CACHE_HOME"/lima "$HOME/Library/Caches/lima"

	run ln -fhs "$EXTERNAL_VOLUME"/Developer/github "$CODE"
	run ln -fhs "$EXTERNAL_VOLUME"/Developer/simousopas "$CODE"

	run ln -fhs "$EXTERNAL_VOLUME"/Documents/Captures "$DOCUMENTS"
	run ln -fhs "$EXTERNAL_VOLUME"/Documents/Misc "$DOCUMENTS"
	run ln -fhs "$EXTERNAL_VOLUME"/Documents/Remote "$DOCUMENTS"

	run ln -fhs "$EXTERNAL_VOLUME"/Downloads/Brave "$DOWNLOADS"
	run ln -fhs "$EXTERNAL_VOLUME"/Downloads/Misc "$DOWNLOADS"
	run ln -fhs "$EXTERNAL_VOLUME"/Downloads/Safari "$DOWNLOADS"
	run ln -fhs "$EXTERNAL_VOLUME"/Downloads/Torrents "$DOWNLOADS"
fi
