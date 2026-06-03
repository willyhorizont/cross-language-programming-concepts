#!/bin/bash

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
    $(echo '#!/bin/bash

declare -r -a variadic_arguments=( "$@" )
declare -r a="$1"
declare -r b="$2"

echo $(( a * b ))' | jq -Rs .)
]")

echo "$JSON_DATA" | jq -r ".[10]"

# echo "$JSON_DATA" > "./languages/bash/test.json"

bash -c "$(jq -r '.[10]' < <(echo "$JSON_DATA"))" _ 5 4
