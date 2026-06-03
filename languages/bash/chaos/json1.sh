#!/bin/bash

(
    declare -r some_python_like_list=$(echo "[
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

                                                        echo $(( a * b ))
                                                        ' | sed 's/^[ \t]*//' | jq -Rs .)
                                            ]")
    // ' | sed 's/^[ \t]*//' | jq -Rs .
    // ' | jq -Rs . | jq '
    //     gsub("(?<! ) (?! )"; "&nbsp;") |
    //     gsub("[ \t]{2,}"; "") |
    //     gsub("&nbsp;"; " ")
    // '
    echo "$some_python_like_list" | jq -r "."
    bash -c "$(jq -r '.[10]' < <(echo "$some_python_like_list"))" _ 7 5
    echo "get_rectangle_area(7, 5): $(bash -c "$(jq -r '.[10]' < <(echo "$some_python_like_list"))" _ 7 5)"
)
