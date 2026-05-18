package willyhorizont

import (
	"cross-language-programming-concepts/runtimes/go/willyhorizont/utils"
	"cross-language-programming-concepts/runtimes/go/willyhorizont/types"
)

type any = types.Any
type pythonLikeList = types.PythonLikeList
type pythonLikeDict = types.PythonLikeDict
type jsLikeFunction = types.JsLikeFunction

var Utils = struct {
    Ternary func(bool, jsLikeFunction, jsLikeFunction) any
	ArraySome func(func(...any) bool, any) bool
	CheckIsJsLikeUndefined func(any) bool
	CheckIsJsLikeNull func(any) bool
	CheckIsJsLikeBoolean func(any) bool
	CheckIsJsLikeString func(any) bool
	CheckIsJsLikeInt func(any) bool
	CheckIsJsLikeFloat func(any) bool
	CheckIsPythonLikeDict func(any) bool
	CheckIsPythonLikeList func(any) bool
	CheckIsJsLikeFunction func(any) bool
	GetType func(any) string
	ParseFloat func(any) any
}{
    Ternary: utils.Ternary,
    ArraySome: utils.ArraySome,
    CheckIsJsLikeUndefined: utils.CheckIsJsLikeUndefined,
    CheckIsJsLikeNull: utils.CheckIsJsLikeNull,
	CheckIsJsLikeBoolean: utils.CheckIsJsLikeBoolean,
	CheckIsJsLikeString: utils.CheckIsJsLikeString,
	CheckIsJsLikeInt: utils.CheckIsJsLikeInt,
	CheckIsJsLikeFloat: utils.CheckIsJsLikeFloat,
	CheckIsPythonLikeDict: utils.CheckIsPythonLikeDict,
	CheckIsPythonLikeList: utils.CheckIsPythonLikeList,
	CheckIsJsLikeFunction: utils.CheckIsJsLikeFunction,
	GetType: utils.GetType,
	ParseFloat: utils.ParseFloat,
}