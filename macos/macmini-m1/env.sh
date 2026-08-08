#!/usr/bin/env /bin/bash
# shellcheck disable=SC2034

readonly EXPECTED_HOSTNAME="macmini-m1"
readonly NICE_HOSTNAME="${HOSTNAME/%.local/}"
