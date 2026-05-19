package willyhorizont

import (
	"fmt"
	"errors"
	"reflect"
	"iter"
	"slices"
	"strings"
)

type TypeDotAny interface{}
type TypeDotPythonLikeList []TypeDotAny
type PythonLikeDictEntry struct {
	Key   string
	Value TypeDotAny
}
type TypeDotPythonLikeDictPreserveOrder []PythonLikeDictEntry
type TypeDotPythonLikeDict map[string]TypeDotAny
type TypeDotJsLikeFunction func(...TypeDotAny) TypeDotAny
type TypeDotJsLikeInt int64
type TypeDotJsLikeFloat float64
// entries := TypeDotPythonLikeDictPreserveOrder{
// 	{"a", 1},
// 	{"b", 2},
// 	{"c", 3},
// }

var JsonType = TypeDotPythonLikeDict{
	"JsLikeNull": "JsLikeNull",
	"JsLikeBoolean": "JsLikeBoolean",
	"JsLikeString": "JsLikeString",
	"JsLikeInt": "JsLikeInt",
	"JsLikeFloat": "JsLikeFloat",
	"PythonLikeDict": "PythonLikeDict",
	"PythonLikeList": "PythonLikeList",
}

func ternary(variadicArguments ...TypeDotAny) TypeDotAny {
	isConditionTrue, callbackFunctionIfConditionTrue, callbackFunctionIfConditionFalse := variadicArguments[0], variadicArguments[1], variadicArguments[2]
	if (isConditionTrue == true) {
		return callbackFunctionIfConditionTrue.(TypeDotJsLikeFunction)()
	}
	return callbackFunctionIfConditionFalse.(TypeDotJsLikeFunction)()
}

func getIsAnyItemInListMatchingCondition(variadicArguments ...TypeDotAny) TypeDotAny {
	callbackFunction, anyPythonLikeList := variadicArguments[0], variadicArguments[1]
	for pythonLikeListIndex, pythonLikeListItem := range anyPythonLikeList.(TypeDotPythonLikeList) {
		if (callbackFunction.(TypeDotJsLikeFunction)(pythonLikeListItem, pythonLikeListIndex, anyPythonLikeList) == true) {
			return true
		}
	}
	return false
}

func getIsJsLikeNull(variadicArguments ...TypeDotAny) TypeDotAny {
	anything := variadicArguments[0]
	return (anything == nil)
}

func getIsJsLikeBoolean(variadicArguments ...TypeDotAny) TypeDotAny {
	anything := variadicArguments[0]
	return ((reflect.TypeOf(anything).Kind() == reflect.Bool) && ((anything == true) || (anything == false)))
}

func getIsJsLikeString(variadicArguments ...TypeDotAny) TypeDotAny {
	anything := variadicArguments[0]
	return (reflect.TypeOf(anything).Kind() == reflect.String)
}

func getIsJsLikeInt(variadicArguments ...TypeDotAny) TypeDotAny {
	anything := variadicArguments[0]
	anyGoKind := reflect.TypeOf(anything).Kind()
	return (getIsAnyItemInListMatchingCondition(TypeDotJsLikeFunction(func(variadicArguments ...TypeDotAny) TypeDotAny {
		numericGoKind := variadicArguments[0]
		return (anyGoKind == numericGoKind)
	}), (TypeDotPythonLikeList{reflect.Int, reflect.Int8, reflect.Int16, reflect.Int32, reflect.Int64, reflect.Uint, reflect.Uint8, reflect.Uint16, reflect.Uint32, reflect.Uint64})))
}

func getIsJsLikeFloat(variadicArguments ...TypeDotAny) TypeDotAny {
	anything := variadicArguments[0]
	anyGoKind := reflect.TypeOf(anything).Kind()
	return (getIsAnyItemInListMatchingCondition(TypeDotJsLikeFunction(func(variadicArguments ...TypeDotAny) TypeDotAny {
		numericGoKind := variadicArguments[0]
		return (anyGoKind == numericGoKind)
	}), (TypeDotPythonLikeList{reflect.Float32, reflect.Float64, reflect.Complex64, reflect.Complex128})))
}

