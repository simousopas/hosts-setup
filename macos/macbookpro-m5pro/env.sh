#!/usr/bin/env /bin/bash
# shellcheck disable=SC2034

readonly EXPECTED_HOSTNAME="macbookpro-m5pro"
readonly NICE_HOSTNAME="${HOSTNAME/%.local/}"
