package xl

import (
    "fmt"
    "reflect"
    "strings"
)

type Kind int

const (
    XlNone Kind = iota
    XlBool
    XlString
    XlInt
    XlFloat
    XlList
    XlDict
    XlLambda
    XlIterator
)

type Type struct {
    kind  Kind
    value interface{}
}

type List []Type
type Dict map[string]Type
type Lambda func(va Type) Type

type Pair struct {
    kind   string
    value Type
}

type Iterator struct {
    value List
    index    int
}

var NONE  = Type{kind: XlNone, value: nil}
var TRUE  = Type{kind: XlBool, value: true}
var FALSE = Type{kind: XlBool, value: false}

func InitString(v string) Type {
    return Type{kind: XlString, value: v}
}

func InitInt(v int64) Type {
    return Type{kind: XlInt, value: v}
}

func InitFloat(v float64) Type {
    return Type{kind: XlFloat, value: v}
}

func InitList(va ...Type) Type {
    l := make(List, len(va))
    copy(l, va)
    return Type{kind: XlList, value: l}
}

func InitPair(k string, v Type) Pair {
    return Pair{kind: k, value: v}
}

func InitDict(dpl ...Pair) Type {
    d := make(Dict)
    for _, p := range dpl {
        d[p.kind] = p.value
    }
    return Type{kind: XlDict, value: d}
}

func InitLambda(fn Lambda) Type {
    return Type{kind: XlLambda, value: fn}
}

func (x Type) Get(kind string) Type {
    if x.kind != XlDict {
        panic("XlRuntimeError: Expected Dict.")
    }
    d := x.value.(Dict)
    if v, ok := d[kind]; ok {
        return v
    }
    return NONE
}

func (x Type) Call(va ...Type) Type {
    if x.kind != XlLambda {
        panic("XlRuntimeError: Expected Lambda.")
    }
    return x.value.(Lambda)(InitList(va...))
}

func (x Type) Iter() *Iterator {
    if x.kind != XlList {
        panic("XlRuntimeError: Expected List.")
    }
    return &Iterator{
        value: x.value.(List),
        index:    0,
    }
}

func (itr *Iterator) Next() Type {
    if itr.index < len(itr.value) {
        v := itr.value[itr.index]
        itr.index += 1
        return v
    }
    return NONE
}

func Println(va ...interface{}) {
    for _, el := range va {
        if a, ok := el.(Type); ok {
            switch a.kind {
            case XlNone: fmt.Print("null")
            case XlBool: fmt.Print(a.value.(bool))
            case XlString: fmt.Print(a.value.(string))
            case XlInt: fmt.Print(a.value.(int64))
            case XlFloat: fmt.Print(a.value.(float64))
            default: fmt.Print("[object Object]")
            }
        } else {
            fmt.Print(el)
        }
    }
    fmt.Print("\n")
}

func (x Type) ToInt() int64 {
    switch x.kind {
    case XlInt:
        return x.value.(int64)
    case XlFloat:
        return int64(x.value.(float64))
    default:
        panic("XlRuntimeError: Expected Int.")
    }
}

func (x Type) ToFloat() float64 {
    switch x.kind {
    case XlInt:
        return float64(x.value.(int64))
    case XlFloat:
        return x.value.(float64)
    default:
        panic("XlRuntimeError: Expected Float.")
    }
}

func (x Type) ToBool() bool {
    if x.kind != XlBool {
        panic("XlRuntimeError: Expected Bool.")
    }
    return x.value.(bool)
}

func (x Type) ToString() string {
    if x.kind != XlString {
        panic("XlRuntimeError: Expected String.")
    }
    return x.value.(string)
}

func escapeString(s string) string {
    return strings.NewReplacer(
        "\\", "\\\\",
        "\"", "\\\"",
        "\n", "\\n",
        "\r", "\\r",
        "\t", "\\t",
    ).Replace(s)
}