func getIsPythonLikeDict(variadicArguments ...TypeDotAny) TypeDotAny {
	anything := variadicArguments[0]
	anyGoType := reflect.TypeOf(anything)
	return ((anyGoType.Kind() == reflect.Map) || ((anyGoType.Kind() == reflect.Map) && (anyGoType.Key().Kind() == reflect.String) && (anyGoType.Elem().Kind() == reflect.Interface)) || (anyGoType == reflect.TypeOf(TypeDotPythonLikeDict{})) || (anyGoType.String() == "map[string]interface {}") || (anyGoType.String() == "map[string]interface {  }"))
}

func getIsPythonLikeList(variadicArguments ...TypeDotAny) TypeDotAny {
	anything := variadicArguments[0]
	anyGoType := reflect.TypeOf(anything)
	return ((anyGoType.Kind() == reflect.Slice) || (anyGoType == reflect.TypeOf(TypeDotPythonLikeList{})) || (anyGoType.String() == "[]interface {}") || (anyGoType.String() == "[]interface {  }"))
}

func getIsJsLikeFunction(variadicArguments ...TypeDotAny) TypeDotAny {
	anything := variadicArguments[0]
	return (reflect.TypeOf(anything).Kind() == reflect.Func)
}

func getType(variadicArguments ...TypeDotAny) TypeDotAny {
	anything := variadicArguments[0]
	if (getIsJsLikeNull(anything) == true) {
		return JsonType["JsLikeNull"]
	}
	if (getIsJsLikeBoolean(anything) == true) {
		return JsonType["JsLikeBoolean"]
	}
	if (getIsJsLikeString(anything) == true) {
		return JsonType["JsLikeString"]
	}
	if (getIsJsLikeInt(anything) == true) {
		return JsonType["JsLikeInt"]
	}
	if (getIsJsLikeFloat(anything) == true) {
		return JsonType["JsLikeFloat"]
	}
	if (getIsPythonLikeDict(anything) == true) {
		return JsonType["PythonLikeDict"]
	}
	if (getIsPythonLikeList(anything) == true) {
		return JsonType["PythonLikeList"]
	}
	return reflect.TypeOf(anything).String()
}

func getStringValueOfPrimitive(variadicArguments ...TypeDotAny) TypeDotAny {
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
	if ((getIsAnyItemInListMatchingCondition(TypeDotJsLikeFunction(func(variadicArguments ...TypeDotAny) TypeDotAny {
		pythonLikeListItem, _ := variadicArguments[0], variadicArguments[1:]
		return (anyGoValue.Kind() == pythonLikeListItem)
	}), (TypeDotPythonLikeList{reflect.Int, reflect.Int8, reflect.Int16, reflect.Int32, reflect.Int64}))) == true) {
		return fmt.Sprintf("%d", anyGoValue.Int())
	}
	if ((getIsAnyItemInListMatchingCondition(TypeDotJsLikeFunction(func(variadicArguments ...TypeDotAny) TypeDotAny {
		pythonLikeListItem, _ := variadicArguments[0], variadicArguments[1:]
		return (anyGoValue.Kind() == pythonLikeListItem)
	}), (TypeDotPythonLikeList{reflect.Uint, reflect.Uint8, reflect.Uint16, reflect.Uint32, reflect.Uint64}))) == true) {
		return fmt.Sprintf("%d", anyGoValue.Uint())
	}
	if ((getIsAnyItemInListMatchingCondition(TypeDotJsLikeFunction(func(variadicArguments ...TypeDotAny) TypeDotAny {
		pythonLikeListItem, _ := variadicArguments[0], variadicArguments[1:]
		return (anyGoValue.Kind() == pythonLikeListItem)
	}), (TypeDotPythonLikeList{reflect.Float32, reflect.Float64}))) == true) {
		return fmt.Sprintf("%f", anyGoValue.Float())
	}
	if ((getIsAnyItemInListMatchingCondition(TypeDotJsLikeFunction(func(variadicArguments ...TypeDotAny) TypeDotAny {
		pythonLikeListItem, _ := variadicArguments[0], variadicArguments[1:]
		return (anyGoValue.Kind() == pythonLikeListItem)
	}), (TypeDotPythonLikeList{reflect.Complex64, reflect.Complex128}))) == true) {
		return fmt.Sprintf("%g", anyGoValue.Complex())
	}
	return errors.New("Error: expecting Go primitive value")
}

