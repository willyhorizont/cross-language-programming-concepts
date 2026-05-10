source("utils.r")

something <- js_like_undefined
utils$console_log(paste0('js_like_undefined === ', utils$json_stringify(something, pretty = FALSE)))
utils$console_log(utils$get_type(something))
utils$console_log()

something <- NULL
utils$console_log(paste0('NULL === ', utils$json_stringify(something, pretty = FALSE)))
utils$console_log(utils$get_type(something))
utils$console_log()

something <- TRUE
utils$console_log(paste0('TRUE === ', utils$json_stringify(something, pretty = FALSE)))
utils$console_log(utils$get_type(something))
utils$console_log()

something <- FALSE
utils$console_log(paste0('FALSE === ', utils$json_stringify(something, pretty = FALSE)))
utils$console_log(utils$get_type(something))
utils$console_log()

something <- "foo"
utils$console_log(paste0('"foo" === ', utils$json_stringify(something, pretty = FALSE)))
utils$console_log(utils$get_type(something))
utils$console_log()

something <- 123
utils$console_log(paste0('123 === ', utils$json_stringify(something, pretty = FALSE)))
utils$console_log(utils$get_type(something))
utils$console_log()

something <- 123.789
utils$console_log(paste0('123.789 === ', utils$json_stringify(something, pretty = FALSE)))
utils$console_log(utils$get_type(something))
utils$console_log()

something <- -123
utils$console_log(paste0('-123 === ', utils$json_stringify(something, pretty = FALSE)))
utils$console_log(utils$get_type(something))
utils$console_log()

something <- -123.789
utils$console_log(paste0('-123.789 === ', utils$json_stringify(something, pretty = FALSE)))
utils$console_log(utils$get_type(something))
utils$console_log()

something <- list(1, 2, 3)
utils$console_log(paste0('list(1, 2, 3) === ', utils$json_stringify(something, pretty = FALSE)))
utils$console_log(utils$get_type(something))
utils$console_log()

something <- js_like_object("foo" %:% "bar")
utils$console_log(paste0('js_like_object("foo" %:% "bar") === ', utils$json_stringify(something, pretty = FALSE)))
utils$console_log(utils$get_type(something))
utils$console_log()

something <- (\(l, w) (l * w))
utils$console_log(paste0(r'((\(l, w) (l * w)) === )', utils$json_stringify(something, pretty = FALSE)))
utils$console_log(utils$get_type(something))
utils$console_log()

something <- utils$json_stringify
utils$console_log(paste0('utils$json_stringify : ', utils$json_stringify(something, pretty = FALSE)))
utils$console_log(utils$get_type(something))
utils$console_log()

delivery_response_key_message <- "message"
delivery_response <- js_like_object(
    delivery_response_key_message %:% "ok",
    "status" %:% 200
)
utils$console_log(delivery_response[[delivery_response_key_message]])
utils$console_log(delivery_response[["status"]])

friend <- js_like_object(
    "first name" %:% "Alisa",
    "country" %:% "Finland",
    "age" %:% 25
)

utils$console_log(friend$"first name")

get_rectangle_area_v3 <- \(l, w) (l * w)
cat(get_rectangle_area_v3(7, 5))

# in R js-like Array is called unnamed list
# in R js-like Object is called named list

add_twenty_five <- (\(a) (a + 25))
multiply_by_ten <- (\(a) (a * 10))
add <- (\(a, b) (a + b))
multiply <- (\(a, b) (a * b))
get_prism_triangle_volume_part <- (\(triangle_length, triangle_height, prism_triangle_height, part_percent_int) ((((triangle_length * triangle_height) / 2) * prism_triangle_height) * (part_percent_int / 100)))

utils$console_log(multiply_by_ten(add_twenty_five(17))) # read from inside to outside

17 |> add_twenty_five() |> multiply_by_ten() |> utils$console_log() # read from left to right

utils$console_log(17 |> add_twenty_five() |> multiply_by_ten()) # read from left to right

utils$console_log(get_prism_triangle_volume_part(3, add(multiply(add_twenty_five(5), 10), 100), 4, 20)) # read from inside to outside

5 |> add_twenty_five() |> (\(x) (multiply(x, 10)))() |> (\(x) (add(x, 100)))() |> (\(x) (get_prism_triangle_volume_part(3, x, 4, 20)))() |> utils$console_log() # read from left to right

utils$console_log(5 |> add_twenty_five() |> (\(x) (multiply(x, 10)))() |> (\(x) (add(x, 100)))() |> (\(x) (get_prism_triangle_volume_part(3, x, 4, 20)))()) # read from left to right

5 |> add_twenty_five() |> utils$curry(multiply, 10)() |> utils$curry(add, 100)() |> (\(x) (get_prism_triangle_volume_part(3, x, 4, 20)))() |> utils$console_log() # read from left to right

utils$console_log(5 |> add_twenty_five() |> utils$curry(multiply, 10)() |> utils$curry(add, 100)() |> (\(x) (get_prism_triangle_volume_part(3, x, 4, 20)))()) # read from left to right

5 |> add_twenty_five() |> multiply(10) |> add(100) |> (\(x) (get_prism_triangle_volume_part(3, x, 4, 20)))() |> utils$console_log() # read from left to right

utils$console_log(5 |> add_twenty_five() |> multiply(10) |> add(100) |> (\(x) (get_prism_triangle_volume_part(3, x, 4, 20)))()) # read from left to right
