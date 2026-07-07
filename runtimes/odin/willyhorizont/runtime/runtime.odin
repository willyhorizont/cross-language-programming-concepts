package xl

import "core:fmt"
import "core:strings"

Bool :: bool
String :: string
Int :: int
Float :: f64
List :: [dynamic]Type
Dict :: map[String]Type
Closure :: struct {
	state: rawptr,
	call: proc(self: ^Closure, varargs: ..Type) -> Type,
}

Type :: union {
    Bool,
    String,
    Int,
    Float,
    List,
    Dict,
    Closure,
}

to_xl_bool :: proc(v: Bool) -> Type {
	return Type(Bool(v))
}

to_xl_string :: proc(v: String) -> Type {
	return Type(String(v))
}

to_xl_int :: proc(v: Int) -> Type {
	return Type(Int(v))
}

to_xl_float :: proc(v: Float) -> Type {
	return Type(Float(v))
}

to_xl_list :: proc(v: List) -> Type {
	return Type(v)
}

to_xl_dict :: proc(v: Dict) -> Type {
	return Type(v)
}

to_xl_closure :: proc(v: Closure) -> Type {
	return Type(v)
}

to_xl_self :: proc(v: Type) -> Type {
	return v
}

to_xl :: proc{
	to_xl_bool,
	to_xl_string,
	to_xl_int,
	to_xl_float,
	to_xl_list,
	to_xl_dict,
	to_xl_closure,
	to_xl_self,
}

to_odin_string :: proc(any_xl_value: Type) -> String {
	if any_xl_value == nil do return "null"
	#partial switch xl_value in any_xl_value {
	case Bool:
		return fmt.tprintf("%t", xl_value)
	case String:
		return fmt.tprintf("\"%s\"", xl_value)
	case Int:
		return fmt.tprintf("%d", xl_value)
	case Float:
		return fmt.tprintf("%f", xl_value)
	case Closure:
		return "\"[object Function]\""
	case List:
		return xl_json_stringify(xl_value)
	case Dict:
		return xl_json_stringify(xl_value)
	}
	return ""
}

// TODO
xl_json_stringify :: proc(val: Type, options: struct { pretty: Bool } = {}) -> String {
    pretty := options.pretty
	if val == nil do return "null"

	#partial switch self in val {
	case Bool, String, Int, Float, Closure:
		return to_odin_string(val)
	}

	Frame :: struct {
		val:     Type,
		is_dict: Bool,
		keys:    [dynamic]String,
		index:   Int,
		total:   Int,
	}

	b := strings.builder_make()
	stack: [dynamic]Frame
	defer {
		for frame in stack {
			if frame.is_dict do delete(frame.keys)
		}
		delete(stack)
	}

	if list, is_list := val.(List); is_list {
		append(&stack, Frame{val = val, is_dict = false, index = 0, total = len(list)})
		strings.write_string(&b, "[")
		if pretty do strings.write_string(&b, "\n")
	} else if dict, is_dict := val.(Dict); is_dict {
		dict_keys := make([dynamic]String, 0, len(dict))
		for k in dict do append(&dict_keys, k)
		append(&stack, Frame{val = val, is_dict = true, keys = dict_keys, index = 0, total = len(dict_keys)})
		strings.write_string(&b, "{")
		if pretty do strings.write_string(&b, "\n")
	}

	for len(stack) > 0 {
		top_idx := len(stack) - 1
		frame := &stack[top_idx]
		current_depth := len(stack)

		if frame.index >= frame.total {
			if pretty do strings.write_string(&b, "\n")
            if pretty {
                for _ in 0..<(current_depth - 1) do strings.write_string(&b, "    ")
            }
			if frame.is_dict {
				strings.write_string(&b, "}")
				delete(frame.keys)
			} else {
				strings.write_string(&b, "]")
			}
			pop(&stack)
			continue
		}

		if frame.index > 0 {
			if pretty do strings.write_string(&b, ",\n")
			else do strings.write_string(&b, ",")
		}
        if pretty {
            for _ in 0..<current_depth do strings.write_string(&b, "    ")
        }

		current_item: Type
		if frame.is_dict {
			key := frame.keys[frame.index]
			if pretty do fmt.sbprintf(&b, "\"%s\": ", key)
			else do fmt.sbprintf(&b, "\"%s\":", key)
			dict_map := frame.val.(Dict)
			current_item = dict_map[key]
		} else {
			list_arr := frame.val.(List)
			current_item = list_arr[frame.index]
		}

		frame.index += 1

		if current_item == nil {
			strings.write_string(&b, "null")
		} else {
			#partial switch child in current_item {
			case Bool, String, Int, Float, Closure:
				strings.write_string(&b, to_odin_string(current_item))
			case List:
				append(&stack, Frame{val = current_item, is_dict = false, index = 0, total = len(child)})
				strings.write_string(&b, "[")
				if pretty do strings.write_string(&b, "\n")
			case Dict:
				child_keys := make([dynamic]String, 0, len(child))
				for k in child do append(&child_keys, k)
				append(&stack, Frame{val = current_item, is_dict = true, keys = child_keys, index = 0, total = len(child_keys)})
				strings.write_string(&b, "{")
				if pretty do strings.write_string(&b, "\n")
			}
		}
	}
	return strings.to_string(b)
}