func combineAllListItem(variadicArguments ...TypeDotAny) TypeDotAny {
	callbackFunction, anyPythonLikeList, initialValue := variadicArguments[0], variadicArguments[1], variadicArguments[2]
	result := initialValue
	for pythonLikeListIndex, pythonLikeListItem := range anyPythonLikeList.(TypeDotPythonLikeList) {
		result = callbackFunction.(TypeDotJsLikeFunction)(result, pythonLikeListItem, pythonLikeListIndex, anyPythonLikeList)
	}
	return result
}

func pipe(variadicArguments ...TypeDotAny) TypeDotAny {
	var pipeLastResult TypeDotAny = nil
	pipeResult := combineAllListItem(TypeDotJsLikeFunction(func(variadicArguments ...TypeDotAny) TypeDotAny {
		currentResult, currentArgument, _ := variadicArguments[0], variadicArguments[1], variadicArguments[2:]
		pipeLastResult = currentResult
		if (currentResult == nil) {
			return currentArgument
		}
		if (getIsJsLikeFunction(currentArgument) == true) {
			return currentArgument.(TypeDotJsLikeFunction)(currentResult)
		}
		return nil
	}), variadicArguments, nil)
	if (getIsJsLikeFunction(pipeResult) == true) {
		return pipeResult.(TypeDotJsLikeFunction)(pipeLastResult)
	}
	return pipeResult
}

