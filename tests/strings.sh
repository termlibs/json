#!/usr/bin/env bash

# shellcheck source=../json/_string.sh
source ./json/_string.sh

# shellcheck source=../json/logging.sh
source ./json/logging.sh

# shellcheck source=./util.sh
source ./tests/util.sh

for s in \
  '"this is a string!"' \
  '"this is a string with a \"quote\""' \
  '"\t\thello!\n\n"' \
  '"\u0000 \uFFFf or something"'; do
  _s="${s:1:-1}"
  _s="${_s//\\\\/\\}"
  _R="$(_string "$s")"
  eval R="$_R"
  assert_string_eq "${R[0]}" "$_s"
done

for s in \
  '" this is \z bad escape sequence"' \
  '"\uF3MN is not unicode"' \
  '"This is a string that doesnt terminate' \
  '4'; do
  _R="$(_string "$s")"
  assert_error --code 99 _string "$s" > /dev/null
done
