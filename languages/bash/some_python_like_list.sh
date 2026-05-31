#!/bin/bash

(
    function='
        #!/bin/bash

        declare -r -a variadic_arguments=( \"$@\" )
        declare -r a=\"$1\"
        declare -r b=\"$2\"

        echo $(( a / b ))
        return 0
    '
    declare -r some_python_like_list="[
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
        \"${function//$'\n'/\\n}\"
    ]"
    echo "${some_python_like_list}" | python3 -c 'import sys; import json; print(json.dumps(json.loads(sys.stdin.read()), indent=4))'
)
