package willyhorizont

import (
	"cross-language-programming-concepts/runtimes/go/willyhorizont/utils"
)

var Utils = struct {
    Ternary func(bool, interface{}, interface{}) interface{}
    IsNull  func(interface{}) bool
}{
    Ternary: utils.Ternary,
    IsNull:  utils.IsNull,
}