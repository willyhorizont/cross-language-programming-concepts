package utils

import (
	"errors"
	"reflect"
	"cross-language-programming-concepts/runtimes/go/willyhorizont/types"
)

type jsLikeAny = types.JsLikeAny
type jsLikeArray = types.JsLikeArray
type jsLikeObject = types.JsLikeObject
type jsLikeFunction = types.JsLikeFunction

var jsLikeUndefined = types.JsLikeUndefined
var jsLikeType = types.JsLikeType

func Ternary(isConditionTrue bool, callbackFunctionIfConditionTrue jsLikeFunction, callbackFunctionIfConditionFalse jsLikeFunction) jsLikeAny {
	if (isConditionTrue == true) {
		return callbackFunctionIfConditionTrue()
	}
	return callbackFunctionIfConditionFalse()
}

func ArraySome(callbackFunction func(...jsLikeAny) bool, anyArray jsLikeAny) bool {
	for arrayItemIndex, arrayItem := range anyArray.(jsLikeArray) {
		if (callbackFunction(arrayItem, arrayItemIndex, anyArray) == true) {
			return true
		}
	}
	return false
}

func CheckIsLikeJsUndefined(anything jsLikeAny) bool {
    return (anything == jsLikeUndefined)
}

func CheckIsLikeJsNull(anything jsLikeAny) bool {
	return (anything == nil)
}

func CheckIsLikeJsBoolean(anything jsLikeAny) bool {
	return ((reflect.TypeOf(anything).Kind() == reflect.Bool) && ((anything == true) || (anything == false)))
}

func CheckIsLikeJsString(anything jsLikeAny) bool {
	return (reflect.TypeOf(anything).Kind() == reflect.String)
}

func CheckIsLikeJsInt(anything jsLikeAny) bool {
	anyGoKind := reflect.TypeOf(anything).Kind()
	return (ArraySome(func(variadicArguments ...jsLikeAny) bool {
		numericGoKind := variadicArguments[0]
		return (anyGoKind == numericGoKind)
	}, (jsLikeArray{reflect.Int, reflect.Int8, reflect.Int16, reflect.Int32, reflect.Int64, reflect.Uint, reflect.Uint8, reflect.Uint16, reflect.Uint32, reflect.Uint64})))
}

func CheckIsLikeJsFloat(anything jsLikeAny) bool {
	anyGoKind := reflect.TypeOf(anything).Kind()
	return (ArraySome(func(variadicArguments ...jsLikeAny) bool {
		numericGoKind := variadicArguments[0]
		return (anyGoKind == numericGoKind)
	}, (jsLikeArray{reflect.Float32, reflect.Float64, reflect.Complex64, reflect.Complex128})))
}

func CheckIsLikeJsObject(anything jsLikeAny) bool {
	anyGoType := reflect.TypeOf(anything)
	return ((anyGoType.Kind() == reflect.Map) || ((anyGoType.Kind() == reflect.Map) && (anyGoType.Key().Kind() == reflect.String) && (anyGoType.Elem().Kind() == reflect.Interface)) || (anyGoType == reflect.TypeOf(jsLikeObject{})) || (anyGoType.String() == "map[string]interface {}") || (anyGoType.String() == "map[string]interface {  }"))
}

func CheckIsLikeJsArray(anything jsLikeAny) bool {
	anyGoType := reflect.TypeOf(anything)
	return ((anyGoType.Kind() == reflect.Slice) || (anyGoType == reflect.TypeOf(jsLikeArray{})) || (anyGoType.String() == "[]interface {}") || (anyGoType.String() == "[]interface {  }"))
}

func CheckIsLikeJsFunction(anything jsLikeAny) bool {
	return (reflect.TypeOf(anything).Kind() == reflect.Func)
}

func GetJsLikeType(anything jsLikeAny) string {
	// TODO
	if (CheckIsLikeJsUndefined(anything) == true) {
		return jsLikeType.Undefined
	}
	if (CheckIsLikeJsNull(anything) == true) {
		return jsLikeType.Null
	}
	if (CheckIsLikeJsBoolean(anything) == true) {
		return jsLikeType.Boolean
	}
	if (CheckIsLikeJsString(anything) == true) {
		return jsLikeType.String
	}
	if (CheckIsLikeJsInt(anything) == true) {
		return jsLikeType.Int
	}
	if (CheckIsLikeJsFloat(anything) == true) {
		return jsLikeType.Float
	}
	if (CheckIsLikeJsObject(anything) == true) {
		return jsLikeType.Object
	}
	if (CheckIsLikeJsArray(anything) == true) {
		return jsLikeType.Array
	}
	if (CheckIsLikeJsFunction(anything) == true) {
		return jsLikeType.Function
	}
	// TODO
	// if (CheckIsLikeJsError(anything) == true) {
	// 	return jsLikeType.Error
	// }
	// TODO
	// if (CheckIsLikeJsDate(anything) == true) {
	// 	return jsLikeType.Date
	// }
	return reflect.TypeOf(anything).String()
}

func ParseFloat(anything jsLikeAny) jsLikeAny {
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