package willyhorizont

import (
	"cross-language-programming-concepts/runtimes/go/willyhorizont/utils"
	"cross-language-programming-concepts/runtimes/go/willyhorizont/types"
)

type jsLikeAny = types.JsLikeAny
type jsLikeArray = types.JsLikeArray
type jsLikeObject = types.JsLikeObject
type jsLikeFunction = types.JsLikeFunction

var Utils = struct {
    Ternary func(bool, jsLikeFunction, jsLikeFunction) jsLikeAny
	ArraySome func(func(...jsLikeAny) bool, jsLikeAny) bool
	CheckIsLikeJsUndefined func(jsLikeAny) bool
	CheckIsLikeJsNull func(jsLikeAny) bool
	CheckIsLikeJsBoolean func(jsLikeAny) bool
	CheckIsLikeJsString func(jsLikeAny) bool
	CheckIsLikeJsInt func(jsLikeAny) bool
	CheckIsLikeJsFloat func(jsLikeAny) bool
	CheckIsLikeJsObject func(jsLikeAny) bool
	CheckIsLikeJsArray func(jsLikeAny) bool
	CheckIsLikeJsFunction func(jsLikeAny) bool
	GetJsLikeType func(jsLikeAny) string
	ParseFloat func(jsLikeAny) jsLikeAny
}{
    Ternary: utils.Ternary,
    ArraySome: utils.ArraySome,
    CheckIsLikeJsUndefined: utils.CheckIsLikeJsUndefined,
    CheckIsLikeJsNull: utils.CheckIsLikeJsNull,
	CheckIsLikeJsBoolean: utils.CheckIsLikeJsBoolean,
	CheckIsLikeJsString: utils.CheckIsLikeJsString,
	CheckIsLikeJsInt: utils.CheckIsLikeJsInt,
	CheckIsLikeJsFloat: utils.CheckIsLikeJsFloat,
	CheckIsLikeJsObject: utils.CheckIsLikeJsObject,
	CheckIsLikeJsArray: utils.CheckIsLikeJsArray,
	CheckIsLikeJsFunction: utils.CheckIsLikeJsFunction,
	GetJsLikeType: utils.GetJsLikeType,
	ParseFloat: utils.ParseFloat,
}