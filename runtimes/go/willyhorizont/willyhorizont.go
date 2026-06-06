package willyhorizont

import (
	"fmt"
	"errors"
	"reflect"
	"iter"
	"slices"
	"strings"
)

type DataTypeAny interface{}
type DataTypePythonLikeList []DataTypeAny
type PythonLikeDictEntry struct {
	Key   string
	Value DataTypeAny
}
type DataTypePythonLikeDictPreserveOrder []PythonLikeDictEntry // TODO
type DataTypePythonLikeDict map[string]DataTypeAny
type DataTypeJsLikeFunction func(...DataTypeAny) DataTypeAny
type DataTypeJsLikeInt int64
type DataTypeJsLikeFloat float64
// entries := DataTypePythonLikeDictPreserveOrder{
// 	{"a", 1},
// 	{"b", 2},
// 	{"c", 3},
// }

var JsonType = DataTypePythonLikeDict{
	"JsLikeNull": "JsLikeNull",
	"JsLikeBoolean": "JsLikeBoolean",
	"JsLikeString": "JsLikeString",
	"JsLikeInt": "JsLikeInt",
	"JsLikeFloat": "JsLikeFloat",
	"PythonLikeDict": "PythonLikeDict",
	"PythonLikeList": "PythonLikeList",
}

func ternary(variadicArguments ...DataTypeAny) DataTypeAny {
	isConditionTrue, callbackFunctionIfConditionTrue, callbackFunctionIfConditionFalse := variadicArguments[0], variadicArguments[1], variadicArguments[2]
	if (isConditionTrue == true) {
		return callbackFunctionIfConditionTrue.(DataTypeJsLikeFunction)()
	}
	return callbackFunctionIfConditionFalse.(DataTypeJsLikeFunction)()
}

func getIsAnyItemInListMatchingCondition(variadicArguments ...DataTypeAny) DataTypeAny {
	callbackFunction, anyPythonLikeList := variadicArguments[0], variadicArguments[1]
	for pythonLikeListIndex, pythonLikeListItem := range anyPythonLikeList.(DataTypePythonLikeList) {
		if (callbackFunction.(DataTypeJsLikeFunction)(pythonLikeListItem, pythonLikeListIndex, anyPythonLikeList) == true) {
			return true
		}
	}
	return false
}

func getIsJsLikeNull(variadicArguments ...DataTypeAny) DataTypeAny {
	anything := variadicArguments[0]
	return (anything == nil)
}

func getIsJsLikeBoolean(variadicArguments ...DataTypeAny) DataTypeAny {
	anything := variadicArguments[0]
	return ((reflect.TypeOf(anything).Kind() == reflect.Bool) && ((anything == true) || (anything == false)))
}

func getIsJsLikeString(variadicArguments ...DataTypeAny) DataTypeAny {
	anything := variadicArguments[0]
	return (reflect.TypeOf(anything).Kind() == reflect.String)
}

func getIsJsLikeInt(variadicArguments ...DataTypeAny) DataTypeAny {
	anything := variadicArguments[0]
	anyGoKind := reflect.TypeOf(anything).Kind()
	return (getIsAnyItemInListMatchingCondition(DataTypeJsLikeFunction(func(variadicArguments ...DataTypeAny) DataTypeAny {
		numericGoKind := variadicArguments[0]
		return (anyGoKind == numericGoKind)
	}), (DataTypePythonLikeList{reflect.Int, reflect.Int8, reflect.Int16, reflect.Int32, reflect.Int64, reflect.Uint, reflect.Uint8, reflect.Uint16, reflect.Uint32, reflect.Uint64})))
}

func getIsJsLikeFloat(variadicArguments ...DataTypeAny) DataTypeAny {
	anything := variadicArguments[0]
	anyGoKind := reflect.TypeOf(anything).Kind()
	return (getIsAnyItemInListMatchingCondition(DataTypeJsLikeFunction(func(variadicArguments ...DataTypeAny) DataTypeAny {
		numericGoKind := variadicArguments[0]
		return (anyGoKind == numericGoKind)
	}), (DataTypePythonLikeList{reflect.Float32, reflect.Float64, reflect.Complex64, reflect.Complex128})))
}

func getIsPythonLikeDict(variadicArguments ...DataTypeAny) DataTypeAny {
	anything := variadicArguments[0]
	anyGoType := reflect.TypeOf(anything)
	return ((anyGoType.Kind() == reflect.Map) || ((anyGoType.Kind() == reflect.Map) && (anyGoType.Key().Kind() == reflect.String) && (anyGoType.Elem().Kind() == reflect.Interface)) || (anyGoType == reflect.TypeOf(DataTypePythonLikeDict{})) || (anyGoType.String() == "map[string]interface {}") || (anyGoType.String() == "map[string]interface {  }"))
}

