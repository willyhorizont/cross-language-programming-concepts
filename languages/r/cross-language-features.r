source("../../runtimes/r/willyhorizont/runtime/xl.r")

# 1. support lambda as value, or has workaround
say_hello <- \(callback_function) {
    xl$catln("hello")
    callback_function()
}
say_hello(\() {
    xl$catln("world")
})
create_multiplier <- \(aa) \(bb) aa * bb
multiply_by_two <- create_multiplier(2)
xl$catln("multiply_by_two(10): ", multiply_by_two(10))
multiply_by_eight <- create_multiplier(8)
xl$catln("multiply_by_eight(4): ", multiply_by_eight(4))
xl$catln("multiply_by_two(8): ", multiply_by_two(8))

# 2. support dynamic-typed value, or has workaround
xl_list <- list(
    NULL,
    TRUE,
    FALSE,
    "foo",
    0,
    -123,
    123.789,
    -123.789,
    list(1, 2, 3),
    xl$dict("foo" = "bar"),
    \(aa, bb) aa * bb
)
xl$catln("xl_list: ", xl$json_stringify(xl_list))
xl$catln("xl_list: ", xl$json_stringify(xl_list, "pretty" = TRUE))
xl_dict <- xl$dict(
    "xl_none" = NULL,
    "xl_bool_true" = TRUE,
    "xl_bool_false" = FALSE,
    "xl_string" = "foo",
    "xl_int_positive" = 0,
    "xl_int_negative" = -123,
    "xl_float_positive" = 123.789,
    "xl_float_negative" = -123.789,
    "xl_list" = list(1, 2, 3),
    "xl_dict" = xl$dict("foo" = "bar"),
    "xl_lambda" = \(aa, bb) aa * bb
)
xl$catln("xl_dict: ", xl$json_stringify(xl_dict))
xl$catln("xl_dict: ", xl$json_stringify(xl_dict, "pretty" = TRUE))
