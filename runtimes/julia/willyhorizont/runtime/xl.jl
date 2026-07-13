module Xl
    export escape_string
    function escape_string(s)
        if s === nothing
            return ""
        end
        b = IOBuffer()
        for c in split(string(s), "")
            if c == "\\"
                write(b, "\\\\")
            elseif c == "\""
                write(b, "\\\"")
            elseif c == "\n"
                write(b, "\\n")
            elseif c == "\r"
                write(b, "\\r")
            elseif c == "\t"
                write(b, "\\t")
            else
                write(b, c)
            end
        end
        return String(take!(b))
    end
    export json_stringify
    function json_stringify(a; pretty=false)
        p = pretty
        t = " " ^ 4
        s = [Dict("t" => "v", "v" => a, "d" => 0)]
        r = ""
        while length(s) > 0
            c = pop!(s)
            if c["t"] == "r"
                r *= c["v"]
                continue
            end
            v = c["v"]
            cur_t = c["d"]
            if (v === nothing && isnothing(v)) || v === undef
                r *= "null"
                continue
            end
            if isa(v, Bool)
                r *= v ? "true" : "false"
                continue
            end
            if isa(v, AbstractString)
                r *= "\"$(escape_string(v))\""
                continue
            end
            if isa(v, Number)
                r *= string(v)
                continue
            end
            if isa(v, Function)
                r *= "\"[object Function]\""
                continue
            end
            if isa(v, AbstractVector)
                if length(v) == 0
                    r *= "[]"
                    continue
                end
                child_t = cur_t + 1
                push!(s, Dict(
                    "t" => "r",
                    "v" => p ? "\n$(t ^ cur_t)]" : "]",
                    "d" => cur_t
                ))
                for i in length(v):-1:1
                    push!(s, Dict(
                        "t" => "v",
                        "v" => v[i],
                        "d" => child_t
                    ))
                    if i > 1
                        push!(s, Dict(
                            "t" => "r",
                            "v" => p ? ",\n$(t ^ child_t)" : ",",
                            "d" => child_t
                        ))
                    end
                end
                push!(s, Dict(
                    "t" => "r",
                    "v" => p ? "[\n$(t ^ child_t)" : "[",
                    "d" => child_t
                ))
                continue
            end
            if isa(v, AbstractDict)
                de = collect(pairs(v))
                if length(de) == 0
                    r *= "{}"
                    continue
                end
                child_t = cur_t + 1
                push!(s, Dict(
                    "t" => "r",
                    "v" => p ? "\n$(t ^ cur_t)}" : "}",
                    "d" => cur_t
                ))
                for i in length(de):-1:1
                    dk, dict_value = de[i]
                    push!(s, Dict(
                        "t" => "v",
                        "v" => dict_value,
                        "d" => child_t
                    ))
                    push!(s, Dict(
                        "t" => "r",
                        "v" => p ? "\"$dk\": " : "\"$dk\":",
                        "d" => child_t
                    ))
                    if i > 1
                        push!(s, Dict(
                            "t" => "r",
                            "v" => p ? ",\n$(t ^ child_t)" : ",",
                            "d" => child_t
                        ))
                    end
                end
                push!(s, Dict(
                    "t" => "r",
                    "v" => p ? "{\n$(t ^ child_t)" : "{",
                    "d" => child_t
                ))
                continue
            end
            r *= "\"$(string(typeof(v)))\""
        end
        return r
    end
end
