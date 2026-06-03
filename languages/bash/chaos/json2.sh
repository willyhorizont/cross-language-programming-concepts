#!/bin/bash

(
    # 1. support function as value
    declare -r say_hello='#!/bin/bash

                        declare -r -a variadic_arguments=( "$@" )
                        declare -r callback_function="$1"

                        echo "hello"
                        bash -c "$callback_function" _ "${variadic_arguments[@]:1}"
                        '
    bash -c "$say_hello" _ '#!/bin/bash

                            declare -r -a variadic_arguments=( "$@" )

                            echo "world"
                            '
    declare -r multiply='#!/bin/bash

                        declare -r -a variadic_arguments=( "$@" )
                        declare -r a="$1"

                        echo "#!/bin/bash

                            declare -r -a variadic_arguments=( "$@" )
                            declare -r b=\"\$1\"

                            echo \$(($a * b))
                            "
                        '
    declare -r multiply_by_two="$(bash -c "$multiply" _ 2)"
    echo "bash -c \"\$multiply_by_two\" _ 10: $(bash -c "$multiply_by_two" _ 10)"
    declare -r multiply_by_eight="$(bash -c "$multiply" _ 8)"
    echo "bash -c \"\$multiply_by_eight\" _ 4: $(bash -c "$multiply_by_eight" _ 4)"
    echo "bash -c \"\$multiply_by_two\" _ 8: $(bash -c "$multiply_by_two" _ 8)"

    # 2. support dynamic-typed value, or has workaround
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
                                                        ' | jq -Rs .)
                                            ]")
    echo "$some_python_like_list" | jq -r "."
    bash -c "$(jq -r '.[10]' < <(echo "$some_python_like_list"))" _ 7 5
    echo "get_rectangle_area(7, 5): $(bash -c "$(jq -r '.[10]' < <(echo "$some_python_like_list"))" _ 7 5)"
    declare -r some_python_like_dict=$(echo "{
                                                \"some_null\": null,
                                                \"some_boolean_true\": true,
                                                \"some_boolean_false\": false,
                                                \"some_string\": \"foo\",
                                                \"some_int_positive\": 123,
                                                \"some_int_negative\": -123,
                                                \"some_float_positive\": 123.789,
                                                \"some_float_negative\": -123.789,
                                                \"some_python_like_list\": [1, 2, 3],
                                                \"some_python_like_dict\": { \"foo\": \"bar\" },
                                                \"some_function\": $(echo '#!/bin/bash

                                                                            declare -r -a variadic_arguments=( "$@" )
                                                                            declare -r a="$1"
                                                                            declare -r b="$2"

                                                                            echo $(( a * b ))
                                                                            ' | jq -Rs .)
                                            }")
    echo "$some_python_like_dict" | jq -r "."
    bash -c "$(jq -r '.some_function' < <(echo "$some_python_like_dict"))" _ 7 5
    echo "get_rectangle_area(7, 5): $(bash -c "$(jq -r '.some_function' < <(echo "$some_python_like_dict"))" _ 7 5)"
)
