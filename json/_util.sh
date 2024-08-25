#!/usr/bin/env bash



_ERROR_SYNTAX() {
  printf "SYNTAX ERROR: Unexpected character at position %d: '%s'\n" "$1" "$2" >&2
  return 99
}

save_data() {
  local path="$1"
  local value="$2"
  printf "%s=%s\n" "$path" "${value@Q}" >> "$__DATAFILE__"
}

slurp_whitespace() {
  local CHAR="${1:0:1}"
  local raw_input="$1"
  local first_char=0
  case "$CHAR" in
    [[:space:]])
      first_char="$(_next_token_index "$raw_input")"
      ;;
    *) ;;
  esac

  printf "%s" "${raw_input:$first_char}"
}

_next_token_index() {
  local trim_plus_1="${1#*[![:space:]]}"
  local start="$((${#1} - ${#trim_plus_1} - 1))"
  printf "%d" "$start"
}


_inc_counter() {
  local char_index
  read -r -d '' char_index < "$_TMP/char_index"
  char_index=$((char_index + 1))
  printf "%d" "$char_index" > "$_TMP/char_index"
}

_add_key() {
  local path
  local key="$1"
  printf "%s\n" "${key@Q}" >> "$_TMP/path"
}

_peek_key() {
  local path last_key
  read -r -d '' last_key < <(tail -n 1 "$_TMP/path")
  eval last_key="$last_key"
  printf "%s" "${last_key}"
}

_pop_key() {
  local path last_key
  read -r -d '' last_key < <(tail -n 1 "$_TMP/path")
  head -n -1 "$_TMP/path" > "$_TMP/path.tmp"
  mv "$_TMP/path.tmp" "$_TMP/path"
  eval last_key="$last_key"
  printf "%s\n" "${last_key}"
}

_get_path() {
  local path_string path_array
  if [ ! -f "$_TMP/path" ]; then
    touch "$_TMP/path"
  fi
  eval path_array="($(cat "$_TMP/path"))"
  path_string=""
  for p in "${path_array[@]}"; do
    path_string+="${KEY_DIVIDER}${p@Q}"
  done
  printf "%s\n" "${path_string}"
}

_set_value() {
  local value="$1"
  local path="$(_get_path)"
  printf "%s=%s\n" "$path" "${value@Q}" >> "$_TMP/data"
}