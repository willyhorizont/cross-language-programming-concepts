package utils

import (
	"errors"
	"reflect"
)

type JsLikeAny interface{}
type JsLikeArray []JsLikeAny
type JsLikeObject map[string]JsLikeAny
type JsLikeFunction func(...JsLikeAny) JsLikeAny

type jsLikeUndefined struct{}
var JsLikeUndefined = &jsLikeUndefined{}

var JsLikeType = struct {
	Undefined string
	Null string
	Boolean string
	String string
	Int string
	Float string
	Object string
	Array string
	Function string
	Error string
	Date string
}{
	Undefined: "Undefined",
	Null: "Null",
	Boolean: "Boolean",
	String: "String",
	Int: "Int",
	Float: "Float",
	Object: "Object",
	Array: "Array",
	Function: "Function",
	Error: "Error",
	Date: "Date",
}

func Ternary(isConditionTrue bool, callbackFunctionIfConditionTrue JsLikeFunction, callbackFunctionIfConditionFalse JsLikeFunction) JsLikeAny {
	if (isConditionTrue == true) {
		return callbackFunctionIfConditionTrue()
	}
	return callbackFunctionIfConditionFalse()
}

func ArraySome(callbackFunction func(...JsLikeAny) bool, anyArray JsLikeAny) bool {
	for arrayItemIndex, arrayItem := range anyArray.(JsLikeArray) {
		if (callbackFunction(arrayItem, arrayItemIndex, anyArray) == true) {
			return true
		}
	}
	return false
}

func CheckIsLikeJsUndefined(anything JsLikeAny) bool {
    return (anything == JsLikeUndefined)
}

func CheckIsLikeJsNull(anything JsLikeAny) bool {
	return (anything == nil)
}

func CheckIsLikeJsBoolean(anything JsLikeAny) bool {
	return ((reflect.TypeOf(anything).Kind() == reflect.Bool) && ((anything == true) || (anything == false)))
}

func CheckIsLikeJsString(anything JsLikeAny) bool {
	return (reflect.TypeOf(anything).Kind() == reflect.String)
}

func CheckIsLikeJsInt(anything JsLikeAny) bool {
	anyGoKind := reflect.TypeOf(anything).Kind()
	return (ArraySome(func(variadicArguments ...JsLikeAny) bool {
		numericGoKind := variadicArguments[0]
		return (anyGoKind == numericGoKind)
	}, (JsLikeArray{reflect.Int, reflect.Int8, reflect.Int16, reflect.Int32, reflect.Int64, reflect.Uint, reflect.Uint8, reflect.Uint16, reflect.Uint32, reflect.Uint64})))
}

func CheckIsLikeJsFloat(anything JsLikeAny) bool {
	anyGoKind := reflect.TypeOf(anything).Kind()
	return (ArraySome(func(variadicArguments ...JsLikeAny) bool {
		numericGoKind := variadicArguments[0]
		return (anyGoKind == numericGoKind)
	}, (JsLikeArray{reflect.Float32, reflect.Float64, reflect.Complex64, reflect.Complex128})))
}

func CheckIsLikeJsObject(anything JsLikeAny) bool {
	anyGoType := reflect.TypeOf(anything)
	return ((anyGoType.Kind() == reflect.Map) || ((anyGoType.Kind() == reflect.Map) && (anyGoType.Key().Kind() == reflect.String) && (anyGoType.Elem().Kind() == reflect.Interface)) || (anyGoType == reflect.TypeOf(JsLikeObject{})) || (anyGoType.String() == "map[string]interface {}") || (anyGoType.String() == "map[string]interface {  }"))
}

func CheckIsLikeJsArray(anything JsLikeAny) bool {
	anyGoType := reflect.TypeOf(anything)
	return ((anyGoType.Kind() == reflect.Slice) || (anyGoType == reflect.TypeOf(JsLikeArray{})) || (anyGoType.String() == "[]interface {}") || (anyGoType.String() == "[]interface {  }"))
}

func CheckIsLikeJsFunction(anything JsLikeAny) bool {
	return (reflect.TypeOf(anything).Kind() == reflect.Func)
}

func GetJsLikeType(anything JsLikeAny) string {
	// TODO
	if (CheckIsLikeJsUndefined(anything) == true) {
		return JsLikeType.Undefined
	}
	if (CheckIsLikeJsNull(anything) == true) {
		return JsLikeType.Null
	}
	if (CheckIsLikeJsBoolean(anything) == true) {
		return JsLikeType.Boolean
	}
	if (CheckIsLikeJsString(anything) == true) {
		return JsLikeType.String
	}
	if (CheckIsLikeJsInt(anything) == true) {
		return JsLikeType.Int
	}
	if (CheckIsLikeJsFloat(anything) == true) {
		return JsLikeType.Float
	}
	if (CheckIsLikeJsObject(anything) == true) {
		return JsLikeType.Object
	}
	if (CheckIsLikeJsArray(anything) == true) {
		return JsLikeType.Array
	}
	if (CheckIsLikeJsFunction(anything) == true) {
		return JsLikeType.Function
	}
	// TODO
	// if (CheckIsLikeJsError(anything) == true) {
	// 	return JsLikeType.Error
	// }
	// TODO
	// if (CheckIsLikeJsDate(anything) == true) {
	// 	return JsLikeType.Date
	// }
	return reflect.TypeOf(anything).String()
}

func ParseFloat(anything JsLikeAny) JsLikeAny {
	switch anyGoType := anything.(type) {
	case float64:
		return anyGoType
	case float32:
		return float64(anyGoType)
	case int64:
		return float64(anyGoType)
	case int32: // rune
		return float64(anyGoType)
	case int16:
		return float64(anyGoType)
	case int8:
		return float64(anyGoType)
	case int:
		return float64(anyGoType)
	case uint64:
		return float64(anyGoType)
	case uint32:
		return float64(anyGoType)
	case uint16:
		return float64(anyGoType)
	case uint8: // byte
		return float64(anyGoType)
	case uint:
		return float64(anyGoType)
	default:
		return errors.New("excpected float64-convertible Go value")
	}
}