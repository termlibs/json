#!/usr/bin/env bash

export GLOBAL_COUNTER=0

# shellcheck source=./_util.sh
source ./json/_util.sh

# source grammar from https://ecma-international.org/publications-and-standards/standards/ecma-404/
#
#    valid_char  = any char except " or \
#    4dx = 4 digit hex for UTF-32
#               (?:)  0     1/2
#  ┌─────┐                                         x x
#  │start┼────► " ─────────────────────────► " ───► x
#  └─────┘      │ ┌───────────────────────┐  │     x x
#               │ ▼                       ▲  ▲
#               ╰─┴─┬────► valid_char ──┬─┴──╯
#                   ▼                   ▲
#                   ╰─ \ ─┬─ " ──────┬──╯
#                         ▼          ▲
#                         ├─ \ ───►──┤
#                         ├─ / ───►──┤
#                         ├─ b ───►──┤
#                         ├─ f ───►──┤
#                         ├─ n ───►──┤
#                         ├─ r ───►──┤
#                         ├─ t ───►──┼
#                         ╰─ u 4dx ─►╯
#                              2.5^

# args: (to_process string, partial value string)
# returns (value: string, next: string)
_s_2_5() {
  # our restrictions here are my interpretation of json spec
  # which is case is insensitive and any combination of 31 bits is ok
  # so long as it is valid hex
  local value next R
  local to_process REMAINDER CHAR value
  to_process="${1}"
  value="${2}"
  for i in {1..4}; do
    CHAR="${to_process:0:1}"
    REMAINDER="${to_process:1}"
    value="${value}${CHAR}"
    to_process="$REMAINDER"
    case "$CHAR" in
      [0-9a-fA-F]) ;;
      *)
        return 99
        ;;
    esac
  done
_R="$(_s_2 "$REMAINDER" "$value")" || return "$?"
  eval R="$_R"
  value=${R[0]}
  next=${R[1]}
  printf "( %s %s )" "${value@Q}" "${next@Q}"
}

_s_2() {
  _s_1 "$@"
}

# args: (to_process string, partial value string)
# returns (value: string, next: string)
_s_1() {
  local value next R
  local CHAR="${1:0:1}"
  local REMAINDER="${1:1}"
  [ -z "$CHAR" ] && return 99 #  not a valid termination state
  local value="${2}${CHAR}"
  case "$CHAR" in
    \")
      value="${value%\"}" # remove quote
      next="${REMAINDER#\"}" # remove the quote
      ;;
    \\)
      _R="$(_s_0 "$REMAINDER" "$value")" || return "$?"
      eval R="$_R"
      value=${R[0]}
      next=${R[1]}
      ;;
    *)
     _R="$(_s_1 "$REMAINDER" "$value")" || return "$?"
      eval R="$_R"
      value=${R[0]}
      next=${R[1]}
      ;;
  esac
  printf "( %s %s )" "${value@Q}" "${next@Q}"
}

# args: (to_process string, partial value string)
# returns (value: string, next: string)
_s_0() {
  local value next R
  local CHAR="${1:0:1}"
  local next="${1:1}"
  local value="${2}${CHAR}"
  case "$CHAR" in
    \" | \\ | \/ | b | f | n | r | t | 8)
      _R="$(_s_2 "$next" "$value")" || return "$?"
      eval R="$_R"
      value=${R[0]}
      next=${R[1]}
      ;;
    u)
      _R="$(_s_2_5 "$next" "$value")" || return "$?"
      eval R="$_R"
      value=${R[0]}
      next=${R[1]}
      ;;
    *)
      return 99
      ;;
  esac
  printf "( %s %s )" "${value@Q}" "${next@Q}"
}

# args: (raw string)
# returns (value: string, next: string)
_string() {
  # quote has been recognized but not stripped yet
  local value next R
  local value="${1:1:1}" # skip the quote
  local next="${1:2}"
  [ "$value" = '"' ] && [ -z "$next" ] && return 0 # empty string
  case "$value" in                                      # we are at the first char after the quote
    \\)
      _R="$(_s_0 "$next" "$value")" || return "$?"
      eval R="$_R"
      value=${R[0]}
      next=${R[1]}
      ;;
    *)
     _R="$(_s_1 "$next" "$value")" || return "$?"
      eval R="$_R"
      value=${R[0]}
      next=${R[1]}
      ;;
  esac
  printf '( %s %s )' "${value@Q}" "${next@Q}"
}

_unwrap_string_value() {
  _R="$(_string "$1")" || return "$?"
  eval R="$_R"
  printf "%s" "${R[0]}"
}