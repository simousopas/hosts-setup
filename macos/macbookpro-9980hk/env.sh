#!/usr/bin/env /bin/bash
# shellcheck disable=SC2034

readonly EXPECTED_HOSTNAME="macbookpro-9980hk"
readonly NICE_HOSTNAME="${HOSTNAME/%.local/}"
