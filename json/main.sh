#!/usr/bin/env bash
export _JSON_SH_VERSION=0.0.1
# source grammar from https://ecma-international.org/publications-and-standards/standards/ecma-404/

export __DATAFILE__="$(mktemp -t json_basher.XXXXXXXXXX)"
trap 'rm -f "$__DATAFILE__"' EXIT

# shellcheck source=./common.sh
source ./json/common.sh
# shellcheck source=./_util.sh
source ./json/_util.sh
# shellcheck source=./_string.sh
source ./json/_string.sh
# shellcheck source=./_number.sh
source ./json/_number.sh
# shellcheck source=./_literals.sh
source ./json/_literals.sh
# shellcheck source=./_object.sh
source ./json/_object.sh
# shellcheck source=./_array.sh
source ./json/_array.sh
# shellcheck source=./_root.sh
source ./json/_root.sh

export GLOBAL_COUNTER=0
export _KEY_PATH=()
declare -A _DATA_OBJECT
export KEY_DIVIDER="${KEY_DIVIDER:-.}"

enter() {
  #  set -x
  local opts raw_data
  local raw_path="."
  opts="$(getopt -o "" --long "" -n json_basher -- "$@")"
  [ "$?" -eq 0 ] || {
                      echo error
                                  return 1
  }
  eval set -- "$opts"
  #  any option parsing will go here
  while true; do
    case "$1" in
      --)
        shift
        break
        ;;
      -* | --*)
        printf "'%s' is not a valid flag\n" "$1" >&2
        return 1
        ;;
    esac
    sleep 0.5
  done
  case "$#" in
    0)
      raw_data="$(cat -)"
      ;;
    1)
      # if the argument is a file, then we
      #  assume we want that as the input, otherwise
      # we assume the first arg is a path expression
      if [ -f "$1" ]; then
        read -r -d '' raw_data < "$1"
      else
        raw_path="$1"
        raw_data="$(cat -)"
      fi
      ;;
    2)
      read -r -d '' raw_data < "$2"
        raw_path="$1"
        ;;
    *)
      printf "Unable to parse inputs %s\n" "$*" >&2
      exit 1
      ;;
  esac
  local current_path=""
  parse_json "$current_path" "$raw_data"
}

# if we are running this as a script to do some task we can do that
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
  enter "$@"
fi