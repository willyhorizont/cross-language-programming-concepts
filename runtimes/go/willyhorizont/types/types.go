package types

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