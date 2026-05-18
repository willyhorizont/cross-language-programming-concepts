package types

type Any interface{}
type PythonLikeList []Any
type PythonLikeDict map[string]Any
type JsLikeFunction func(...Any) Any

var AnyType = struct {
	JsLikeUndefined string
	JsLikeNull string
	JsLikeBoolean string
	JsLikeString string
	JsLikeInt string
	JsLikeFloat string
	PythonLikeDict string
	PythonLikeList string
	JsLikeFunction string
}{
	JsLikeUndefined: "JsLikeUndefined",
	JsLikeNull: "JsLikeNull",
	JsLikeBoolean: "JsLikeBoolean",
	JsLikeString: "JsLikeString",
	JsLikeInt: "JsLikeInt",
	JsLikeFloat: "JsLikeFloat",
	PythonLikeDict: "PythonLikeDict",
	PythonLikeList: "PythonLikeList",
	JsLikeFunction: "JsLikeFunction",
}