source("../../utils/utils.r")
console_log <- willy_horizont$utils$console_log
json_stringify <- willy_horizont$utils$json_stringify
get_type <- willy_horizont$utils$get_type
curry <- willy_horizont$utils$curry

something <- js_like_undefined
console_log(paste0('js_like_undefined === ', json_stringify(something, pretty = FALSE)))
console_log(get_type(something))
console_log()

something <- NULL
console_log(paste0('NULL === ', json_stringify(something, pretty = FALSE)))
console_log(get_type(something))
console_log()

something <- TRUE
console_log(paste0('TRUE === ', json_stringify(something, pretty = FALSE)))
console_log(get_type(something))
console_log()

something <- FALSE
console_log(paste0('FALSE === ', json_stringify(something, pretty = FALSE)))
console_log(get_type(something))
console_log()

something <- "foo"
console_log(paste0('"foo" === ', json_stringify(something, pretty = FALSE)))
console_log(get_type(something))
console_log()

something <- 123
console_log(paste0('123 === ', json_stringify(something, pretty = FALSE)))
console_log(get_type(something))
console_log()

something <- 123.789
console_log(paste0('123.789 === ', json_stringify(something, pretty = FALSE)))
console_log(get_type(something))
console_log()

something <- -123
console_log(paste0('-123 === ', json_stringify(something, pretty = FALSE)))
console_log(get_type(something))
console_log()

something <- -123.789
console_log(paste0('-123.789 === ', json_stringify(something, pretty = FALSE)))
console_log(get_type(something))
console_log()

something <- list(1, 2, 3)
console_log(paste0('list(1, 2, 3) === ', json_stringify(something, pretty = FALSE)))
console_log(get_type(something))
console_log()

something <- js_like_object("foo" %:% "bar")
console_log(paste0('js_like_object("foo" %:% "bar") === ', json_stringify(something, pretty = FALSE)))
console_log(get_type(something))
console_log()

something <- (\(l, w) (l * w))
console_log(paste0(r'((\(l, w) (l * w)) === )', json_stringify(something, pretty = FALSE)))
console_log(get_type(something))
console_log()

something <- json_stringify
console_log(paste0('json_stringify : ', json_stringify(something, pretty = FALSE)))
console_log(get_type(something))
console_log()

delivery_response_key_message <- "message"
delivery_response <- js_like_object(
    delivery_response_key_message %:% "ok",
    "status" %:% 200
)
console_log(delivery_response[[delivery_response_key_message]])
console_log(delivery_response[["status"]])

friend <- js_like_object(
    "first name" %:% "Alisa",
    "country" %:% "Finland",
    "age" %:% 25
)

console_log(friend$"first name")

get_rectangle_area_v3 <- \(l, w) (l * w)
console_log(get_rectangle_area_v3(7, 5))

# in R js-like Array is called unnamed list
# in R js-like Object is called named list

add_twenty_five <- (\(a) (a + 25))
multiply_by_ten <- (\(a) (a * 10))
add <- (\(a, b) (a + b))
multiply <- (\(a, b) (a * b))
get_prism_triangle_volume_part <- (\(triangle_length, triangle_height, prism_triangle_height, part_percent_int) ((((triangle_length * triangle_height) / 2) * prism_triangle_height) * (part_percent_int / 100)))

console_log(multiply_by_ten(add_twenty_five(17))) # read from inside to outside

17 |> add_twenty_five() |> multiply_by_ten() |> console_log() # read from left to right

console_log(17 |> add_twenty_five() |> multiply_by_ten()) # read from left to right

console_log(get_prism_triangle_volume_part(3, add(multiply(add_twenty_five(5), 10), 100), 4, 20)) # read from inside to outside

5 |> add_twenty_five() |> (\(x) (multiply(x, 10)))() |> (\(x) (add(x, 100)))() |> (\(x) (get_prism_triangle_volume_part(3, x, 4, 20)))() |> console_log() # read from left to right

console_log(5 |> add_twenty_five() |> (\(x) (multiply(x, 10)))() |> (\(x) (add(x, 100)))() |> (\(x) (get_prism_triangle_volume_part(3, x, 4, 20)))()) # read from left to right

5 |> add_twenty_five() |> curry(multiply, 10)() |> curry(add, 100)() |> (\(x) (get_prism_triangle_volume_part(3, x, 4, 20)))() |> console_log() # read from left to right

console_log(5 |> add_twenty_five() |> curry(multiply, 10)() |> curry(add, 100)() |> (\(x) (get_prism_triangle_volume_part(3, x, 4, 20)))()) # read from left to right

5 |> add_twenty_five() |> multiply(10) |> add(100) |> (\(x) (get_prism_triangle_volume_part(3, x, 4, 20)))() |> console_log() # read from left to right

console_log(5 |> add_twenty_five() |> multiply(10) |> add(100) |> (\(x) (get_prism_triangle_volume_part(3, x, 4, 20)))()) # read from left to right
