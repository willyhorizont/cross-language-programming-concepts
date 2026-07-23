import std/tables
import std/strformat
import willyhorizont/runtime/xl

#[
1. support lambda as value, or has workaround
]#
let sayHello = xl.init(proc (args: xl.Type): xl.Type {.closure.} =
  let itr = xl.iter(args)
  let callbackFunction = itr.next()
  echo "hello"
  discard callbackFunction.call()
)
discard sayHello.call(xl.init(proc (args: xl.Type): xl.Type {.closure.} =
  echo "world"
))
let createMultiplier = xl.init(proc (args: xl.Type): xl.Type {.closure.} =
  let itr = xl.iter(args)
  let aa = itr.next().toInt()
  return xl.init(proc (args: xl.Type): xl.Type {.closure.} =
    let itr = xl.iter(args)
    let bb = itr.next().toInt()
    return xl.init(aa * bb)
  )
)
let multiplyByTwo = createMultiplier.call(2)
echo fmt"multiply_by_two(10): {multiplyByTwo.call(10).toInt()}"
let multiplyByEight = createMultiplier.call(8)
echo fmt"multiply_by_eight(4): {multiplyByEight.call(4).toInt()}"
echo fmt"multiply_by_two(8): {multiplyByTwo.call(8).toInt()}"

#[
2. support dynamic-typed value, or has workaround
]#
let xlList = xl.init(@[
  xl.none,
  xl.init(true),
  xl.init(false),
  xl.init("foo"),
  xl.init(123),
  xl.init(-123),
  xl.init(123.789),
  xl.init(-123.789),
  xl.init(@[xl.init(1), xl.init(2), xl.init(3)]),
  xl.init(toTable({"foo": xl.init("bar")})),
  xl.init(proc (args: xl.Type): xl.Type {.closure.} =
    let itr = xl.iter(args)
    let aa = itr.next().toInt()
    let bb = itr.next().toInt()
    return xl.init(aa * bb)
  ),
])
echo fmt"xl_list: {jsonStringify(xlList)}"
echo fmt"xl_list: {jsonStringify(xlList, pretty = true)}"
let xlDict = xl.init(toTable({
  "xl_none": xl.none,
  "xl_bool_true": xl.init(true),
  "xl_bool_false": xl.init(false),
  "xl_string": xl.init("foo"),
  "xl_int_positive": xl.init(123),
  "xl_int_negative": xl.init(-123),
  "xl_float_positive": xl.init(123.789),
  "xl_float_negative": xl.init(-123.789),
  "xl_list": xl.init(@[xl.init(1), xl.init(2), xl.init(3)]),
  "xl_dict": xl.init(toTable({"foo": xl.init("bar")})),
  "xl_lambda": xl.init(proc (args: xl.Type): xl.Type {.closure.} =
    let itr = xl.iter(args)
    let aa = itr.next().toInt()
    let bb = itr.next().toInt()
    return xl.init(aa * bb)
  ),
}))
echo fmt"xl_dict: {jsonStringify(xlDict)}"
echo fmt"xl_dict: {jsonStringify(xlDict, pretty = true)}"
