#!/usr/bin/env bash

# shellcheck source=../json/main.sh
source ./json/main.sh

# shellcheck source=../json/logging.sh
source ./json/logging.sh

# shellcheck source=./util.sh
source ./tests/util.sh

test_string='
{"this": "is", "a": "test"}
'
echo "$test_string"
parse_json "" "$test_string"
echo cat "$__DATAFILE__"
