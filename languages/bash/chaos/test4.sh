declare -r -a variadic_arguments=( "$@" )
declare -r a="$1"
declare -r b="$2"

echo $(( a * b ))