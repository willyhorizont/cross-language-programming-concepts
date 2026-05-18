package willyhorizont

import (
	"fmt"
	"errors"
	"reflect"
)

type TypeAny interface{}
type TypePythonLikeList []TypeAny
type TypePythonLikeDict map[string]TypeAny
type TypeJsLikeFunction func(...TypeAny) TypeAny
type TypeJsLikeInt int64
type TypeJsLikeFloat float64

var JsonType = struct {
	JsLikeNull string
	JsLikeBoolean string
	JsLikeString string
	JsLikeInt string
	JsLikeFloat string
	PythonLikeDict string
	PythonLikeList string
}{
	JsLikeNull: "JsLikeNull",
	JsLikeBoolean: "JsLikeBoolean",
	JsLikeString: "JsLikeString",
	JsLikeInt: "JsLikeInt",
	JsLikeFloat: "JsLikeFloat",
	PythonLikeDict: "PythonLikeDict",
	PythonLikeList: "PythonLikeList",
}

func ternary(variadicArguments ...TypeAny) TypeAny {
	isConditionTrue, callbackFunctionIfConditionTrue, callbackFunctionIfConditionFalse := variadicArguments[0], variadicArguments[1], variadicArguments[2]
	if (isConditionTrue == true) {
		return callbackFunctionIfConditionTrue.(TypeJsLikeFunction)()
	}
	return callbackFunctionIfConditionFalse.(TypeJsLikeFunction)()
}

func getIsAnyItemInListMatchingCondition(variadicArguments ...TypeAny) TypeAny {
	callbackFunction, anyPythonLikeList := variadicArguments[0], variadicArguments[1]
	for pythonLikeListIndex, pythonLikeListItem := range anyPythonLikeList.(TypePythonLikeList) {
		if (callbackFunction.(TypeJsLikeFunction)(pythonLikeListItem, pythonLikeListIndex, anyPythonLikeList) == true) {
			return true
		}
	}
	return false
}

func getIsJsLikeNull(variadicArguments ...TypeAny) TypeAny {
	anything := variadicArguments[0]
	return (anything == nil)
}

func getIsJsLikeBoolean(variadicArguments ...TypeAny) TypeAny {
	anything := variadicArguments[0]
	return ((reflect.TypeOf(anything).Kind() == reflect.Bool) && ((anything == true) || (anything == false)))
}

func getIsJsLikeString(variadicArguments ...TypeAny) TypeAny {
	anything := variadicArguments[0]
	return (reflect.TypeOf(anything).Kind() == reflect.String)
}

func getIsJsLikeInt(variadicArguments ...TypeAny) TypeAny {
	anything := variadicArguments[0]
	anyGoKind := reflect.TypeOf(anything).Kind()
	return (getIsAnyItemInListMatchingCondition(TypeJsLikeFunction(func(variadicArguments ...TypeAny) TypeAny {
		numericGoKind := variadicArguments[0]
		return (anyGoKind == numericGoKind)
	}), (TypePythonLikeList{reflect.Int, reflect.Int8, reflect.Int16, reflect.Int32, reflect.Int64, reflect.Uint, reflect.Uint8, reflect.Uint16, reflect.Uint32, reflect.Uint64})))
}

func getIsJsLikeFloat(variadicArguments ...TypeAny) TypeAny {
	anything := variadicArguments[0]
	anyGoKind := reflect.TypeOf(anything).Kind()
	return (getIsAnyItemInListMatchingCondition(TypeJsLikeFunction(func(variadicArguments ...TypeAny) TypeAny {
		numericGoKind := variadicArguments[0]
		return (anyGoKind == numericGoKind)
	}), (TypePythonLikeList{reflect.Float32, reflect.Float64, reflect.Complex64, reflect.Complex128})))
}

func getIsPythonLikeDict(variadicArguments ...TypeAny) TypeAny {
	anything := variadicArguments[0]
	anyGoType := reflect.TypeOf(anything)
	return ((anyGoType.Kind() == reflect.Map) || ((anyGoType.Kind() == reflect.Map) && (anyGoType.Key().Kind() == reflect.String) && (anyGoType.Elem().Kind() == reflect.Interface)) || (anyGoType == reflect.TypeOf(TypePythonLikeDict{})) || (anyGoType.String() == "map[string]interface {}") || (anyGoType.String() == "map[string]interface {  }"))
}

