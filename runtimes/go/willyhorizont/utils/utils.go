package utils

import (
	"errors"
	"reflect"
	"cross-language-programming-concepts/runtimes/go/willyhorizont/types"
	"cross-language-programming-concepts/runtimes/go/willyhorizont/value"
)

type any = types.Any
type pythonLikeList = types.PythonLikeList
type pythonLikeDict = types.PythonLikeDict
type jsLikeFunction = types.JsLikeFunction

var jsLikeUndefined = value.JsLikeUndefined
var anyType = types.AnyType

func Ternary(isConditionTrue bool, callbackFunctionIfConditionTrue jsLikeFunction, callbackFunctionIfConditionFalse jsLikeFunction) any {
	if (isConditionTrue == true) {
		return callbackFunctionIfConditionTrue()
	}
	return callbackFunctionIfConditionFalse()
}

func ArraySome(callbackFunction func(...any) bool, anyArray any) bool {
	for arrayItemIndex, arrayItem := range anyArray.(pythonLikeList) {
		if (callbackFunction(arrayItem, arrayItemIndex, anyArray) == true) {
			return true
		}
	}
	return false
}

func CheckIsJsLikeUndefined(anything any) bool {
    return (anything == jsLikeUndefined)
}

func CheckIsJsLikeNull(anything any) bool {
	return (anything == nil)
}

func CheckIsJsLikeBoolean(anything any) bool {
	return ((reflect.TypeOf(anything).Kind() == reflect.Bool) && ((anything == true) || (anything == false)))
}

func CheckIsJsLikeString(anything any) bool {
	return (reflect.TypeOf(anything).Kind() == reflect.String)
}

func CheckIsJsLikeInt(anything any) bool {
	anyGoKind := reflect.TypeOf(anything).Kind()
	return (ArraySome(func(variadicArguments ...any) bool {
		numericGoKind := variadicArguments[0]
		return (anyGoKind == numericGoKind)
	}, (pythonLikeList{reflect.Int, reflect.Int8, reflect.Int16, reflect.Int32, reflect.Int64, reflect.Uint, reflect.Uint8, reflect.Uint16, reflect.Uint32, reflect.Uint64})))
}

func CheckIsJsLikeFloat(anything any) bool {
	anyGoKind := reflect.TypeOf(anything).Kind()
	return (ArraySome(func(variadicArguments ...any) bool {
		numericGoKind := variadicArguments[0]
		return (anyGoKind == numericGoKind)
	}, (pythonLikeList{reflect.Float32, reflect.Float64, reflect.Complex64, reflect.Complex128})))
}

func CheckIsPythonLikeDict(anything any) bool {
	anyGoType := reflect.TypeOf(anything)
	return ((anyGoType.Kind() == reflect.Map) || ((anyGoType.Kind() == reflect.Map) && (anyGoType.Key().Kind() == reflect.String) && (anyGoType.Elem().Kind() == reflect.Interface)) || (anyGoType == reflect.TypeOf(pythonLikeDict{})) || (anyGoType.String() == "map[string]interface {}") || (anyGoType.String() == "map[string]interface {  }"))
}

func CheckIsPythonLikeList(anything any) bool {
	anyGoType := reflect.TypeOf(anything)
	return ((anyGoType.Kind() == reflect.Slice) || (anyGoType == reflect.TypeOf(pythonLikeList{})) || (anyGoType.String() == "[]interface {}") || (anyGoType.String() == "[]interface {  }"))
}

func CheckIsJsLikeFunction(anything any) bool {
	return (reflect.TypeOf(anything).Kind() == reflect.Func)
}

func GetType(anything any) string {
	if (CheckIsJsLikeUndefined(anything) == true) {
		return anyType.JsLikeUndefined
	}
	if (CheckIsJsLikeNull(anything) == true) {
		return anyType.JsLikeNull
	}
	if (CheckIsJsLikeBoolean(anything) == true) {
		return anyType.JsLikeBoolean
	}
	if (CheckIsJsLikeString(anything) == true) {
		return anyType.JsLikeString
	}
	if (CheckIsJsLikeInt(anything) == true) {
		return anyType.JsLikeInt
	}
	if (CheckIsJsLikeFloat(anything) == true) {
		return anyType.JsLikeFloat
	}
	if (CheckIsPythonLikeDict(anything) == true) {
		return anyType.PythonLikeDict
	}
	if (CheckIsPythonLikeList(anything) == true) {
		return anyType.PythonLikeList
	}
	if (CheckIsJsLikeFunction(anything) == true) {
		return anyType.JsLikeFunction
	}
	return reflect.TypeOf(anything).String()
}

func ParseFloat(anything any) any {
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