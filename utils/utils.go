package utils

import (
	// "errors"
	// "fmt"
	"reflect"
	// "strings"
)

func Multiply(a int, b int) int {
    return (a * b)
}

var JsLikeType = struct {
	Null string
	Boolean string
	String string
	Numeric string
	Int string
	Float string
	Object string
	Array string
	Function string
}{
	Null: "Null",
	Boolean: "Boolean",
	String: "String",
	Numeric: "Numeric",
	Int: "Int",
	Float: "Float",
	Object: "Object",
	Array: "Array",
	Function: "Function",
}

func Ternary(isConditionTrue bool, callbackFunctionIfConditionTrue func(...interface{}) interface{}, callbackFunctionIfConditionFalse func(...interface{}) interface{}) interface{} {
	if (isConditionTrue == true) {
		return callbackFunctionIfConditionTrue()
	}
	return callbackFunctionIfConditionFalse()
}

func ArraySome(callbackFunction func(...interface{}) bool, anyArray interface{}) bool {
	for arrayItemIndex, arrayItem := range anyArray.([]interface{}) {
		if (callbackFunction(arrayItem, arrayItemIndex, anyArray) == true) {
			return true
		}
	}
	return false
}

func CheckIsLikeJsNull(anything interface{}) bool {
	return (anything == nil)
}

func CheckIsLikeJsBoolean(anything interface{}) bool {
	return ((reflect.TypeOf(anything).Kind() == reflect.Bool) && ((anything == true) || (anything == false)))
}

func CheckIsLikeJsString(anything interface{}) bool {
	return (reflect.TypeOf(anything).Kind() == reflect.String)
}

func CheckIsLikeJsNumeric(anything interface{}) bool {
	anythingGoKind := reflect.TypeOf(anything).Kind()
	return (ArraySome(func(restArgumentsArraySomeCallback ...interface{}) bool {
		numericGoKind := restArgumentsArraySomeCallback[0]
		return (anythingGoKind == numericGoKind)
	}, ([]interface{}{reflect.Int, reflect.Int8, reflect.Int16, reflect.Int32, reflect.Int64, reflect.Uint, reflect.Uint8, reflect.Uint16, reflect.Uint32, reflect.Uint64, reflect.Float32, reflect.Float64, reflect.Complex64, reflect.Complex128})))
}

func CheckIsLikeJsInt(anything interface{}) bool {
	anythingGoKind := reflect.TypeOf(anything).Kind()
	return (ArraySome(func(restArgumentsArraySomeCallback ...interface{}) bool {
		numericGoKind := restArgumentsArraySomeCallback[0]
		return (anythingGoKind == numericGoKind)
	}, ([]interface{}{reflect.Int, reflect.Int8, reflect.Int16, reflect.Int32, reflect.Int64, reflect.Uint, reflect.Uint8, reflect.Uint16, reflect.Uint32, reflect.Uint64})))
}

func CheckIsLikeJsFloat(anything interface{}) bool {
	anythingGoKind := reflect.TypeOf(anything).Kind()
	return (ArraySome(func(restArgumentsArraySomeCallback ...interface{}) bool {
		numericGoKind := restArgumentsArraySomeCallback[0]
		return (anythingGoKind == numericGoKind)
	}, ([]interface{}{reflect.Float32, reflect.Float64, reflect.Complex64, reflect.Complex128})))
}

func CheckIsLikeJsObject(anything interface{}) bool {
	anythingGoType := reflect.TypeOf(anything)
	return ((anythingGoType.Kind() == reflect.Map) || ((anythingGoType.Kind() == reflect.Map) && (anythingGoType.Key().Kind() == reflect.String) && (anythingGoType.Elem().Kind() == reflect.Interface)) || (anythingGoType == reflect.TypeOf(map[string]interface{}{})) || (anythingGoType.String() == "map[string]interface {}") || (anythingGoType.String() == "map[string]interface {  }"))
}

func CheckIsLikeJsArray(anything interface{}) bool {
	anythingGoType := reflect.TypeOf(anything)
	return ((anythingGoType.Kind() == reflect.Slice) || (anythingGoType == reflect.TypeOf([]interface{}{})) || (anythingGoType.String() == "[]interface {}") || (anythingGoType.String() == "[]interface {  }"))
}

func CheckIsLikeJsFunction(anything interface{}) bool {
	return (reflect.TypeOf(anything).Kind() == reflect.Func)
}

func GetType(anything interface{}) string {
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
	return reflect.TypeOf(anything).String()
}