func getIsPythonLikeList(variadicArguments ...TypeAny) TypeAny {
	anything := variadicArguments[0]
	anyGoType := reflect.TypeOf(anything)
	return ((anyGoType.Kind() == reflect.Slice) || (anyGoType == reflect.TypeOf(TypePythonLikeList{})) || (anyGoType.String() == "[]interface {}") || (anyGoType.String() == "[]interface {  }"))
}

func getIsJsLikeFunction(variadicArguments ...TypeAny) TypeAny {
	anything := variadicArguments[0]
	return (reflect.TypeOf(anything).Kind() == reflect.Func)
}

func getType(variadicArguments ...TypeAny) TypeAny {
	anything := variadicArguments[0]
	if (getIsJsLikeNull(anything) == true) {
		return JsonType.JsLikeNull
	}
	if (getIsJsLikeBoolean(anything) == true) {
		return JsonType.JsLikeBoolean
	}
	if (getIsJsLikeString(anything) == true) {
		return JsonType.JsLikeString
	}
	if (getIsJsLikeInt(anything) == true) {
		return JsonType.JsLikeInt
	}
	if (getIsJsLikeFloat(anything) == true) {
		return JsonType.JsLikeFloat
	}
	if (getIsPythonLikeDict(anything) == true) {
		return JsonType.PythonLikeDict
	}
	if (getIsPythonLikeList(anything) == true) {
		return JsonType.PythonLikeList
	}
	return reflect.TypeOf(anything).String()
}

func getStringValueOfPrimitive(variadicArguments ...TypeAny) TypeAny {
	anything := variadicArguments[0]
	if (anything == nil) {
		return "null"
	}
	anyGoValue := reflect.ValueOf(anything)
	if (anyGoValue.Kind() == reflect.Bool) {
		return fmt.Sprintf("%t", anyGoValue.Bool())
	}
	if (anyGoValue.Kind() == reflect.String) {
		return anyGoValue.String()
	}
	if ((getIsAnyItemInListMatchingCondition(TypeJsLikeFunction(func(variadicArguments ...TypeAny) TypeAny {
		pythonLikeListItem, _ := variadicArguments[0], variadicArguments[1:]
		return (anyGoValue.Kind() == pythonLikeListItem)
	}), (TypePythonLikeList{reflect.Int, reflect.Int8, reflect.Int16, reflect.Int32, reflect.Int64}))) == true) {
		return fmt.Sprintf("%d", anyGoValue.Int())
	}
	if ((getIsAnyItemInListMatchingCondition(TypeJsLikeFunction(func(variadicArguments ...TypeAny) TypeAny {
		pythonLikeListItem, _ := variadicArguments[0], variadicArguments[1:]
		return (anyGoValue.Kind() == pythonLikeListItem)
	}), (TypePythonLikeList{reflect.Uint, reflect.Uint8, reflect.Uint16, reflect.Uint32, reflect.Uint64}))) == true) {
		return fmt.Sprintf("%d", anyGoValue.Uint())
	}
	if ((getIsAnyItemInListMatchingCondition(TypeJsLikeFunction(func(variadicArguments ...TypeAny) TypeAny {
		pythonLikeListItem, _ := variadicArguments[0], variadicArguments[1:]
		return (anyGoValue.Kind() == pythonLikeListItem)
	}), (TypePythonLikeList{reflect.Float32, reflect.Float64}))) == true) {
		return fmt.Sprintf("%f", anyGoValue.Float())
	}
	if ((getIsAnyItemInListMatchingCondition(TypeJsLikeFunction(func(variadicArguments ...TypeAny) TypeAny {
		pythonLikeListItem, _ := variadicArguments[0], variadicArguments[1:]
		return (anyGoValue.Kind() == pythonLikeListItem)
	}), (TypePythonLikeList{reflect.Complex64, reflect.Complex128}))) == true) {
		return fmt.Sprintf("%g", anyGoValue.Complex())
	}
	return errors.New("Error: expecting Go primitive value")
}

