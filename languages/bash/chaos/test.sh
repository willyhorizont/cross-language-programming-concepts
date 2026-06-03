#!/bin/bash

MULTILINE_TEXT='#!/bin/bash

declare -r -a variadic_arguments=( "$@" )
declare -r a="$1"
declare -r b="$2"

echo $(( a * b ))'

ONELINE_TEXT=$(echo "$MULTILINE_TEXT" | jq -Rs .)

JSON_DATA=$(echo "[
    null,
    true,
    false,
    \"foo\",
    123,
    -123,
    123.789,
    -123.789,
    [1, 2, 3],
    { \"foo\": \"bar\" },
    $ONELINE_TEXT
]")

# echo "$JSON_DATA" | jq -r ".[10]"

# echo "$JSON_DATA" > "./languages/bash/test.json"

bash -c "$(jq -r '.[10]' < <(echo "$JSON_DATA"))" _ 5 4
