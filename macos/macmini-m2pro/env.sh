#!/usr/bin/env /bin/bash
# shellcheck disable=SC2034

readonly EXPECTED_HOSTNAME="macmini-m2pro"
readonly NICE_HOSTNAME="${HOSTNAME/%.local/}"
