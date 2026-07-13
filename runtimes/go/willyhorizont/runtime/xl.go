package xl

import (
	"fmt"
	rt "reflect"
	str "strings"
)

func escapeString(s string) string {
	return str.NewReplacer(
		"\\", "\\\\",
		"\"", "\\\"",
		"\n", "\\n",
		"\r", "\\r",
		"\t", "\\t",
	).Replace(fmt.Sprintf("%v", s))
}

type List []interface{}

type Dict map[string]interface{}

type Closure func(va ...interface{}) interface{}

func (c Closure) Call(va ...interface{}) interface{} {
	return c(va...)
}

type Callable struct {
	Underlying Closure
}

func (c Callable) Call(va ...interface{}) interface{} {
	if c.Underlying == nil {
		panic("XlRuntimeError: Can't do Call.")
	}
	return c.Underlying(va...)
}

type Iterator struct {
	Iterable []interface{}
	Index int
}

func Iter(iterable []interface{}) *Iterator {
	return &Iterator{
		Iterable: iterable,
		Index:    0,
	}
}

func (itr *Iterator) Next() interface{} {
	if itr.Index < len(itr.Iterable) {
		v := itr.Iterable[itr.Index]
		itr.Index += 1
		return v
	}
	return nil
}

func Println(va ...interface{}) {
	for _, el := range va {
		fmt.Print(el)
	}
	fmt.Print("\n")
}

func ToInt(a interface{}) int64 {
	if a == nil {
		panic("XlRuntimeError: Can't do ToInt.")
	}
	rv := rt.ValueOf(a)
	if rv.Kind() == rt.Ptr {
		if rv.IsNil() {
			panic("XlRuntimeError: Can't do ToInt.")
		}
		rv = rv.Elem()
	}
	switch rv.Kind() {
	case rt.Int, rt.Int8, rt.Int16, rt.Int32, rt.Int64:
		return rv.Int()
	case rt.Uint, rt.Uint8, rt.Uint16, rt.Uint32, rt.Uint64:
		return int64(rv.Uint())
	case rt.Float32, rt.Float64:
		return int64(rv.Float())
	default:
		panic("XlRuntimeError: Can't do ToInt.")
	}
}

func ToFloat(a interface{}) float64 {
	if a == nil {
		panic("XlRuntimeError: Can't do ToFloat.")
	}
	rv := rt.ValueOf(a)
	if rv.Kind() == rt.Ptr {
		if rv.IsNil() {
			panic("XlRuntimeError: Can't do ToFloat.")
		}
		rv = rv.Elem()
	}
	switch rv.Kind() {
	case rt.Int, rt.Int8, rt.Int16, rt.Int32, rt.Int64:
		return float64(rv.Int())
	case rt.Uint, rt.Uint8, rt.Uint16, rt.Uint32, rt.Uint64:
		return float64(rv.Uint())
	case rt.Float32, rt.Float64:
		return rv.Float()
	default:
		panic("XlRuntimeError: Can't do ToFloat.")
	}
}

func ToBool(a interface{}) bool {
	if a == nil {
		panic("XlRuntimeError: Can't do ToBool.")
	}
	rv := rt.ValueOf(a)
	if rv.Kind() == rt.Ptr {
		if rv.IsNil() {
			panic("XlRuntimeError: Can't do ToBool.")
		}
		rv = rv.Elem()
	}
	switch rv.Kind() {
	case rt.Bool:
		return rv.Bool()
	default:
		panic("XlRuntimeError: Can't do ToBool.")
	}
}

func ToClosure(a interface{}) Callable {
	if a == nil {
		panic("XlRuntimeError: Can't do ToClosure.")
	}
	if exst, ok := a.(Callable); ok {
		return exst
	}
	if c, ok := a.(Closure); ok {
		return Callable{Underlying: c}
	}
	if rC, ok := a.(func(...interface{}) interface{}); ok {
		return Callable{Underlying: Closure(rC)}
	}
	rv := rt.ValueOf(a)
	if rv.Kind() != rt.Func {
		panic("XlRuntimeError: Can't do ToClosure")
	}
	cls := func(va ...interface{}) interface{} {
		a := make([]rt.Value, len(va))
		for i, arg := range va {
			a[i] = rt.ValueOf(arg)
		}
		nC := rv.Call(a)
		if len(nC) == 0 {
			return nil
		}
		return nC[0].Interface()
	}
	return Callable{Underlying: cls}
}

