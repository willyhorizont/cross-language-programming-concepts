import scala.collection.mutable

@main def apply(): Unit = {
    println("Hello, World!")

    var something: Any = null
    // something = undefined // TODO
    // println(something)
    something = null
    println(something)
    something = true
    println(something)
    something = false
    println(something)
    something = "foo"
    println(something)
    something = 123
    println(something)
    something = 123.789
    println(something)
    something = -123
    println(something)
    something = -123.789
    println(something)
    something = mutable.ArrayBuffer[Any](1, 2, 3)
    println(something)
    something = mutable.Map[String, Any]("foo".asInstanceOf[String] -> "bar".asInstanceOf[Any])
    println(something)
    // something = /*javascript (a, b) => (a * b) */ // TODO
    // println(something(7, 5))
}