#!/usr/bin/env bash
# parse a json array

# value: any valid json type
#              ┌────────────────┐
#              ▼                ▲
# start ──► [ ─┴─┬──► value ──┬─┴──► ] ──► end
#                ╰──►   ,  ─►─╯

# shellcheck source=./_util.sh
source ./json/_util.sh

# shellcheck source=./_root.sh
source ./json/_root.sh

_array() {
  local value next R _R c
  local next="${1}"
  [ -z "$next" ] && return 99
  # consume the opening bracket
  next="${next:1}" && _inc_counter
  while ! [[ "$(_last_char "$next")" = "]" ]]; do
    c="${next:0:1}"
    [ "$c" = "]" ] && break
    if [ -z "$c" ] || [ "$c" = "," ]; then
      _ERROR_SYNTAX "$c" || return "$?"
    fi
    _R="$(parse_json "$next)"
    eval R="$_R"
    value="${R[0]}"
    next="${R[1]}"
  done
}
