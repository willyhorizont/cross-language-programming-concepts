#import "/runtimes/typst/willyhorizont/runtime/xl.typ" as xl
#show: xl.runtime

#{
    /*
    1. support closure as value, or has workaround
    */
    let say-hello = (callback-function) => {
        xl.print-cmd("hello")
        callback-function()
    }
    say-hello(() => {
        xl.print-cmd("world")
    })
    let create-multiplier = (a) => (b) => (a * b)
    let multiply-by-two = create-multiplier(2)
    xl.print-cmd([multiply_by_two(10): #{xl.json-stringify(multiply-by-two(10))}])
    let multiply-by-eight = create-multiplier(8)
    xl.print-cmd([multiply_by_eight(4): #{xl.json-stringify(multiply-by-eight(4))}])
    xl.print-cmd([multiply_by_two(8): #{xl.json-stringify(multiply-by-two(8))}])

    /*
    2. support dynamic-typed value, or has workaround
    */
    let xl-list = (
        none,
        true,
        false,
        "foo",
        0,
        -123,
        123.789,
        -123.789,
        (1, 2, 3),
        ("foo": "bar"),
        (a, b) => (a * b),
    )
    xl.print-cmd([xl_list: #{xl.json-stringify(xl-list)}])
    xl.print-cmd([xl_list: #{xl.json-stringify(xl-list, pretty: true)}])
    let xl-dict = (
        "xl_none": none,
        "xl_bool_true": true,
        "xl_bool_false": false,
        "xl_string": "foo",
        "xl_int_positive": 0,
        "xl_int_negative": -123,
        "xl_float_positive": 123.789,
        "xl_float_negative": -123.789,
        "xl_list": (1, 2, 3),
        "xl_dict": ("foo": "bar"),
        "xl_closure": (a, b) => (a * b),
    )
    xl.print-cmd([xl_dict: #{xl.json-stringify(xl-dict)}])
    xl.print-cmd([xl_dict: #{xl.json-stringify(xl-dict, pretty: true)}])
}
