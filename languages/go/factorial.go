package main

import (
    "fmt"
    "cross-language-programming-concepts/runtimes/go/willyhorizont"
)

func factorial(n int) int {
    if n <= 1 {
        return 1
    }
    return n * factorial(n-1)
}

func main() {
    fmt.Println(factorial(5))

    fmt.Println(willyhorizont.Utils.Ternary(true, 100, 200))
}