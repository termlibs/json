#!/usr/bin/env bash

# shellcheck source=../json/_string.sh
source ./json/_string.sh

# shellcheck source=../json/logging.sh
source ./json/logging.sh

# shellcheck source=./assert.sh
source ./tests/assert.sh

for s in \
  '"this is a string!"' \
  '"this is a string with a \"quote\""' \
  '"\t\thello!\n\n"' \
  '"\u0000 \uFFFf or something"'; do
  _s="${s:1:-1}"
  _s="${_s//\\\\/\\}"
  eval R="$(_string "$s")"
  assert_string_eq "${R[0]}" "$_s"
done

for s in \
  '" this is \z bad escape sequence"' \
  '"\uF3MN is not unicode"' \
  '"This is a string that doesnt terminate' \
  '4'; do
  assert_error --code 99 _unwrap_string "$s" > /dev/null
done
