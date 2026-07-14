module Xl
    def self.escape_string(s)
        return "" if s.nil?
        r = s.to_s
        r = r.gsub("\\", "\\\\")
        r = r.gsub("\"", "\\\"")
        r = r.gsub("\n", "\\n")
        r = r.gsub("\r", "\\r")
        r = r.gsub("\t", "\\t")
        return r
    end
    def self.json_stringify(a, pretty: false)
        p = pretty
        t = " " * 4
        s = [{ "t" => "v", "v" => a, "d" => 0 }]
        r = ""
        while s.length > 0
            c = s.pop
            if c["t"] == "r"
                r += c["v"].to_s
                next
            end
            v = c["v"]
            cur_d = c["d"]
            if v.nil?
                r += "null"
                next
            end
            if v.is_a?(TrueClass) || v.is_a?(FalseClass)
                r += v ? "true" : "false"
                next
            end
            if v.is_a?(String)
                r += "\"" + escape_string(v) + "\""
                next
            end
            if v.is_a?(Numeric)
                r += v.to_s
                next
            end
            if v.is_a?(Proc) || v.is_a?(Method)
                r += "\"[object Function]\""
                next
            end
            if v.is_a?(Array)
                if v.length == 0
                    r += "[]"
                    next
                end
                child_d = cur_d + 1
                s.push({
                    "t" => "r",
                    "v" => p ? "\n" + t * cur_d + "]" : "]",
                    "d" => cur_d
                })
                (v.length - 1).downto(0) do |i|
                    s.push({
                        "t" => "v",
                        "v" => v[i],
                        "d" => child_d
                    })
                    if i > 0
                        s.push({
                            "t" => "r",
                            "v" => p ? ",\n" + t * child_d : ",",
                            "d" => child_d
                        })
                    end
                end
                s.push({
                    "t" => "r",
                    "v" => p ? "[\n" + t * child_d : "[",
                    "d" => child_d
                })
                next
            end
            if v.is_a?(Hash)
                dp_l = v.to_a
                if dp_l.length == 0
                    r += "{}"
                    next
                end
                child_d = cur_d + 1
                s.push({
                    "t" => "r",
                    "v" => p ? "\n" + t * cur_d + "}" : "}",
                    "d" => cur_d
                })
                (dp_l.length - 1).downto(0) do |i|
                    d_k, d_v = dp_l[i]
                    s.push({
                        "t" => "v",
                        "v" => d_v,
                        "d" => child_d
                    })
                    s.push({
                        "t" => "r",
                        "v" => p ? "\"" + d_k.to_s + "\": " : "\"" + d_k.to_s + "\":",
                        "d" => child_d
                    })
                    if i > 0
                        s.push({
                            "t" => "r",
                            "v" => p ? ",\n" + t * child_d : ",",
                            "d" => child_d
                        })
                    end
                end
                s.push({
                    "t" => "r",
                    "v" => p ? "{\n" + t * child_d : "{",
                    "d" => child_d
                })
                next
            end
            r += "\"" + v.class.name + "\""
        end
        return r
    end
end
