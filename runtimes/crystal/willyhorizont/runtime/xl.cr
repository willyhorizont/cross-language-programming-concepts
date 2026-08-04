module Xl
    module Type
        alias Any = Nil | Bool | String | Int32 | Float64 | Array(Any) | Hash(String, Any) | Proc(Array(Any), Any)
        alias None = Nil
        alias Int = Int32
        alias Float = Float64
        alias List = Array(Any)
        alias Dict = Hash(String, Any)
        alias Lambda = Proc(Array(Any), Any)
    end
    def self.to_none(a : Type::Any) : Type::None
        if a.is_a?(Type::None)
            return nil
        else
            raise "XlRuntimeError: Expected None."
        end
    end
    def self.to_bool(a : Type::Any) : Bool
        if a.is_a?(Bool)
            return a.as(Bool)
        else
            raise "XlRuntimeError: Expected Bool."
        end
    end
    def self.to_string(a : Type::Any) : String
        if a.is_a?(String)
            return a.as(String)
        else
            raise "XlRuntimeError: Expected String."
        end
    end
    def self.to_int(a : Type::Any) : Type::Int
        if a.is_a?(Type::Int)
            return a.as(Type::Int)
        else
            raise "XlRuntimeError: Expected Int."
        end
    end
    def self.to_float(a : Type::Any) : Type::Float
        if a.is_a?(Type::Float)
            return a.as(Type::Float)
        else
            raise "XlRuntimeError: Expected Float."
        end
    end
    def self.to_list(a : Type::Any) : Type::List
        if a.is_a?(Type::List)
            return a.as(Type::List)
        else
            raise "XlRuntimeError: Expected List."
        end
    end
    def self.to_dict(a : Type::Any) : Type::Dict
        if a.is_a?(Type::Dict)
            return a.as(Type::Dict)
        else
            raise "XlRuntimeError: Expected Dict."
        end
    end
    def self.to_lambda(a : Type::Any) : Type::Lambda
        if a.is_a?(Type::Lambda)
            return a.as(Type::Lambda)
        else
            raise "XlRuntimeError: Expected Lambda."
        end
    end
    def self.init(a : Type::Any) : Type::Any
        return a.as(Type::Any)
    end
    def self.init_list(*el) : Type::Any
        l = [] of Type::Any
        el.each do |el|
            l << el.as(Type::Any)
        end
        return l.as(Type::Any)
    end
    def self.init_dict(a : Hash) : Type::Any
        d = {} of String => Type::Any
        a.each do |pk, pv|
            d[pk.to_s] = pv.as(Type::Any)
        end
        return d.as(Type::Any)
    end
    def self.init_lambda(c : T) : Type::Any forall T
        if c.nil?
            return nil.as(Type::Any)
        end
        return ->(va : Type::List) : Type::Any {
            return init(c.call(va))
        }.as(Type::Any)
    end
    def self.init_lambda(a : Type::None) : Type::Any
        return nil.as(Type::Any)
    end
    def self.call(a : Type::Any, *args) : Type::Any
        return to_lambda(a).call(to_list(init_list(*args)))
    end
    def self.iter(a : Type::Any)
        return to_list(a).each
    end
    def self.next(itr) : Type::Any
        v = itr.next
        if v.is_a?(Type::Any)
            return v.as(Type::Any)
        end
        raise "XlRuntimeError: Iterator is empty or out of bounds."
    end
    def self.escape_string(a : Type::Any) : String
        return "" if a.is_a?(Type::None)
        s = to_string(a)
        r = s.gsub("\\", "\\\\")
        r = r.gsub("\"", "\\\"")
        r = r.gsub("\n", "\\n")
        r = r.gsub("\r", "\\r")
        r = r.gsub("\t", "\\t")
        return r
    end
    def self.json_stringify(a, pretty = false)
        p = pretty
        t = " " * 4
        s = to_list(init_list(init_dict({ "t" => "v", "v" => a, "d" => 0 })))
        r = ""
        while s.size > 0
            c = to_dict(s.pop)
            if to_string(c["t"]) == "r"
                r += to_string(c["v"])
                next
            end
            v = c["v"]
            cur_d = to_int(c["d"])
            if v.is_a?(Type::None)
                r += "null"
                next
            end
            if v.is_a?(Bool)
                r += to_bool(v) ? "true" : "false"
                next
            end
            if v.is_a?(String)
                r += "\"" + escape_string(v) + "\""
                next
            end
            if v.is_a?(Type::Int)
                r += to_int(v).to_s
                next
            end
            if v.is_a?(Type::Float)
                r += to_float(v).to_s
                next
            end
            if v.is_a?(Proc)
                r += "\"[object Function]\""
                next
            end
            if v.is_a?(Array)
                l = to_list(v)
                if l.size == 0
                    r += "[]"
                    next
                end
                child_d = cur_d + 1
                s.push(init_dict({
                    "t" => "r",
                    "v" => p ? "\n" + (t * cur_d) + "]" : "]",
                    "d" => cur_d
                }))
                (l.size - 1).downto(0) do |i|
                    s.push(init_dict({
                        "t" => "v",
                        "v" => l[i],
                        "d" => child_d
                    }))
                    if i > 0
                        s.push(init_dict({
                            "t" => "r",
                            "v" => p ? ",\n" + (t * child_d) : ",",
                            "d" => child_d
                        }))
                    end
                end
                s.push(init_dict({
                    "t" => "r",
                    "v" => p ? "[\n" + (t * child_d) : "[",
                    "d" => child_d
                }))
                next
            end
            if v.is_a?(Hash)
                d = to_dict(v)
                dpl = d.to_a
                if dpl.size == 0
                    r += "{}"
                    next
                end
                child_d = cur_d + 1
                s.push(init_dict({
                    "t" => "r",
                    "v" => p ? "\n" + (t * cur_d) + "}" : "}",
                    "d" => cur_d
                }))
                (dpl.size - 1).downto(0) do |i|
                    pk, pv = dpl[i]
                    s.push(init_dict({
                        "t" => "v",
                        "v" => pv,
                        "d" => child_d
                    }))
                    s.push(init_dict({
                        "t" => "r",
                        "v" => p ? "\"" + pk.to_s + "\": " : "\"" + pk.to_s + "\":",
                        "d" => child_d
                    }))
                    if i > 0
                        s.push(init_dict({
                            "t" => "r",
                            "v" => p ? ",\n" + (t * child_d) : ",",
                            "d" => child_d
                        }))
                    end
                end
                s.push(init_dict({
                    "t" => "r",
                    "v" => p ? "{\n" + (t * child_d) : "{",
                    "d" => child_d
                }))
                next
            end
            r += "\"" + v.class.name + "\""
        end
        return r
    end
end
