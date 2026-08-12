#!/usr/bin/env /bin/bash
# shellcheck disable=SC2034

readonly EXPECTED_HOSTNAME="macstudio-m1ultra"
readonly NICE_HOSTNAME="${HOSTNAME/%.local/}"
