import std/tables
import std/strutils

type
  Types* = enum
    None,
    Bool,
    String,
    Int,
    Float,
    List,
    Dict,
    Closure
  Type* = object
    case kind*: Types
    of None: discard
    of Bool: boolValue*: bool
    of String: stringValue*: string
    of Int: intValue*: int
    of Float: floatValue*: float
    of List: listValue*: seq[Type]
    of Dict: dictValue*: OrderedTable[string, Type] 
    of Closure: closureValue*: proc (args: seq[Type]): Type {.closure.}

type Iterator* = proc (): Type {.closure.}

proc init*(v: bool): Type = Type(kind: Bool, boolValue: v)
proc init*(v: string): Type = Type(kind: String, stringValue: v)
proc init*(v: int): Type = Type(kind: Int, intValue: v)
proc init*(v: float): Type = Type(kind: Float, floatValue: v)
proc init*(v: seq[Type]): Type = Type(kind: List, listValue: v)
proc init*(v: OrderedTable[string, Type]): Type = Type(kind: Dict, dictValue: v)
proc init*(v: proc (args: seq[Type]): Type {.closure.}): Type = Type(kind: Closure, closureValue: v)
proc init*(t: Type): Type = t
let none* = Type(kind: None)

proc iter*(l: seq[Type]): Iterator =
  let itr = iterator(): Type {.closure.} =
    for el in l:
      yield el
  return proc (): Type {.closure.} =
    if finished(itr):
      return none
    return itr()

proc next*(self: Iterator): Type =
  return self()

proc call*(self: Type, va: varargs[Type, init]): Type =
  if self.kind == Closure:
    return self.closureValue(@va)
  raise newException(ValueError, "XlError: Expected Closure, got " & $self.kind)

proc `$`*(self: Type): string =
  case self.kind:
  of None: "None"
  of Bool: $self.boolValue
  of String: '"' & self.stringValue & '"'
  of Int: $self.intValue
  of Float: $self.floatValue
  of List:
    var items: seq[string] = @[]
    for x in self.listValue: items.add($x)
    "[" & items.join(", ") & "]"
  of Dict:
    var pairs: seq[string] = @[]
    for k, v in self.dictValue.pairs: pairs.add(k & ": " & $v)
    "{" & pairs.join(", ") & "}"
  of Closure: "\"[object Function]\""

proc toBool*(self: Type): bool =
  if self.kind == Bool: return self.boolValue
  raise newException(ValueError, "XlError: Expected Bool, got " & $self.kind)

proc toString*(self: Type): string =
  if self.kind == String: return self.stringValue
  raise newException(ValueError, "XlError: Expected String, got " & $self.kind)

proc toInt*(self: Type): int =
  if self.kind == Int: return self.intValue
  raise newException(ValueError, "XlError: Expected Int, got " & $self.kind)

proc toFloat*(self: Type): float =
  if self.kind == Float: return self.floatValue
  raise newException(ValueError, "XlError: Expected Float, got " & $self.kind)

proc jsonStringify*(a: Type, pretty: bool = false): string =
  let p = pretty
  let t = repeat(" ", 4)
  type 
    T = object
      t: string
      v: Type
      r: string
      d: int
  var s: seq[T] = @[]
  var r = ""
  s.add(T(t: "v", v: a, d: 0))
  while s.len > 0:
    let c = s.pop()
    if c.t == "r":
      r.add(c.r)
      continue
    let v = c.v
    let curD = c.d
    case v.kind:
    of None:
      r.add("null")
      continue
    of Bool:
      r.add((if v.boolValue: "true" else: "false"))
      continue
    of String:
      r.add("\"" & v.stringValue & "\"")
      continue
    of Int:
      r.add($v.intValue)
      continue
    of Float:
      r.add($v.floatValue)
      continue
    of Closure:
      r.add("\"[object Function]\"")
      continue
    of List:
      if v.listValue.len == 0:
        r.add("[]")
        continue
      let childD = curD + 1
      s.add(T(
        t: "r",
        r: (if p: "\n" & repeat(t, curD) & "]" else: "]"), 
        d: curD
      ))
      for i in countdown(v.listValue.len - 1, 0):
        s.add(T(
          t: "v",
          v: v.listValue[i],
          d: childD
        ))
        if i > 0:
          s.add(T(
            t: "r", 
            r: (if p: ",\n" & repeat(t, childD) else: ","), 
            d: childD
          ))
      s.add(T(
        t: "r", 
        r: (if p: "[\n" & repeat(t, childD) else: "["), 
        d: childD
      ))
      continue
    of Dict:
      if v.dictValue.len == 0:
        r.add("{}")
        continue
      let childD = curD + 1
      s.add(T(
        t: "r", 
        r: (if p: "\n" & repeat(t, curD) & "}" else: "}"), 
        d: curD
      ))
      var dpL: seq[tuple[key: string, v: Type]] = @[]
      for dpK, dpV in v.dictValue.pairs:
        dpL.add((dpK, dpV))
      for i in countdown(dpL.len - 1, 0):
        let (dK, dV) = dpL[i]
        s.add(T(
          t: "v",
          v: dV,
          d: childD
        ))
        s.add(T(
          t: "r", 
          r: (if p: "\"" & dK & "\": " else: "\"" & dK & "\":"), 
          d: childD
        ))
        if i > 0:
          s.add(T(
            t: "r", 
            r: (if p: ",\n" & repeat(t, childD) else: ","), 
            d: childD
          ))
      s.add(T(
        t: "r", 
        r: (if p: "{\n" & repeat(t, childD) else: "{"), 
        d: childD
      ))
      continue
    else:
      {.warning[UnreachableElse]: off.}
      r.add("\"[object Nim Object]\"")
      continue
  return r