func JsonStringify(va ...interface{}) string {
	itr := Iter(va)
	a := itr.Next()
	if a == nil {
		return "null"
	}
	oC := itr.Next()
	p := false
	if oC != nil {
		oD := rt.ValueOf(oC)
		if oD.Kind() == rt.Map {
			for _, dK := range oD.MapKeys() {
				if dK.Kind() == rt.String && dK.String() == "pretty" {
					p = ToBool(oD.MapIndex(dK).Interface())
				}
			}
		}
	}
	t := "    "
	s := List{Dict{ "t": "v", "v": a, "d": 0 }}
	var r str.Builder
	for len(s) > 0 {
		n := len(s) - 1
		c := s[n].(Dict)
		s = s[:n]
		if c["t"].(string) == "r" {
			r.WriteString(c["v"].(string))
			continue
		}
		v := c["v"]
		curD := c["d"].(int)
		if v == nil {
			r.WriteString("null")
			continue
		}
		rv := rt.ValueOf(v)
		switch rv.Kind() {
		case rt.Bool:
			if rv.Bool() {
				r.WriteString("true")
			} else {
				r.WriteString("false")
			}
		case rt.String:
			r.WriteString("\"" + escapeString(rv.String()) + "\"")
		case rt.Int, rt.Int8, rt.Int16, rt.Int32, rt.Int64:
			r.WriteString(fmt.Sprintf("%d", rv.Int()))
		case rt.Float32, rt.Float64:
			r.WriteString(fmt.Sprintf("%g", rv.Float()))
		case rt.Func:
			r.WriteString("\"[object Function]\"")
		case rt.Slice:
			lD := rv.Len()
			if lD == 0 {
				r.WriteString("[]")
				continue
			}
			chldD := curD + 1
			vBc := "]"
			if p {
				vBc = "\n" + str.Repeat(t, curD) + "]"
			}
			s = append(s, Dict{
				"t": "r",
				"v": vBc,
				"d": curD,
			})
			for i := lD - 1; i >= 0; i -= 1 {
				s = append(s, Dict{
					"t": "v",
					"v": rv.Index(i).Interface(),
					"d": chldD,
				})
				if i > 0 {
					vSep := ","
					if p {
						vSep = ",\n" + str.Repeat(t, chldD)
					}
					s = append(s, Dict{
						"t": "r",
						"v": vSep,
						"d": chldD,
					})
				}
			}
			vBo := "["
			if p {
				vBo = "[\n" + str.Repeat(t, chldD)
			}
			s = append(s, Dict{
				"t": "r",
				"v": vBo,
				"d": chldD,
			})
		case rt.Map:
			dKl := rv.MapKeys()
			if len(dKl) == 0 {
				r.WriteString("{}")
				continue
			}
			chldD := curD + 1
			vBc := "}"
			if p {
				vBc = "\n" + str.Repeat(t, curD) + "}"
			}
			s = append(s, Dict{
				"t": "r",
				"v": vBc,
				"d": curD,
			})
			for i := len(dKl) - 1; i >= 0; i -= 1 {
				dK := dKl[i]
				dV := rv.MapIndex(dK).Interface()
				s = append(s, Dict{
					"t": "v",
					"v": dV,
					"d": chldD,
				})
				vSep := ":"
				if p {
					vSep = ": "
				}
				s = append(s, Dict{
					"t": "r",
					"v": "\"" + dK.String() + "\"" + vSep,
					"d": chldD,
				})
				if i > 0 {
					vSep := ","
					if p {
						vSep = ",\n" + str.Repeat(t, chldD)
					}
					s = append(s, Dict{
						"t": "r",
						"v": vSep,
						"d": chldD,
					})
				}
			}
			vBo := "{"
			if p {
				vBo = "{\n" + str.Repeat(t, chldD)
			}
			s = append(s, Dict{
				"t": "r",
				"v": vBo,
				"d": chldD,
			})
		default:
			r.WriteString("\"" + rt.TypeOf(v).String() + "\"")
		}
	}
	return r.String()
}
