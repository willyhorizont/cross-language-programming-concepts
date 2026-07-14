xl <- list(
    NONE = "null",
    curry = \(f, ...) \(r) f(r, ...),
    catln = \(...) cat(paste0(..., "\n")),
    escape_string = \(s) {
        if (is.null(s) || identical(s, xl$NONE)) return("")
        r <- as.character(s)
        r <- gsub("\\\\", "\\\\\\\\", r)
        r <- gsub("\"", "\\\\\"", r)
        r <- gsub("\n", "\\\\n", r)
        r <- gsub("\r", "\\\\r", r)
        r <- gsub("\t", "\\\\t", r)
        return(r)
    },
    dict = \(...) {
        va <- list(...)
        d <- new.env(parent = emptyenv())
        dpl <- names(va)
        if (is.null(dpl)) {
            if (length(va) > 0) stop("XlRuntimeError: Invalid dict.")
            return(d)
        }
        for (k in dpl) {
            if (k == "") stop("XlRuntimeError: Invalid dict.")
            d[[k]] <- va[[k]]
        }
        return(d)
    },
    get = \(d, k) {
        if (!is.environment(d)) stop("XlRuntimeError: Expected dict.")
        if (!exists(k, envir = d, inherits = FALSE)) stop(paste0("XlRuntimeError: Key \"", k, "\" not found in dict."))
        return(d[[k]])
    },
    json_stringify = \(a, pretty = FALSE) {
        p <- isTRUE(pretty)
        t <- strrep(" ", 4)
        s <- list(list("t" = "v", "v" = a, "d" = 0))
        r <- ""
        while (length(s) > 0) {
            c <- s[[length(s)]]
            s[[length(s)]] <- NULL
            if (c$"t" == "r") {
                r <- paste0(r, as.character(c$"v"))
                next
            }
            v <- c$"v"
            cur_d <- c$"d"
            if (is.null(v) || identical(v, xl$NONE)) {
                r <- paste0(r, "null")
                next
            }
            if (is.logical(v) && length(v) == 1) {
                r <- paste0(r, if (v) "true" else "false")
                next
            }
            if (is.character(v) && length(v) == 1 && !identical(v, xl$NONE)) {
                r <- paste0(r, "\"", xl$escape_string(v), "\"")
                next
            }
            if (is.numeric(v) && length(v) == 1) {
                r <- paste0(r, as.character(v))
                next
            }
            if (is.function(v)) {
                r <- paste0(r, "\"[object Function]\"")
                next
            }
            if (is.list(v) && (is.null(names(v)) || all(names(v) == ""))) {
                if (length(v) == 0) {
                    r <- paste0(r, "[]")
                    next
                }
                child_d <- cur_d + 1
                s[[length(s) + 1]] <- list(
                    "t" = "r",
                    "v" = if (p) paste0("\n", strrep(t, cur_d), "]") else "]",
                    "d" = cur_d
                )
                for (i in rev(seq_along(v))) {
                    s[[length(s) + 1]] <- list(
                        "t" = "v",
                        "v" = v[[i]],
                        "d" = child_d
                    )
                    if (i > 1) {
                        s[[length(s) + 1]] <- list(
                            "t" = "r",
                            "v" = if (p) paste0(",\n", strrep(t, child_d)) else ",",
                            "d" = child_d
                        )
                    }
                }
                s[[length(s) + 1]] <- list(
                    "t" = "r",
                    "v" = if (p) paste0("[\n", strrep(t, child_d)) else "[",
                    "d" = child_d
                )
                next
            }
            if (is.environment(v)) {
                dp_l <- ls(envir = v, all.names = TRUE)
                if (length(dp_l) == 0) {
                    r <- paste0(r, "{}")
                    next
                }
                child_d <- cur_d + 1
                s[[length(s) + 1]] <- list(
                    "t" = "r",
                    "v" = if (p) paste0("\n", strrep(t, cur_d), "}") else "}",
                    "d" = cur_d
                )
                for (i in rev(seq_along(dp_l))) {
                    d_k <- dp_l[i]
                    d_v <- v[[d_k]]
                    s[[length(s) + 1]] <- list(
                        "t" = "v",
                        "v" = d_v,
                        "d" = child_d
                    )
                    s[[length(s) + 1]] <- list(
                        "t" = "r",
                        "v" = if (p) paste0("\"", d_k, "\": ") else paste0("\"", d_k, "\":"),
                        "d" = child_d
                    )
                    if (i > 1) {
                        s[[length(s) + 1]] <- list(
                            "t" = "r",
                            "v" = if (p) paste0(",\n", strrep(t, child_d)) else ",",
                            "d" = child_d
                        )
                    }
                }
                s[[length(s) + 1]] <- list(
                    "t" = "r",
                    "v" = if (p) paste0("{\n", strrep(t, child_d)) else "{",
                    "d" = child_d
                )
                next
            }
            r <- paste0(r, "\"", class(v), "\"")
        }
        return(r)
    }
)
