import std/tables
import std/strformat
import willyhorizont/runtime as Xl

let sayHello = Xl.init(proc (args: seq[Xl.Type]): Xl.Type {.closure.} =
  let itr = Xl.iter(args)
  let callbackFunction = itr.next()
  echo "hello"
  discard callbackFunction.call() 
)
discard sayHello.call(Xl.init(proc (args: seq[Xl.Type]): Xl.Type {.closure.} =
  echo "world"
))
let createMultiplier = Xl.init(proc (args: seq[Xl.Type]): Xl.Type {.closure.} =
  let itr = Xl.iter(args)
  let aa = itr.next().toInt()
  return Xl.init(proc (args: seq[Xl.Type]): Xl.Type {.closure.} =
    let itr = Xl.iter(args)
    let bb = itr.next().toInt()
    return Xl.init(aa * bb)
  )
)
let multiplyByTwo = createMultiplier.call(2)
echo fmt"multiply_by_two(10): {multiplyByTwo.call(10).toInt()}"
let multiplyByEight = createMultiplier.call(8)
echo fmt"multiply_by_eight(4): {multiplyByEight.call(4).toInt()}"
echo fmt"multiply_by_two(8): {multiplyByTwo.call(8).toInt()}"

let xlList = Xl.init(@[
  Xl.none,
  Xl.init(true),
  Xl.init(false),
  Xl.init("foo"),
  Xl.init(123),
  Xl.init(-123),
  Xl.init(123.789),
  Xl.init(-123.789),
  Xl.init(@[Xl.init(1), Xl.init(2), Xl.init(3)]),
  Xl.init(toOrderedTable({"foo": Xl.init("bar")})),
  Xl.init(proc (args: seq[Xl.Type]): Xl.Type {.closure.} =
    let itr = Xl.iter(args)
    let aa = itr.next().toInt()
    let bb = itr.next().toInt()
    return Xl.init(aa * bb)
  ),
])
echo fmt"xl_list: {jsonStringify(xlList)}"
echo fmt"xl_list: {jsonStringify(xlList, pretty = true)}"
let xlDict = Xl.init(toOrderedTable({
  "xl_none": Xl.none,
  "xl_bool_true": Xl.init(true),
  "xl_bool_false": Xl.init(false),
  "xl_string": Xl.init("foo"),
  "xl_int_positive": Xl.init(123),
  "xl_int_negative": Xl.init(-123),
  "xl_float_positive": Xl.init(123.789),
  "xl_float_negative": Xl.init(-123.789),
  "xl_list": Xl.init(@[Xl.init(1), Xl.init(2), Xl.init(3)]),
  "xl_dict": Xl.init(toOrderedTable({"foo": Xl.init("bar")})),
  "xl_closure": Xl.init(proc (args: seq[Xl.Type]): Xl.Type {.closure.} =
    let itr = Xl.iter(args)
    let aa = itr.next().toInt()
    let bb = itr.next().toInt()
    return Xl.init(aa * bb)
  ),
}))
echo fmt"xl_dict: {jsonStringify(xlDict)}"
echo fmt"xl_dict: {jsonStringify(xlDict, pretty = true)}"