func jsonStringify(variadicArguments ...TypeDotAny) TypeDotAny {
	next, stop := iter.Pull(slices.Values(variadicArguments))
	defer stop()

	anything, _ := next()
	var pretty TypeDotAny = false
	pythonLikeDictOption, isExist := next()
	if isExist {
		pretty = pythonLikeDictOption.(TypeDotPythonLikeDict)["pretty"]
	}

	var indentation TypeDotAny = strings.Repeat(" ", 4)
	tokenStack := TypeDotPythonLikeList{TypeDotPythonLikeDict{"type": "value", "value": anything, "indentationLevel": 0}}

	var result TypeDotAny = ""
	for (len(tokenStack) > 0) {
		current := tokenStack[len(tokenStack)-1]
		tokenStack = tokenStack[:len(tokenStack)-1]
		currentValue := current.(TypeDotPythonLikeDict)["value"]

		if (current.(TypeDotPythonLikeDict)["type"] == "raw") {
			result = result.(string) + currentValue.(string)
			continue
		}

		currentIndentationLevel := current.(TypeDotPythonLikeDict)["indentationLevel"].(int)
		currentValueType := getType(currentValue)
		if (currentValue == "nil") {
			result = (result.(string) + "null")
			continue
		}
		if (currentValueType == JsonType["JsLikeNull"]) {
			result = (result.(string) + "null")
			continue
		}
		if (currentValueType == JsonType["JsLikeString"]) {
			result = (result.(string) + ("\"" + currentValue.(string) + "\""))
			continue
		}
		if ((currentValueType == JsonType["JsLikeInt"]) || (currentValueType == JsonType["JsLikeFloat"]) || (currentValueType == JsonType["JsLikeBoolean"])) {
			result = (result.(string) + getStringValueOfPrimitive(currentValue).(string))
			continue
		}
		if (currentValueType == JsonType["PythonLikeList"]) {
			if (len(currentValue.(TypeDotPythonLikeList)) == 0) {
				result = (result.(string) + "[]")
				continue
			}
			childIndentationLevel := (currentIndentationLevel + 1)
			tokenStack = append(tokenStack, TypeDotPythonLikeDict{
				"type": "raw",
				"value": ternary((pretty == true), TypeDotJsLikeFunction(func(variadicArguments ...TypeDotAny) TypeDotAny {
					return ("\n" + strings.Repeat(indentation.(string), currentIndentationLevel) + "]")
				}), TypeDotJsLikeFunction(func(variadicArguments ...TypeDotAny) TypeDotAny {
					return "]"
				})),
				"indentationLevel": currentIndentationLevel,
			})
			for i := (len(currentValue.(TypeDotPythonLikeList)) - 1); (i >= 0); i = (i - 1) {
				tokenStack = append(tokenStack, TypeDotPythonLikeDict{
					"type": "value",
					"value": currentValue.(TypeDotPythonLikeList)[i],
					"indentationLevel": childIndentationLevel,
				})
				if (i > 0) {
					tokenStack = append(tokenStack, TypeDotPythonLikeDict{
						"type": "raw",
						"value": ternary((pretty == true), TypeDotJsLikeFunction(func(variadicArguments ...TypeDotAny) TypeDotAny {
							return (",\n" + strings.Repeat(indentation.(string), childIndentationLevel))
						}), TypeDotJsLikeFunction(func(variadicArguments ...TypeDotAny) TypeDotAny {
							return ", "
						})),
						"indentationLevel": childIndentationLevel,
					})
				}
			}
			tokenStack = append(tokenStack, TypeDotPythonLikeDict{
				"type": "raw",
				"value": ternary((pretty == true), TypeDotJsLikeFunction(func(variadicArguments ...TypeDotAny) TypeDotAny {
					return ("[\n" + strings.Repeat(indentation.(string), childIndentationLevel))
				}), TypeDotJsLikeFunction(func(variadicArguments ...TypeDotAny) TypeDotAny {
					return "["
				})),
				"indentationLevel": childIndentationLevel,
			})
			continue
		}
		if (currentValueType == JsonType["PythonLikeDict"]) {
			if (len(currentValue.(TypeDotPythonLikeDict)) == 0) {
				result = (result.(string) + "{}")
				continue
			}
			childIndentationLevel := (currentIndentationLevel + 1)
			tokenStack = append(tokenStack, TypeDotPythonLikeDict{
				"type": "raw",
				"value": ternary((pretty == true), TypeDotJsLikeFunction(func(variadicArguments ...TypeDotAny) TypeDotAny {
					return ("\n" + strings.Repeat(indentation.(string), currentIndentationLevel) + "}")
				}), TypeDotJsLikeFunction(func(variadicArguments ...TypeDotAny) TypeDotAny {
					return " }"
				})),
				"indentationLevel": currentIndentationLevel,
			})
			pythonLikeDictEntryIndex := 0
			for pythonLikeDictKey, pythonLikeDictValue := range currentValue.(TypeDotPythonLikeDict) {
				tokenStack = append(tokenStack, TypeDotPythonLikeDict{
					"type": "value",
					"value": pythonLikeDictValue,
					"indentationLevel": childIndentationLevel,
				})
				tokenStack = append(tokenStack, TypeDotPythonLikeDict{
					"type": "raw",
					"value": ("\"" + pythonLikeDictKey + "\": "),
					"indentationLevel": childIndentationLevel,
				})
				if ((pythonLikeDictEntryIndex + 1) != len(currentValue.(TypeDotPythonLikeDict))) {
					tokenStack = append(tokenStack, TypeDotPythonLikeDict{
						"type": "raw",
						"value": ternary((pretty == true), TypeDotJsLikeFunction(func(variadicArguments ...TypeDotAny) TypeDotAny {
							return (",\n" + strings.Repeat(indentation.(string), childIndentationLevel))
						}), TypeDotJsLikeFunction(func(variadicArguments ...TypeDotAny) TypeDotAny {
							return ", "
						})),
						"indentationLevel": childIndentationLevel,
					})
				}
				pythonLikeDictEntryIndex += 1
			}
			tokenStack = append(tokenStack, TypeDotPythonLikeDict{
				"type": "raw",
				"value": ternary((pretty == true), TypeDotJsLikeFunction(func(variadicArguments ...TypeDotAny) TypeDotAny {
					return ("{\n" + strings.Repeat(indentation.(string), childIndentationLevel))
				}), TypeDotJsLikeFunction(func(variadicArguments ...TypeDotAny) TypeDotAny {
					return "{ "
				})),
				"indentationLevel": childIndentationLevel,
			})
			continue
		}
		result = result.(string) + ("\"" + currentValueType.(string) + "\"")
	}
	return result
}

