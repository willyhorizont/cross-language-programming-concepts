`%:%` <- (\(key, value) (setNames(list(value), key)))

# js_like_object <- (\(...) (Reduce(c, list(...), init = NULL)))
js_like_object <- (\(...) {
    rest_arguments <- list(...)
    result <- list()

    for (object_entry_index in seq_along(rest_arguments)) {
        any_object_entry <- rest_arguments[[object_entry_index]]
        any_object_key <- names(any_object_entry)
        result[[any_object_key]] <- any_object_entry[[1]]
    }

    return(result)
})

js_like_undefined <- tryCatch(something_undefined, error = (\(any_error) (structure(list(), class = c("js_like_undefined")))))

js_like_type = js_like_object(
    "Undefined" %:% "Undefined",
    "Null" %:% "Null",
    "Boolean" %:% "Boolean",
    "String" %:% "String",
    "Int" %:% "Int",
    "Float" %:% "Float",
    "Object" %:% "Object",
    "Array" %:% "Array",
    "Function" %:% "Function",
    "Error" %:% "Error",
    "Date" %:% "Date"
)

willy_horizont <- (\() {
    utils <- (\() {
        string_interpolate <- paste0
        curry = (\(any_function, ...) (\(current_result) (any_function(current_result, ...))))
        console_log <- (\(...) cat(paste0(..., "\n")))
        check_is_js_like_array_or_object_or_neither <- (\(anything) (if ((class(anything) != "list") && (is.list(anything) == FALSE)) ("neither") else (if (length(anything) == 0) ("js_like_array") else (if (is.null(names(anything)) == TRUE) ("js_like_array") else ("js_like_object")))))
        check_is_js_like_undefined <- (\(anything) (identical(class(anything), c("js_like_undefined"))))
        check_is_js_like_null <- (\(anything) ((class(anything) == "NULL") && (is.null(anything) == TRUE)))
        check_is_js_like_boolean <- (\(anything) ((class(anything) == "logical") && (is.logical(anything) == TRUE)))
        check_is_js_like_string <- (\(anything) ((class(anything) == "character") && (is.character(anything) == TRUE)))
        check_is_js_like_int <- (\(anything) ((class(anything) == "numeric") && (is.numeric(anything) == TRUE) && ((anything %% 1) == 0)))
        check_is_js_like_float <- (\(anything) ((class(anything) == "numeric") && (is.numeric(anything) == TRUE) && ((anything %% 1) != 0)))
        check_is_js_like_object <- (\(anything) (check_is_js_like_array_or_object_or_neither(anything) == "js_like_object"))
        check_is_js_like_array <- (\(anything) (check_is_js_like_array_or_object_or_neither(anything) == "js_like_array"))
        check_is_js_like_function <- (\(anything) (is.function(anything) == TRUE))
        check_is_js_like_error <- (\(anything) (inherits(anything, "error") == TRUE))
        check_is_js_like_date <- (\(anything) ((inherits(anything, "Date") == TRUE) || (inherits(anything, "POSIXct") == TRUE) || (inherits(anything, "POSIXlt") == TRUE)))
        get_type <- (\(anything) (if (check_is_js_like_null(anything) == TRUE) (js_like_type[["Null"]]) else (if (check_is_js_like_undefined(anything) == TRUE) (js_like_type[["Undefined"]]) else (if (check_is_js_like_boolean(anything) == TRUE) (js_like_type[["Boolean"]]) else (if (check_is_js_like_string(anything) == TRUE) (js_like_type[["String"]]) else (if (check_is_js_like_int(anything) == TRUE) (js_like_type[["Int"]]) else (if (check_is_js_like_float(anything) == TRUE) (js_like_type[["Float"]]) else (if (check_is_js_like_object(anything) == TRUE) (js_like_type[["Object"]]) else (if (check_is_js_like_array(anything) == TRUE) (js_like_type[["Array"]]) else (if (check_is_js_like_function(anything) == TRUE) (js_like_type[["Function"]]) else (if (check_is_js_like_error(anything) == TRUE) (js_like_type[["Error"]]) else (if (check_is_js_like_date(anything) == TRUE) (js_like_type[["Date"]]) else (class(anything))))))))))))))
        format_function_string <- (\(anything) {
            any_vector <- deparse(anything)
            part_one <- paste(any_vector[1:min(2, length(any_vector))], collapse = "")
            if (length(any_vector) <= 2) return(part_one)
            rest_parts <- paste(any_vector[-(1:min(2, length(any_vector)))], collapse = "\n")
            return(paste(part_one, rest_parts, sep = "\n"))
        })
        json_stringify <- (\(anything, pretty = FALSE) {
            indent = strrep(" ", 4)
            indent_level <- 0
            json_stringify_inner <- (\(anything_inner, indent_inner) {
                anything_inner_type <- get_type(anything_inner)
                if (anything_inner_type == js_like_type[["Undefined"]]) return("undefined")
                if (anything_inner_type == js_like_type[["Null"]]) return("null")
                if ((anything_inner_type == js_like_type[["Boolean"]]) && (anything_inner == TRUE)) return("True")
                if ((anything_inner_type == js_like_type[["Boolean"]]) && (anything_inner == FALSE)) return("False")
                if (anything_inner_type == js_like_type[["String"]]) return(paste0("\"", anything_inner, "\""))
                if ((anything_inner_type == js_like_type[["Int"]]) || (anything_inner_type == js_like_type[["Float"]])) return(anything_inner)
                if (anything_inner_type == js_like_type[["Function"]]) return(format_function_string(anything_inner))
                # if (anything_inner_type == js_like_type[["Function"]]) return(paste0("[object Function]"))
                # if (anything_inner_type == js_like_type[["Date"]]) return("TODO")
                # if (anything_inner_type == js_like_type[["Error"]]) return("TODO")
                if (anything_inner_type == js_like_type[["Object"]]) {
                    if (length(names(anything_inner)) == 0) return("{}")
                    indent_level <<- (indent_level + 1)
                    result <- (if (pretty == TRUE) (paste0("{\n", strrep(indent_inner, indent_level))) else ("{"))
                    for (object_entry_index in seq_along(anything_inner)) {
                        object_key <- names(anything_inner)[object_entry_index]
                        object_value <- anything_inner[[object_entry_index]]
                        result <- paste0(result, "\"", object_key, "\": ", json_stringify_inner(object_value, indent_inner))
                        if (object_entry_index != length(names(anything_inner))) result <- (if (pretty == TRUE) paste0(result, ",\n", strrep(indent_inner, indent_level)) else paste0(result, ", "))
                    }
                    indent_level <<- (indent_level - 1)
                    result <- (if (pretty == TRUE) paste0(result, "\n", strrep(indent_inner, indent_level), "}") else paste0(result, "}"))
                    return(result)
                }
                if (anything_inner_type == js_like_type[["Array"]]) {
                    if (length(anything_inner) == 0) return("[]")
                    indent_level <<- (indent_level + 1)
                    result <- (if (pretty == TRUE) paste0("[\n", strrep(indent_inner, indent_level)) else "[")
                    for (array_item_index in seq_along(anything_inner)) {
                        array_item <- anything_inner[[array_item_index]]
                        result <- paste0(result, json_stringify_inner(array_item, indent_inner))
                        if (array_item_index != length(anything_inner)) result <- (if (pretty == TRUE) paste0(result, ",\n", strrep(indent_inner, indent_level)) else paste0(result, ", "))
                    }
                    indent_level <<- (indent_level - 1)
                    result <- (if (pretty == TRUE) paste0(result, "\n", strrep(indent_inner, indent_level), "]") else paste0(result, "]"))
                    return(result)
                }
                return(toString(anything_inner))
            })
            return(json_stringify_inner(anything, indent))
        })

        return(js_like_object(
            "string_interpolate" %:% string_interpolate,
            "curry" %:% curry,
            "console_log" %:% console_log,
            "check_is_js_like_array_or_object_or_neither" %:% check_is_js_like_array_or_object_or_neither,
            "check_is_js_like_undefined" %:% check_is_js_like_undefined,
            "check_is_js_like_null" %:% check_is_js_like_null,
            "check_is_js_like_boolean" %:% check_is_js_like_boolean,
            "check_is_js_like_string" %:% check_is_js_like_string,
            "check_is_js_like_int" %:% check_is_js_like_int,
            "check_is_js_like_float" %:% check_is_js_like_float,
            "check_is_js_like_object" %:% check_is_js_like_object,
            "check_is_js_like_array" %:% check_is_js_like_array,
            "check_is_js_like_function" %:% check_is_js_like_function,
            "check_is_js_like_error" %:% check_is_js_like_error,
            "check_is_js_like_date" %:% check_is_js_like_date,
            "get_type" %:% get_type,
            "format_function_string" %:% format_function_string,
            "json_stringify" %:% json_stringify
        ))
    })()

    return(js_like_object(
        "utils" %:% utils
    ))
})()
