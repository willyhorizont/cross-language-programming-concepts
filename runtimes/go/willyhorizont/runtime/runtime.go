package runtime

import (
	"fmt"
	rt "reflect"
	"strings"
)

type XlList []interface{}
type XlDict map[string]interface{}
type XlClosure func(va ...interface{}) interface{}
type XlCallable struct {
	Underlying XlClosure
}

type XlIterator struct {
	Iterable []interface{}
	Index int
}

func Iter(iterable []interface{}) *XlIterator {
	return &XlIterator{
		Iterable: iterable,
		Index:    0,
	}
}

func (itr *XlIterator) Next() interface{} {
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
		panic("Runtime Error: Can't do ToInt.")
	}
	rv := rt.ValueOf(a)
	if rv.Kind() == rt.Ptr {
		if rv.IsNil() {
			panic("Runtime Error: Can't do ToInt.")
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
		panic("Runtime Error: Can't do ToInt.")
	}
}

func ToFloat(a interface{}) float64 {
	if a == nil {
		panic("Runtime Error: Can't do ToFloat.")
	}
	rv := rt.ValueOf(a)
	if rv.Kind() == rt.Ptr {
		if rv.IsNil() {
			panic("Runtime Error: Can't do ToFloat.")
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
		panic("Runtime Error: Can't do ToFloat.")
	}
}

func ToBool(a interface{}) bool {
	if a == nil {
		panic("Runtime Error: Can't do ToBool.")
	}
	rv := rt.ValueOf(a)
	if rv.Kind() == rt.Ptr {
		if rv.IsNil() {
			panic("Runtime Error: Can't do ToBool.")
		}
		rv = rv.Elem()
	}
	switch rv.Kind() {
	case rt.Bool:
		return rv.Bool()
	default:
		panic("Runtime Error: Can't do ToBool.")
	}
}

func (c XlCallable) Call(va ...interface{}) interface{} {
	if c.Underlying == nil {
		panic("Runtime Error: Can't do Call.")
	}
	return c.Underlying(va...)
}

func ToClosure(a interface{}) XlCallable {
	if a == nil {
		panic("Runtime Error: Can't do ToClosure.")
	}
	if exst, ok := a.(XlCallable); ok {
		return exst
	}
	if c, ok := a.(XlClosure); ok {
		return XlCallable{Underlying: c}
	}
	if rC, ok := a.(func(...interface{}) interface{}); ok {
		return XlCallable{Underlying: XlClosure(rC)}
	}
	rv := rt.ValueOf(a)
	if rv.Kind() != rt.Func {
		panic("Runtime Error: Can't do ToClosure")
	}
	cls := func(va ...interface{}) interface{} {
		args := make([]rt.Value, len(va))
		for i, arg := range va {
			args[i] = rt.ValueOf(arg)
		}
		nC := rv.Call(args)
		if len(nC) == 0 {
			return nil
		}
		return nC[0].Interface()
	}
	return XlCallable{Underlying: cls}
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
			for _, k := range oD.MapKeys() {
				if k.Kind() == rt.String && k.String() == "pretty" {
					p = ToBool(oD.MapIndex(k).Interface())
				}
			}
		}
	}
	t := "    "
	type sDi struct {
		T string
		Rv interface{}
		Pv string
		D int
	}
	s := []sDi{{T: "v", Rv: a, D: 0}}
	var r strings.Builder
	for len(s) > 0 {
		n := len(s) - 1
		c := s[n]
		s = s[:n]
		if c.T == "r" {
			r.WriteString(c.Pv)
			continue
		}
		v := c.Rv
		curD := c.D
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
			r.WriteString("\"" + rv.String() + "\"")
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
			chiD := curD + 1
			clsVal := "]"
			if p {
				clsVal = "\n" + strings.Repeat(t, curD) + "]"
			}
			s = append(s, sDi{T: "r", Pv: clsVal})
			for i := lD - 1; i >= 0; i-- {
				s = append(s, sDi{T: "v", Rv: rv.Index(i).Interface(), D: chiD})
				if i > 0 {
					sepVal := ","
					if p {
						sepVal = ",\n" + strings.Repeat(t, chiD)
					}
					s = append(s, sDi{T: "r", Pv: sepVal})
				}
			}
			opVal := "["
			if p {
				opVal = "[\n" + strings.Repeat(t, chiD)
			}
			s = append(s, sDi{T: "r", Pv: opVal})
		case rt.Map:
			keys := rv.MapKeys()
			if len(keys) == 0 {
				r.WriteString("{}")
				continue
			}
			chiD := curD + 1
			clsVal := "}"
			if p {
				clsVal = "\n" + strings.Repeat(t, curD) + "}"
			}
			s = append(s, sDi{T: "r", Pv: clsVal})
			for i := len(keys) - 1; i >= 0; i-- {
				k := keys[i]
				dVal := rv.MapIndex(k).Interface()
				s = append(s, sDi{T: "v", Rv: dVal, D: chiD})
				kvSep := ":"
				if p {
					kvSep = ": "
				}
				s = append(s, sDi{T: "r", Pv: "\"" + k.String() + "\"" + kvSep})
				if i > 0 {
					sepVal := ","
					if p {
						sepVal = ",\n" + strings.Repeat(t, chiD)
					}
					s = append(s, sDi{T: "r", Pv: sepVal})
				}
			}
			opVal := "{"
			if p {
				opVal = "{\n" + strings.Repeat(t, chiD)
			}
			s = append(s, sDi{T: "r", Pv: opVal})
		default:
			r.WriteString("\"" + rt.TypeOf(v).Name() + "\"")
		}
	}
	return r.String()
}