func parseFloat(variadicArguments ...TypeDotAny) TypeDotAny {
	anything := variadicArguments[0]
	switch anyGoType := anything.(type) {
	case TypeDotJsLikeFloat:
		return anyGoType
	case complex128:
		return TypeDotJsLikeFloat(real(anyGoType))
	case complex64:
		return TypeDotJsLikeFloat(real(complex128(anyGoType)))
	case float64:
		return TypeDotJsLikeFloat(anyGoType)
	case float32:
		return TypeDotJsLikeFloat(anyGoType)
	case int64:
		return TypeDotJsLikeFloat(anyGoType)
	case int32: // rune
		return TypeDotJsLikeFloat(anyGoType)
	case int16:
		return TypeDotJsLikeFloat(anyGoType)
	case int8:
		return TypeDotJsLikeFloat(anyGoType)
	case int:
		return TypeDotJsLikeFloat(anyGoType)
	case uint64:
		return TypeDotJsLikeFloat(anyGoType)
	case uint32:
		return TypeDotJsLikeFloat(anyGoType)
	case uint16:
		return TypeDotJsLikeFloat(anyGoType)
	case uint8: // byte
		return TypeDotJsLikeFloat(anyGoType)
	case uint:
		return TypeDotJsLikeFloat(anyGoType)
	default:
		return errors.New("expecting float64-convertible Go value")
	}
}

func parseInt(variadicArguments ...TypeDotAny) TypeDotAny {
	anything := variadicArguments[0]
	switch anyGoType := anything.(type) {
	case TypeDotJsLikeInt:
		return anyGoType
	case complex128:
		return TypeDotJsLikeInt(real(anyGoType))
	case complex64:
		return TypeDotJsLikeInt(real(complex128(anyGoType)))
	case float64:
		return TypeDotJsLikeInt(anyGoType)
	case float32:
		return TypeDotJsLikeInt(anyGoType)
	case int64:
		return TypeDotJsLikeInt(anyGoType)
	case int32: // rune
		return TypeDotJsLikeInt(anyGoType)
	case int16:
		return TypeDotJsLikeInt(anyGoType)
	case int8:
		return TypeDotJsLikeInt(anyGoType)
	case int:
		return TypeDotJsLikeInt(anyGoType)
	case uint64:
		return TypeDotJsLikeInt(anyGoType)
	case uint32:
		return TypeDotJsLikeInt(anyGoType)
	case uint16:
		return TypeDotJsLikeInt(anyGoType)
	case uint8: // byte
		return TypeDotJsLikeInt(anyGoType)
	case uint:
		return TypeDotJsLikeInt(anyGoType)
	default:
		return errors.New("expecting int-convertible Go value")
	}
}

var Utils = struct {
    Ternary func(...TypeDotAny) TypeDotAny
	GetIsAnyItemInListMatchingCondition func(...TypeDotAny) TypeDotAny
	GetIsJsLikeNull func(...TypeDotAny) TypeDotAny
	GetIsJsLikeBoolean func(...TypeDotAny) TypeDotAny
	GetIsJsLikeString func(...TypeDotAny) TypeDotAny
	GetIsJsLikeInt func(...TypeDotAny) TypeDotAny
	GetIsJsLikeFloat func(...TypeDotAny) TypeDotAny
	GetIsPythonLikeDict func(...TypeDotAny) TypeDotAny
	GetIsPythonLikeList func(...TypeDotAny) TypeDotAny
	GetIsJsLikeFunction func(...TypeDotAny) TypeDotAny
	GetType func(...TypeDotAny) TypeDotAny
	GetStringValueOfPrimitive func(...TypeDotAny) TypeDotAny
	CombineAllListItem func(...TypeDotAny) TypeDotAny
	Pipe func(...TypeDotAny) TypeDotAny
	ParseFloat func(...TypeDotAny) TypeDotAny
	JsonStringify func(...TypeDotAny) TypeDotAny
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
	JsonStringify: jsonStringify,
}