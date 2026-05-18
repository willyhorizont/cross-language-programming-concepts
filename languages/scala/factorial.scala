@main def apply(): Unit = {
    val factorialRec = (
        (number: Int) => (
            (
                (fn: ((List[Int]) => BigInt) => ((List[Int]) => BigInt)) => (((self: Any) => (fn((argumentsList: List[Int]) => (self.asInstanceOf[Any => (List[Int] => BigInt)](self)(argumentsList)))))((self: Any) => (fn((argumentsList: List[Int]) => (self.asInstanceOf[Any => (List[Int] => BigInt)](self)(argumentsList))))))
            )(
                (factorialFunction: (List[Int]) => BigInt) => ((argumentsList: List[Int]) => (if (argumentsList(0) == 0) BigInt(argumentsList(1)) else factorialFunction(List((argumentsList(0) - 1), (argumentsList(1) * argumentsList(0))))))
            )
        )(List(number, 1))
    )

    println(factorialRec(5))

    @annotation.tailrec
    def factorial(
        number: BigInt,
        accumulator: BigInt = 1
    ): BigInt = {

        if (number == 0)
            accumulator
        else
            factorial(
                number - 1,
                accumulator * number
            )
    }
    println(factorial(100000))
}