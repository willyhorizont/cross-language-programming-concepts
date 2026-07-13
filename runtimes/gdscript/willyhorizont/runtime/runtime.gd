extends RefCounted

static func escape_string(s: String) -> String:
	if s.is_empty():
		return ""
	var r := s
	r = r.replace("\\", "\\\\")
	r = r.replace("\"", "\\\"")
	r = r.replace("\n", "\\n")
	r = r.replace("\r", "\\r")
	r = r.replace("\t", "\\t")
	return r

static func json_stringify(a, ao = {}):
	var o = {"pretty": false}
	o.merge(ao, true)
	var p = o["pretty"]
	var t = " ".repeat(4)
	var s = [{"t": "v", "v": a, "d": 0}]
	var r = ""
	while s.size() > 0:
		var c = s.pop_back()
		if c["t"] == "r":
			r += c["v"]
			continue
		var v = c["v"]
		var cur_d: int = c["d"]
		if typeof(v) == TYPE_NIL:
			r += "null"
			continue
		if typeof(v) == TYPE_BOOL:
			r += "true" if v else "false"
			continue
		if typeof(v) == TYPE_STRING:
			r += "\"" + escape_string(v) + "\""
			continue
		if typeof(v) == TYPE_INT or typeof(v) == TYPE_FLOAT:
			r += str(v)
			continue
		if typeof(v) == TYPE_CALLABLE:
			r += "\"[object Function]\""
			continue
		if typeof(v) == TYPE_ARRAY or (typeof(v) >= TYPE_PACKED_BYTE_ARRAY and typeof(v) <= TYPE_PACKED_COLOR_ARRAY):
			if v.size() == 0:
				r += "[]"
				continue
			var child_d: int = cur_d + 1
			s.push_back({
                "t": "r",
                "v": "\n" + t.repeat(cur_d) + "]" if p else "]",
                "d": cur_d
            })
			for i in range(v.size() - 1, -1, -1):
				s.push_back({
                    "t": "v",
                    "v": v[i],
                    "d": child_d
                })
				if i > 0:
					s.push_back({
                        "t": "r",
                        "v": ",\n" + t.repeat(child_d) if p else ",",
                        "d": child_d
                    })
			s.push_back({
                "t": "r",
                "v": "[\n" + t.repeat(child_d) if p else "[",
                "d": child_d
            })
			continue
		if typeof(v) == TYPE_DICTIONARY:
			var dkl = v.keys()
			if dkl.size() == 0:
				r += "{}"
				continue
			var child_d: int = cur_d + 1
			s.push_back({
                "t": "r",
                "v": "\n" + t.repeat(cur_d) + "}" if p else "}",
                "d": cur_d
            })
			for i in range(dkl.size() - 1, -1, -1):
				var d_k = str(dkl[i])
				var d_v = v[dkl[i]]
				s.push_back({
                    "t": "v",
                    "v": d_v,
                    "d": child_d
                })
				s.push_back({
                    "t": "r",
                    "v": "\"" + d_k + "\": " if p else "\"" + d_k + "\":",
                    "d": child_d
                })
				if i > 0:
					s.push_back({
                        "t": "r",
                        "v": ",\n" + t.repeat(child_d) if p else ",",
                        "d": child_d
                    })
			s.push_back({
                "t": "r",
                "v": "{\n" + t.repeat(child_d) if p else "{",
                "d": child_d
            })
			continue
		if typeof(v) == TYPE_OBJECT:
			r += "\"[object GDScript \\\"" + v.get_class() + "\\\"]\""
			continue
		r += "\"[object GDScript \\\"" + str(v) + "\\\"]\""
	return r
