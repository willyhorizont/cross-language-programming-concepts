package willyhorizont

import "core:fmt"
import "core:strings"

greet :: proc() {
    fmt.println("hello from package willyhorizont")
}

XlBool :: bool
XlString :: string
XlInt :: int
XlFloat :: f64
XlList :: [dynamic]CrossType
XlDict :: map[string]CrossType
XlClosure :: struct {
	state: rawptr,
	call: proc(self: ^XlClosure, varargs: ..CrossType) -> CrossType,
}

CrossType :: union {
    XlBool,
    XlString,
    XlInt,
    XlFloat,
    XlList,
    XlDict,
    XlClosure,
}

to_xl_bool :: proc(odin_value: XlBool) -> CrossType {
	return CrossType(XlBool(odin_value))
}

to_xl_string :: proc(odin_value: XlString) -> CrossType {
	return CrossType(XlString(odin_value))
}

to_xl_int :: proc(odin_value: XlInt) -> CrossType {
	return CrossType(XlInt(odin_value))
}

to_xl_float :: proc(odin_value: XlFloat) -> CrossType {
	return CrossType(XlFloat(odin_value))
}

to_xl_list :: proc(odin_value: XlList) -> CrossType {
	return CrossType(odin_value)
}

to_xl_dict :: proc(odin_value: XlDict) -> CrossType {
	return CrossType(odin_value)
}

to_xl_closure :: proc(odin_value: XlClosure) -> CrossType {
	return CrossType(odin_value)
}

to_xl_self :: proc(odin_value: CrossType) -> CrossType {
	return odin_value
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

to_odin_string :: proc(any_xl_value: CrossType) -> XlString {
	if any_xl_value == nil do return "null"
	#partial switch xl_value in any_xl_value {
	case XlBool:
		return fmt.tprintf("%t", xl_value)
	case XlString:
		return fmt.tprintf("\"%s\"", xl_value)
	case XlInt:
		return fmt.tprintf("%d", xl_value)
	case XlFloat:
		return fmt.tprintf("%f", xl_value)
	case XlClosure:
		return "\"[object Function]\""
	case XlList:
		return xl_json_stringify(xl_value)
	case XlDict:
		return xl_json_stringify(xl_value)
	}
	return ""
}

// TODO
xl_json_stringify :: proc(val: CrossType, options: struct { pretty: XlBool } = {}) -> XlString {
    pretty := options.pretty
	if val == nil do return "null"

	#partial switch self in val {
	case XlBool, XlString, XlInt, XlFloat, XlClosure:
		return to_odin_string(val)
	}

	Frame :: struct {
		val:     CrossType,
		is_dict: XlBool,
		keys:    [dynamic]XlString,
		index:   XlInt,
		total:   XlInt,
	}

	b := strings.builder_make()
	stack: [dynamic]Frame
	defer {
		for frame in stack {
			if frame.is_dict do delete(frame.keys)
		}
		delete(stack)
	}

	if list, is_list := val.(XlList); is_list {
		append(&stack, Frame{val = val, is_dict = false, index = 0, total = len(list)})
		strings.write_string(&b, "[")
		if pretty do strings.write_string(&b, "\n")
	} else if dict, is_dict := val.(XlDict); is_dict {
		dict_keys := make([dynamic]XlString, 0, len(dict))
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

		current_item: CrossType
		if frame.is_dict {
			key := frame.keys[frame.index]
			if pretty do fmt.sbprintf(&b, "\"%s\": ", key)
			else do fmt.sbprintf(&b, "\"%s\":", key)
			dict_map := frame.val.(XlDict)
			current_item = dict_map[key]
		} else {
			list_arr := frame.val.(XlList)
			current_item = list_arr[frame.index]
		}

		frame.index += 1

		if current_item == nil {
			strings.write_string(&b, "null")
		} else {
			#partial switch child in current_item {
			case XlBool, XlString, XlInt, XlFloat, XlClosure:
				strings.write_string(&b, to_odin_string(current_item))
			case XlList:
				append(&stack, Frame{val = current_item, is_dict = false, index = 0, total = len(child)})
				strings.write_string(&b, "[")
				if pretty do strings.write_string(&b, "\n")
			case XlDict:
				child_keys := make([dynamic]XlString, 0, len(child))
				for k in child do append(&child_keys, k)
				append(&stack, Frame{val = current_item, is_dict = true, keys = child_keys, index = 0, total = len(child_keys)})
				strings.write_string(&b, "{")
				if pretty do strings.write_string(&b, "\n")
			}
		}
	}
	return strings.to_string(b)
}
