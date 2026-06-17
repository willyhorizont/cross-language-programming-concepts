import std/tables
import std/strformat
import willyhorizont/runtime

let sayHello = (proc (getNextArguments: proc (): DynamicType {.closure.}): DynamicType {.closure.} =
  let callbackFunction = getNextArguments()
  echo "hello"
  discard callbackFunction.call() 
).toDynamicType
discard sayHello.call((proc (getNextArguments: proc (): DynamicType {.closure.}): DynamicType {.closure.} =
  echo "world"
).toDynamicType)
let createMultiplier = (proc (getNextArguments: proc (): DynamicType {.closure.}): DynamicType {.closure.} =
  let aa = getNextArguments().dynamicTypeIntValue
  return (proc (getNextArguments: proc (): DynamicType {.closure.}): DynamicType {.closure.} =
    let bb = getNextArguments().dynamicTypeIntValue
    return (aa * bb).toDynamicType
  ).toDynamicType
).toDynamicType
let multiplyByTwo = createMultiplier.call(2)
echo fmt"multiply_by_two(10): {multiplyByTwo.call(10).dynamicTypeIntValue}"
let multiplyByEight = createMultiplier.call(8)
echo fmt"multiply_by_eight(4): {multiplyByEight.call(4).dynamicTypeIntValue}"
echo fmt"multiply_by_two(8): {multiplyByTwo.call(8).dynamicTypeIntValue}"

let somePyList = @[
  nimNone,
  true.toDynamicType,
  false.toDynamicType,
  "foo".toDynamicType,
  123.toDynamicType,
  (-123).toDynamicType,
  123.789.toDynamicType,
  (-123.789).toDynamicType,
  @[1.toDynamicType, 2.toDynamicType, 3.toDynamicType].toDynamicType,
  {"foo": "bar".toDynamicType}.toOrderedTable.toDynamicType,
  (proc (getNextArguments: proc (): DynamicType {.closure.}): DynamicType {.closure.} =
    let aa = getNextArguments().dynamicTypeIntValue
    let bb = getNextArguments().dynamicTypeIntValue
    return (aa * bb).toDynamicType
  ).toDynamicType
].toDynamicType
echo "some_list: " & @[somePyList, {"pretty": true.toDynamicType}.toOrderedTable.toDynamicType].toDynamicType.jsonStringifyVersionTwo()
let somePyDict = {
  "some_null": nimNone,
  "some_boolean_true": true.toDynamicType,
  "some_boolean_false": false.toDynamicType,
  "some_string": "foo".toDynamicType,
  "some_int_positive": 123.toDynamicType,
  "some_int_negative": (-123).toDynamicType,
  "some_float_positive": 123.789.toDynamicType,
  "some_float_negative": (-123.789).toDynamicType,
  "some_list": @[1.toDynamicType, 2.toDynamicType, 3.toDynamicType].toDynamicType,
  "some_dict": {"foo": "bar".toDynamicType}.toOrderedTable.toDynamicType,
  "some_function": (proc (getNextArguments: proc (): DynamicType {.closure.}): DynamicType {.closure.} =
      let aa = getNextArguments().dynamicTypeIntValue
      let bb = getNextArguments().dynamicTypeIntValue
      return (aa * bb).toDynamicType
    ).toDynamicType
}.toOrderedTable.toDynamicType
echo "some_dict: " & @[somePyDict, {"pretty": true.toDynamicType}.toOrderedTable.toDynamicType].toDynamicType.jsonStringifyVersionTwo()
