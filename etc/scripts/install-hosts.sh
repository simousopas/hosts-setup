#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR
# shellcheck disable=SC2155

# README
# This script automatically sets up /private/etc/host
#
# Pre-conditions:
# - `curl` must be installed in case you whish to pull Steven Black's hosts.
#
# The following switches are available:
# --with-sb-hosts-variant: Select a particular variant of Steven Black's hosts
#   to be installed. By default it will be the base 'Unifiedd' variant. Oher
#   variants can be found here: https://github.com/StevenBlack/hosts#list-of-all-hosts-file-variants
# --with-sb-hosts-version: Select a particular release of Steven Black's hosts
#   to be installed. By default it will be the latest one. Other versions can be
#   found here: https://github.com/StevenBlack/hosts/releases
# -v: Print major commands being executed.
# -vv: Print major commands being executed and their output.

set -Eeuo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
readonly ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
readonly SB_HOSTS_REPO="StevenBlack/hosts"
VERBOSE="${VERBOSE:-0}"
sb_hosts_variant=""
sb_hosts_version=""

source "$ROOT_DIR/etc/scripts/utils.sh"

parse_input_args () {
	while [[ $# -gt 0 ]]; do case $1 in
		--with-sb-hosts-variant) sb_hosts_variant="$2"; shift; shift;;
		--with-sb-hosts-version) sb_hosts_version="$2"; shift; shift;;
		-v) VERBOSE=1; shift;;
		*) shift;;
	esac; done
}

check_preconds () {
	logi "Checking pre-conditions ..."

	if [[ -n $sb_hosts_variant || -n $sb_hosts_version ]] && ! which -s curl; then
		loge "\`curl\` was not found but it's required by this script when pulling Steven Black's hosts."
		exit 1
	fi

	if [[ -n $sb_hosts_variant || -n $sb_hosts_version ]] && ! which -s jq; then
		loge "\`jq\` was not found but it's required by this script when pulling Steven Black's hosts."
		exit 1
	fi

	return 0
}

add_basic_hosts () {
	logi "Adding basic entries ..."
	{
		run echo "# Start: Basic hosts";
		run echo "127.0.0.1 localhost";
		run echo "127.0.0.1 localhost.localdomain";
		run echo "127.0.0.1 local"
		run echo "127.0.0.1 ${HOSTNAME/%.local/}"
		run echo "127.0.0.1 ${HOSTNAME/%.local/}.localdomain"
		run echo "255.255.255.255 broadcasthost"
		run echo "::1 localhost"
		run echo "::1 ip6-localhost"
		run echo "::1 ip6-loopback"
		run echo "fe80::1%lo0 localhost"
		run echo "ff00::0 ip6-localnet"
		run echo "ff00::0 ip6-mcastprefix"
		run echo "ff02::1 ip6-allnodes"
		run echo "ff02::2 ip6-allrouters"
		run echo "ff02::3 ip6-allhosts"
		run echo ""
	}>>"$TMPDIR/hosts"
}

add_stevenblack_hosts () {
	if [[ -z $sb_hosts_variant && -z $sb_hosts_version ]]; then
		return 0
	fi

	if [[ -z $sb_hosts_version || $sb_hosts_version == "latest" ]]; then
		logi "Querying StevenBlack's hosts latest available version ..."
		sb_hosts_version=$(
			run curl --fail --location --show-error --silent \
				--connect-timeout 13  --retry 5 --retry-delay 2 \
				--header "Accept:application/vnd.github.v3.raw" \
				"https://api.github.com/repos/$SB_HOSTS_REPO/releases/latest" |
			run jq --raw-output '.tag_name'
		)
		logi "The latest available version is $sb_hosts_version"
	fi

	logi "Downloading StevenBlack's hosts ..."
	local sb_hosts_url=""
	if [[ -z $sb_hosts_variant || $sb_hosts_variant == "unified" ]]; then
		sb_hosts_url="https://raw.githubusercontent.com/$SB_HOSTS_REPO/${sb_hosts_version}/hosts"
	else
		sb_hosts_url="https://raw.githubusercontent.com/$SB_HOSTS_REPO/${sb_hosts_version}/alternates/{$sb_hosts_variant}/hosts"
	fi
	run curl --fail --location --show-error --silent \
		--connect-timeout 13  --retry 5 --retry-delay 2 \
		--header "Accept:application/vnd.github.v3.raw" \
		--output "$TMPDIR/sb-hosts" \
		"$sb_hosts_url"

	logi "Parsing and merging StevenBlack's hosts ..."
	stdo=1 run sed '1,/^# End of custom host records.$/d' "$TMPDIR/sb-hosts" >>"$TMPDIR/hosts"
}


parse_input_args "$@"
check_preconds
add_basic_hosts
add_stevenblack_hosts

logi "Overwriting /private/etc/hosts ..."
run sudo mv "$TMPDIR/hosts" "/private/etc/hosts"

logi "Flushing the DNS cache ..."
run sudo dscacheutil -flushcache
run sudo killall mDNSResponder

logi "OK!"