func combineAllListItem(variadicArguments ...TypeAny) TypeAny {
	callbackFunction, anyPythonLikeList, initialValue := variadicArguments[0], variadicArguments[1], variadicArguments[2]
	result := initialValue
	for pythonLikeListIndex, pythonLikeListItem := range anyPythonLikeList.(TypePythonLikeList) {
		result = callbackFunction.(TypeJsLikeFunction)(result, pythonLikeListItem, pythonLikeListIndex, anyPythonLikeList)
	}
	return result
}

func pipe(variadicArguments ...TypeAny) TypeAny {
	var pipeLastResult TypeAny = nil
	pipeResult := combineAllListItem(TypeJsLikeFunction(func(variadicArguments ...TypeAny) TypeAny {
		currentResult, currentArgument, _ := variadicArguments[0], variadicArguments[1], variadicArguments[2:]
		pipeLastResult = currentResult
		if (currentResult == nil) {
			return currentArgument
		}
		if (getIsJsLikeFunction(currentArgument) == true) {
			return currentArgument.(TypeJsLikeFunction)(currentResult)
		}
		return nil
	}), variadicArguments, nil)
	if (getIsJsLikeFunction(pipeResult) == true) {
		return pipeResult.(TypeJsLikeFunction)(pipeLastResult)
	}
	return pipeResult
}

func parseFloat(variadicArguments ...TypeAny) TypeAny {
	anything := variadicArguments[0]
	switch anyGoType := anything.(type) {
	case TypeJsLikeFloat:
		return anyGoType
	case float32:
		return TypeJsLikeFloat(anyGoType)
	case int64:
		return TypeJsLikeFloat(anyGoType)
	case int32: // rune
		return TypeJsLikeFloat(anyGoType)
	case int16:
		return TypeJsLikeFloat(anyGoType)
	case int8:
		return TypeJsLikeFloat(anyGoType)
	case int:
		return TypeJsLikeFloat(anyGoType)
	case uint64:
		return TypeJsLikeFloat(anyGoType)
	case uint32:
		return TypeJsLikeFloat(anyGoType)
	case uint16:
		return TypeJsLikeFloat(anyGoType)
	case uint8: // byte
		return TypeJsLikeFloat(anyGoType)
	case uint:
		return TypeJsLikeFloat(anyGoType)
	default:
		return errors.New("expecting float64-convertible Go value")
	}
}

var Utils = struct {
    Ternary func(...TypeAny) TypeAny
	GetIsAnyItemInListMatchingCondition func(...TypeAny) TypeAny
	GetIsJsLikeNull func(...TypeAny) TypeAny
	GetIsJsLikeBoolean func(...TypeAny) TypeAny
	GetIsJsLikeString func(...TypeAny) TypeAny
	GetIsJsLikeInt func(...TypeAny) TypeAny
	GetIsJsLikeFloat func(...TypeAny) TypeAny
	GetIsPythonLikeDict func(...TypeAny) TypeAny
	GetIsPythonLikeList func(...TypeAny) TypeAny
	GetIsJsLikeFunction func(...TypeAny) TypeAny
	GetType func(...TypeAny) TypeAny
	GetStringValueOfPrimitive func(...TypeAny) TypeAny
	CombineAllListItem func(...TypeAny) TypeAny
	Pipe func(...TypeAny) TypeAny
	ParseFloat func(...TypeAny) TypeAny
}{
    Ternary: ternary,
    GetIsAnyItemInListMatchingCondition: getIsAnyItemInListMatchingCondition,
    GetIsJsLikeNull: getIsJsLikeNull,
	GetIsJsLikeBoolean: getIsJsLikeBoolean,
	GetIsJsLikeString: getIsJsLikeString,
	GetIsJsLikeInt: getIsJsLikeInt,
	GetIsJsLikeFloat: getIsJsLikeFloat,
	GetIsPythonLikeDict: getIsPythonLikeDict,
	GetIsPythonLikeList: getIsPythonLikeList,
	GetIsJsLikeFunction: getIsJsLikeFunction,
	GetType: getType,
	GetStringValueOfPrimitive: getStringValueOfPrimitive,
	CombineAllListItem: combineAllListItem,
	Pipe: pipe,
	ParseFloat: parseFloat,
}