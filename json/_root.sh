#!/usr/bin/env bash

# source grammar from https://ecma-international.org/publications-and-standards/standards/ecma-404/
# start ──┬───► object ────┬─► end
#         ├───► array ──►──┤
#         ├───► number ─►──┤
#         ├───► string ─►──┤
#         ├───► true  ──►──┤
#         ├───► false ──►──┤
#         ╰───► null  ──►──╯

# parse_json
# `args:` ( next: raw json string )
# returns: ( value: string, next: string )
# takes any valid string and tries to parse it from the beginning
# will return the value as soon as it can and returns the rest of the string to be parsed
# separately
parse_json() {
  local next="$(slurp_whitespace "$1")"
  [ -z "$next" ] && return 99
  case "$CHAR" in
    '"')
      _R="$(_string "$next")" || return "$?"
      eval R="$_R"
      value=${R[0]}
      next=${R[1]}
      _set_value "$value"
      _pop_key
      ;;
    [[:digit:]] | '-')
     _R="$(_number "$next")" || return "$?"
      eval R="$_R"
      value=${R[0]}
      next=${R[1]}
      ;;
    "t")
     _R="$(_true "$next")" || return "$?"
      eval R="$_R"
      value=${R[0]}
      next=${R[1]}
      ;;
    "f")
     _R="$(_false "$next")" || return "$?"
      eval R="$_R"
      value=${R[0]}
      next=${R[1]}
      ;;
    "n")
     _R="$(_null "$next")" || return "$?"
      eval R="$_R"
      value=${R[0]}
      next=${R[1]}
      ;;
    '{')
     _R="$(_object "$next")" || return "$?"
      eval R="$_R"
      value=${R[0]}
      next=${R[1]}
      ;;
    '[')
     _R="$(_array "$next")" || return "$?"
      eval R="$_R"
      value=${R[0]}
      next=${R[1]}
      ;;
    *)
      _ERROR_SYNTAX "$GLOBAL_COUNTER" "$FIRST_CHAR" >&2
      return 99
      ;;
  esac
  printf '( %s %s )' "${value@Q}" "${next@Q}"
}