func getIsPythonLikeList(variadicArguments ...DataTypeAny) DataTypeAny {
	anything := variadicArguments[0]
	// TODO
	anyGoType := reflect.TypeOf(anything)
	return ((anyGoType.Kind() == reflect.Slice) || (anyGoType == reflect.TypeOf(DataTypePythonLikeList{})) || (anyGoType.String() == "[]interface {}") || (anyGoType.String() == "[]interface {  }"))
}

func getIsJsLikeFunction(variadicArguments ...DataTypeAny) DataTypeAny {
	anything := variadicArguments[0]
	return (reflect.TypeOf(anything).Kind() == reflect.Func)
}

func getType(variadicArguments ...DataTypeAny) DataTypeAny {
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

func getStringValueOfPrimitive(variadicArguments ...DataTypeAny) DataTypeAny {
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
	if ((getIsAnyItemInListMatchingCondition(DataTypeJsLikeFunction(func(variadicArguments ...DataTypeAny) DataTypeAny {
		pythonLikeListItem, _ := variadicArguments[0], variadicArguments[1:]
		return (anyGoValue.Kind() == pythonLikeListItem)
	}), (DataTypePythonLikeList{reflect.Int, reflect.Int8, reflect.Int16, reflect.Int32, reflect.Int64}))) == true) {
		return fmt.Sprintf("%d", anyGoValue.Int())
	}
	if ((getIsAnyItemInListMatchingCondition(DataTypeJsLikeFunction(func(variadicArguments ...DataTypeAny) DataTypeAny {
		pythonLikeListItem, _ := variadicArguments[0], variadicArguments[1:]
		return (anyGoValue.Kind() == pythonLikeListItem)
	}), (DataTypePythonLikeList{reflect.Uint, reflect.Uint8, reflect.Uint16, reflect.Uint32, reflect.Uint64}))) == true) {
		return fmt.Sprintf("%d", anyGoValue.Uint())
	}
	if ((getIsAnyItemInListMatchingCondition(DataTypeJsLikeFunction(func(variadicArguments ...DataTypeAny) DataTypeAny {
		pythonLikeListItem, _ := variadicArguments[0], variadicArguments[1:]
		return (anyGoValue.Kind() == pythonLikeListItem)
	}), (DataTypePythonLikeList{reflect.Float32, reflect.Float64}))) == true) {
		return fmt.Sprintf("%f", anyGoValue.Float())
	}
	if ((getIsAnyItemInListMatchingCondition(DataTypeJsLikeFunction(func(variadicArguments ...DataTypeAny) DataTypeAny {
		pythonLikeListItem, _ := variadicArguments[0], variadicArguments[1:]
		return (anyGoValue.Kind() == pythonLikeListItem)
	}), (DataTypePythonLikeList{reflect.Complex64, reflect.Complex128}))) == true) {
		return fmt.Sprintf("%g", anyGoValue.Complex())
	}
	return errors.New("Error: expecting Go primitive value")
}

func combineAllListItem(variadicArguments ...DataTypeAny) DataTypeAny {
	callbackFunction, anyPythonLikeList, initialValue := variadicArguments[0], variadicArguments[1], variadicArguments[2]
	result := initialValue
	for pythonLikeListIndex, pythonLikeListItem := range anyPythonLikeList.(DataTypePythonLikeList) {
		result = callbackFunction.(DataTypeJsLikeFunction)(result, pythonLikeListItem, pythonLikeListIndex, anyPythonLikeList)
	}
	return result
}

func pipe(variadicArguments ...DataTypeAny) DataTypeAny {
	var pipeLastResult DataTypeAny = nil
	pipeResult := combineAllListItem(DataTypeJsLikeFunction(func(variadicArguments ...DataTypeAny) DataTypeAny {
		currentResult, currentArgument, _ := variadicArguments[0], variadicArguments[1], variadicArguments[2:]
		pipeLastResult = currentResult
		if (currentResult == nil) {
			return currentArgument
		}
		if (getIsJsLikeFunction(currentArgument) == true) {
			return currentArgument.(DataTypeJsLikeFunction)(currentResult)
		}
		return nil
	}), variadicArguments, nil)
	if (getIsJsLikeFunction(pipeResult) == true) {
		return pipeResult.(DataTypeJsLikeFunction)(pipeLastResult)
	}
	return pipeResult
}

func jsonStringify(variadicArguments ...DataTypeAny) DataTypeAny {
	// TODO
	next, stop := iter.Pull(slices.Values(variadicArguments))
	defer stop()

	anything, _ := next()
	var pretty DataTypeAny = false
	pythonLikeDictOption, isExist := next()
	if isExist {
		pretty = pythonLikeDictOption.(DataTypePythonLikeDict)["pretty"]
	}

	var indentation DataTypeAny = strings.Repeat(" ", 4)
	tokenStack := DataTypePythonLikeList{DataTypePythonLikeDict{"type": "value", "value": anything, "indentationLevel": 0}}

	var result DataTypeAny = ""
	for (len(tokenStack) > 0) {
		current := tokenStack[len(tokenStack)-1]
		tokenStack = tokenStack[:len(tokenStack)-1]
		currentValue := current.(DataTypePythonLikeDict)["value"]

		if (current.(DataTypePythonLikeDict)["type"] == "raw") {
			result = result.(string) + currentValue.(string)
			continue
		}

		currentIndentationLevel := current.(DataTypePythonLikeDict)["indentationLevel"].(int)
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
			if (len(currentValue.(DataTypePythonLikeList)) == 0) {
				result = (result.(string) + "[]")
				continue
			}
			childIndentationLevel := (currentIndentationLevel + 1)
			tokenStack = append(tokenStack, DataTypePythonLikeDict{
				"type": "raw",
				"value": ternary((pretty == true), DataTypeJsLikeFunction(func(variadicArguments ...DataTypeAny) DataTypeAny {
					return ("\n" + strings.Repeat(indentation.(string), currentIndentationLevel) + "]")
				}), DataTypeJsLikeFunction(func(variadicArguments ...DataTypeAny) DataTypeAny {
					return "]"
				})),
				"indentationLevel": currentIndentationLevel,
			})
			for i := (len(currentValue.(DataTypePythonLikeList)) - 1); (i >= 0); i = (i - 1) {
				tokenStack = append(tokenStack, DataTypePythonLikeDict{
					"type": "value",
					"value": currentValue.(DataTypePythonLikeList)[i],
					"indentationLevel": childIndentationLevel,
				})
				if (i > 0) {
					tokenStack = append(tokenStack, DataTypePythonLikeDict{
						"type": "raw",
						"value": ternary((pretty == true), DataTypeJsLikeFunction(func(variadicArguments ...DataTypeAny) DataTypeAny {
							return (",\n" + strings.Repeat(indentation.(string), childIndentationLevel))
						}), DataTypeJsLikeFunction(func(variadicArguments ...DataTypeAny) DataTypeAny {
							return ", "
						})),
						"indentationLevel": childIndentationLevel,
					})
				}
			}
			tokenStack = append(tokenStack, DataTypePythonLikeDict{
				"type": "raw",
				"value": ternary((pretty == true), DataTypeJsLikeFunction(func(variadicArguments ...DataTypeAny) DataTypeAny {
					return ("[\n" + strings.Repeat(indentation.(string), childIndentationLevel))
				}), DataTypeJsLikeFunction(func(variadicArguments ...DataTypeAny) DataTypeAny {
					return "["
				})),
				"indentationLevel": childIndentationLevel,
			})
			continue
		}
		if (currentValueType == JsonType["PythonLikeDict"]) {
			if (len(currentValue.(DataTypePythonLikeDict)) == 0) {
				result = (result.(string) + "{}")
				continue
			}
			childIndentationLevel := (currentIndentationLevel + 1)
			tokenStack = append(tokenStack, DataTypePythonLikeDict{
				"type": "raw",
				"value": ternary((pretty == true), DataTypeJsLikeFunction(func(variadicArguments ...DataTypeAny) DataTypeAny {
					return ("\n" + strings.Repeat(indentation.(string), currentIndentationLevel) + "}")
				}), DataTypeJsLikeFunction(func(variadicArguments ...DataTypeAny) DataTypeAny {
					return " }"
				})),
				"indentationLevel": currentIndentationLevel,
			})
			pythonLikeDictEntryIndex := 0
			for pythonLikeDictKey, pythonLikeDictValue := range currentValue.(DataTypePythonLikeDict) {
				tokenStack = append(tokenStack, DataTypePythonLikeDict{
					"type": "value",
					"value": pythonLikeDictValue,
					"indentationLevel": childIndentationLevel,
				})
				tokenStack = append(tokenStack, DataTypePythonLikeDict{
					"type": "raw",
					"value": ("\"" + pythonLikeDictKey + "\": "),
					"indentationLevel": childIndentationLevel,
				})
				if ((pythonLikeDictEntryIndex + 1) != len(currentValue.(DataTypePythonLikeDict))) {
					tokenStack = append(tokenStack, DataTypePythonLikeDict{
						"type": "raw",
						"value": ternary((pretty == true), DataTypeJsLikeFunction(func(variadicArguments ...DataTypeAny) DataTypeAny {
							return (",\n" + strings.Repeat(indentation.(string), childIndentationLevel))
						}), DataTypeJsLikeFunction(func(variadicArguments ...DataTypeAny) DataTypeAny {
							return ", "
						})),
						"indentationLevel": childIndentationLevel,
					})
				}
				pythonLikeDictEntryIndex += 1
			}
			tokenStack = append(tokenStack, DataTypePythonLikeDict{
				"type": "raw",
				"value": ternary((pretty == true), DataTypeJsLikeFunction(func(variadicArguments ...DataTypeAny) DataTypeAny {
					return ("{\n" + strings.Repeat(indentation.(string), childIndentationLevel))
				}), DataTypeJsLikeFunction(func(variadicArguments ...DataTypeAny) DataTypeAny {
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

func parseFloat(variadicArguments ...DataTypeAny) DataTypeAny {
	anything := variadicArguments[0]
	switch anyGoType := anything.(type) {
	case DataTypeJsLikeFloat:
		return anyGoType
	case complex128:
		return DataTypeJsLikeFloat(real(anyGoType))
	case complex64:
		return DataTypeJsLikeFloat(real(complex128(anyGoType)))
	case float64:
		return DataTypeJsLikeFloat(anyGoType)
	case float32:
		return DataTypeJsLikeFloat(anyGoType)
	case int64:
		return DataTypeJsLikeFloat(anyGoType)
	case int32: // rune
		return DataTypeJsLikeFloat(anyGoType)
	case int16:
		return DataTypeJsLikeFloat(anyGoType)
	case int8:
		return DataTypeJsLikeFloat(anyGoType)
	case int:
		return DataTypeJsLikeFloat(anyGoType)
	case uint64:
		return DataTypeJsLikeFloat(anyGoType)
	case uint32:
		return DataTypeJsLikeFloat(anyGoType)
	case uint16:
		return DataTypeJsLikeFloat(anyGoType)
	case uint8: // byte
		return DataTypeJsLikeFloat(anyGoType)
	case uint:
		return DataTypeJsLikeFloat(anyGoType)
	default:
		return errors.New("expecting float64-convertible Go value")
	}
}

func parseInt(variadicArguments ...DataTypeAny) DataTypeAny {
	anything := variadicArguments[0]
	switch anyGoType := anything.(type) {
	case DataTypeJsLikeInt:
		return anyGoType
	case complex128:
		return DataTypeJsLikeInt(real(anyGoType))
	case complex64:
		return DataTypeJsLikeInt(real(complex128(anyGoType)))
	case float64:
		return DataTypeJsLikeInt(anyGoType)
	case float32:
		return DataTypeJsLikeInt(anyGoType)
	case int64:
		return DataTypeJsLikeInt(anyGoType)
	case int32: // rune
		return DataTypeJsLikeInt(anyGoType)
	case int16:
		return DataTypeJsLikeInt(anyGoType)
	case int8:
		return DataTypeJsLikeInt(anyGoType)
	case int:
		return DataTypeJsLikeInt(anyGoType)
	case uint64:
		return DataTypeJsLikeInt(anyGoType)
	case uint32:
		return DataTypeJsLikeInt(anyGoType)
	case uint16:
		return DataTypeJsLikeInt(anyGoType)
	case uint8: // byte
		return DataTypeJsLikeInt(anyGoType)
	case uint:
		return DataTypeJsLikeInt(anyGoType)
	default:
		return errors.New("expecting int-convertible Go value")
	}
}

var Utils = struct {
    Ternary func(...DataTypeAny) DataTypeAny
	GetIsAnyItemInListMatchingCondition func(...DataTypeAny) DataTypeAny
	GetIsJsLikeNull func(...DataTypeAny) DataTypeAny
	GetIsJsLikeBoolean func(...DataTypeAny) DataTypeAny
	GetIsJsLikeString func(...DataTypeAny) DataTypeAny
	GetIsJsLikeInt func(...DataTypeAny) DataTypeAny
	GetIsJsLikeFloat func(...DataTypeAny) DataTypeAny
	GetIsPythonLikeDict func(...DataTypeAny) DataTypeAny
	GetIsPythonLikeList func(...DataTypeAny) DataTypeAny
	GetIsJsLikeFunction func(...DataTypeAny) DataTypeAny
	GetType func(...DataTypeAny) DataTypeAny
	GetStringValueOfPrimitive func(...DataTypeAny) DataTypeAny
	CombineAllListItem func(...DataTypeAny) DataTypeAny
	Pipe func(...DataTypeAny) DataTypeAny
	ParseFloat func(...DataTypeAny) DataTypeAny
	JsonStringify func(...DataTypeAny) DataTypeAny
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