func JsonStringify(va ...interface{}) string {
    if len(va) == 0 || va[0] == nil {
        return "null"
    }
    var a Type
    if aX, ok := va[0].(Type); ok {
        a = aX
    } else {
        return "null"
    }
    p := false
    if len(va) > 1 && va[1] != nil {
        if o, ok := va[1].(Type); ok && o.kind == XlDict {
            oD := o.value.(Dict)
            if odP, exists := oD["pretty"]; exists && odP.kind == XlBool {
                p = odP.value.(bool)
            }
        }
    }
    t := strings.Repeat(" ", 4)
    s := []map[string]interface{}{{"t": "v", "v": a, "d": 0}}
    var r strings.Builder
    for len(s) > 0 {
        n := len(s) - 1
        c := s[n]
        s = s[:n]
        if c["t"].(string) == "r" {
            r.WriteString(c["v"].(string))
            continue
        }
        v := c["v"].(Type)
        curD := c["d"].(int)
        switch v.kind {
        case XlNone:
            r.WriteString("null")
        case XlBool:
            if v.value.(bool) {
                r.WriteString("true")
            } else {
                r.WriteString("false")
            }
        case XlString:
            r.WriteString("\"" + escapeString(v.value.(string)) + "\"")
        case XlInt:
            r.WriteString(fmt.Sprintf("%d", v.value.(int64)))
        case XlFloat:
            r.WriteString(fmt.Sprintf("%g", v.value.(float64)))
        case XlLambda:
            r.WriteString("\"[object Function]\"")
        case XlList:
            lV := v.value.(List)
            lLen := len(lV)
            if lLen == 0 {
                r.WriteString("[]")
                continue
            }
            chldD := curD + 1
            slcb := "]"
            if p {
                slcb = "\n" + strings.Repeat(t, curD) + "]"
            }
            s = append(s, map[string]interface{}{
                "t": "r",
                "v": slcb,
                "d": curD,
            })
            for i := lLen - 1; i >= 0; i -= 1 {
                s = append(s, map[string]interface{}{
                    "t": "v",
                    "v": lV[i],
                    "d": chldD,
                })
                if i > 0 {
                    slelsep := ","
                    if p {
                        slelsep = ",\n" + strings.Repeat(t, chldD)
                    }
                    s = append(s, map[string]interface{}{
                        "t": "r",
                        "v": slelsep,
                        "d": chldD,
                    })
                }
            }
            slob := "["
            if p {
                slob = "[\n" + strings.Repeat(t, chldD)
            }
            s = append(s, map[string]interface{}{
                "t": "r",
                "v": slob,
                "d": chldD,
            })
        case XlDict:
            d := v.value.(Dict)
            if len(d) == 0 {
                r.WriteString("{}")
                continue
            }
            dpL := make([]string, 0, len(d))
            for k := range d {
                dpL = append(dpL, k)
            }
            chldD := curD + 1
            slcb := "}"
            if p {
                slcb = "\n" + strings.Repeat(t, curD) + "}"
            }
            s = append(s, map[string]interface{}{
                "t": "r",
                "v": slcb,
                "d": curD,
            })
            for i := len(dpL) - 1; i >= 0; i -= 1 {
                pK := dpL[i]
                pV := d[pK]
                s = append(s, map[string]interface{}{
                    "t": "v",
                    "v": pV,
                    "d": chldD,
                })
                sdelsep := ":"
                if p {
                    sdelsep = ": "
                }
                s = append(s, map[string]interface{}{
                    "t": "r",
                    "v": "\"" + pK + "\"" + sdelsep,
                    "d": chldD,
                })
                if i > 0 {
                    sdelsep := ","
                    if p {
                        sdelsep = ",\n" + strings.Repeat(t, chldD)
                    }
                    s = append(s, map[string]interface{}{
                        "t": "r",
                        "v": sdelsep,
                        "d": chldD,
                    })
                }
            }
            sdob := "{"
            if p {
                sdob = "{\n" + strings.Repeat(t, chldD)
            }
            s = append(s, map[string]interface{}{
                "t": "r",
                "v": sdob,
                "d": chldD,
            })
        default:
            r.WriteString("\"" + reflect.TypeOf(v.value).String() + "\"")
        }
    }
    return r.String()
}
