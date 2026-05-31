#!/bin/bash

(
    say_hello() {
        local -r callback_function="$1"
        shift
        echo "hello"
        bash -c "$callback_function" _ "$@"
        return 0
    }
    say_hello '
        variadic_argumnts="$@"
        echo "world"
    '
)

(
    say_hello() {
        local -r callback_function="$1"
        shift
        local -r callback_function_variadic_arguments=( "$@" )
        echo "hello"
        bash -c "$callback_function" _ "${callback_function_variadic_arguments[@]}"
        return 0
    }
    say_hello '
        variadic_argumnts="$@"
        echo "world"
    '
)

(
    say_hello() {
        local -r callback_function="$1"
        shift
        declare -a -r callback_function_variadic_arguments=( "$@" )
        echo "hello"
        bash -c "$callback_function" _ "${callback_function_variadic_arguments[@]}"
        return 0
    }
    say_hello '
        variadic_argumnts="$@"
        echo "world"
    '
)
