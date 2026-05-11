package main

import (
    "fmt"
    "cross-language-programming-concepts/runtimes/go/willyhorizont"
)

func main() {
    fmt.Println(willyhorizont.Utils.IsNull(nil))
    // fmt.Println(Utils.IsNull(nil)) // this should not work
}