#!/bin/bash

(
    # 1. support function as value
    declare -r say_hello='
        #!/bin/bash

        declare -r -a variadic_arguments=( "$@" )
        declare -r callback_function="$1"

        echo "hello"
        bash -c "$callback_function" _ "${variadic_arguments[@]:1}"
        return 0
    '
    bash -c "$say_hello" _ '
        #!/bin/bash

        declare -r -a variadic_arguments=( "$@" )

        echo "world"
        return 0
    ' 2>/dev/null
    declare -r multiply='
        #!/bin/bash

        declare -r -a variadic_arguments=( "$@" )
        declare -r a="$1"

        echo "
            declare -r -a variadic_arguments=( "$@" )
            declare -r b=\"\$1\"

            echo \$(($a * b))
            return 0
        "
        return 0
    '
    declare -r multiply_by_two="$(bash -c "$multiply" _ 2 2>/dev/null)"
    echo "bash -c \"\$multiply_by_two\" _ 10 2>/dev/null: $(bash -c "$multiply_by_two" _ 10 2>/dev/null)"
    declare -r multiply_by_eight="$(bash -c "$multiply" _ 8 2>/dev/null)"
    echo "bash -c \"\$multiply_by_eight\" _ 4 2>/dev/null: $(bash -c "$multiply_by_eight" _ 4 2>/dev/null)"
    echo "bash -c \"\$multiply_by_two\" _ 8 2>/dev/null: $(bash -c "$multiply_by_two" _ 8 2>/dev/null)"

    # 2. support dynamic-typed value, or has workaround
    declare -a some_python_like_list=()
    some_python_like_list+=( "" ) # null
    some_python_like_list+=( "any-non-empty-string" ) # true
    some_python_like_list+=( "" ) # false
    some_python_like_list+=( "foo" )
    some_python_like_list+=( 123 )
    some_python_like_list+=( -123 )
    some_python_like_list+=( "123.789" )
    some_python_like_list+=( "-123.789" )
    some_python_like_list+=( 1 2 3 )
    some_python_like_list+=( [foo]="bar" )
    some_python_like_list+=( '
            #!/bin/bash

            declare -r -a variadic_arguments=( "$@" )
            declare -r a="$1"
            declare -r b="$2"

            echo $(( a * b ))
            return 0
        ' )
    declare -A some_python_like_dict=()
    some_python_like_dict[some_null]="" # null
    some_python_like_dict[some_boolean_true]="any-non-empty-string" # true
    some_python_like_dict[some_boolean_false]="" # false
    some_python_like_dict[some_string]="foo"
    some_python_like_dict[some_int_positive]=123
    some_python_like_dict[some_int_negative]=-123
    # some_python_like_dict[some_float_positive]=123.789 # error
    some_python_like_dict[some_float_positive]="123.789"
    # some_python_like_dict[some_float_negative]=-123.789 # error
    some_python_like_dict[some_float_negative]="-123.789"
    # some_python_like_dict[some_python_like_list]=( 1 2 3 ) # error
    # some_python_like_dict[some_python_like_dict]=( [foo]="bar" ) # error
    some_python_like_dict[some_function]='
            #!/bin/bash

            declare -r -a variadic_arguments=( "$@" )
            declare -r a="$1"
            declare -r b="$2"

            echo $(( a * b ))
            return 0
        '
)
