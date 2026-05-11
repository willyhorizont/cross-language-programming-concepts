package willyhorizont

import (
	"cross-language-programming-concepts/runtimes/go/willyhorizont/utils"
)

type JsLikeAny = utils.JsLikeAny
type JsLikeArray = utils.JsLikeArray
type JsLikeObject = utils.JsLikeObject
type JsLikeFunction = utils.JsLikeFunction

var JsLikeUndefined = utils.JsLikeUndefined
var JsLikeType = utils.JsLikeType

var Utils = struct {
    Ternary func(bool, JsLikeFunction, JsLikeFunction) JsLikeAny
	ArraySome func(func(...JsLikeAny) bool, JsLikeAny) bool
	CheckIsLikeJsUndefined func(JsLikeAny) bool
	CheckIsLikeJsNull func(JsLikeAny) bool
	CheckIsLikeJsBoolean func(JsLikeAny) bool
	CheckIsLikeJsString func(JsLikeAny) bool
	CheckIsLikeJsInt func(JsLikeAny) bool
	CheckIsLikeJsFloat func(JsLikeAny) bool
	CheckIsLikeJsObject func(JsLikeAny) bool
	CheckIsLikeJsArray func(JsLikeAny) bool
	CheckIsLikeJsFunction func(JsLikeAny) bool
	GetJsLikeType func(JsLikeAny) string
	ParseFloat func(JsLikeAny) JsLikeAny
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