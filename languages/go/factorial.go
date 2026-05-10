package main

import (
    "fmt"
    "cross-language-programming-concepts/utils"
)

func main() {
    fmt.Println("Hello, World!")
    fmt.Println(utils.Multiply(2, 3))

	var something interface{}
	something = "foo"
    fmt.Println(utils.GetType(something))
    something = 123
    fmt.Println(utils.GetType(something))
    something = 123.789
    fmt.Println(utils.GetType(something))
    something = -123
    fmt.Println(utils.GetType(something))
    something = -123.789
    fmt.Println(utils.GetType(something))
    something = true
    fmt.Println(utils.GetType(something))
    something = false
    fmt.Println(utils.GetType(something))
    something = nil
    fmt.Println(utils.GetType(something))
    something = []interface{}{1, 2, 3}
    fmt.Println(utils.GetType(something))
    something = map[string]interface{}{"foo": "bar"}
    fmt.Println(utils.GetType(something))
}