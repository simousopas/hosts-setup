# shellcheck disable=SC2155

loge () {
	printf '[%s] ERROR: %s\n' "${0##*/}" "$*" >&2;
}

logi () {
	printf '[%s] %s\n' "${0##*/}" "$*" >&2
}

run () {
	[[ ${VERBOSE:-0} -gt 0 ]] && printf "\t%s\n" "$*" >&2

	[[ ! -t 0 ]] && local input=$(cat)
	local stde_file=$(mktemp)
	local stdo_file=$(mktemp)
	set +e
	if [[ ! -t 0 ]]; then
		echo "$input" | "$@" 1>"$stdo_file" 2>"$stde_file"
	else
		"$@" 1>"$stdo_file" 2>"$stde_file"
	fi
	local status=$?
	set -e

	[[ ! -t 1 ]] && cat "$stdo_file"
	[[ $status -gt 0 ]] && loge "$(cat "$stde_file")"

	rm -rf "$stde_file" "$stdo_file"
	return $status
}

validate_host () {
	[[ ! $NICE_HOSTNAME == $EXPECTED_HOSTNAME* ]] &&
		loge "This script belongs to another host '$EXPECTED_HOSTNAME'. The current one is '$NICE_HOSTNAME'." &&
		return 1

	return 0
}
