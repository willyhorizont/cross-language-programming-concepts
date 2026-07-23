import std/tables
import std/strutils

type Types* {.pure.} = enum
    None,
    Bool,
    String,
    Int,
    Float,
    List,
    Dict,
    Lambda

type Type* = object
    case kind*: Types
    of Types.None: discard
    of Types.Bool: boolValue*: bool
    of Types.String: stringValue*: string
    of Types.Int: intValue*: int
    of Types.Float: floatValue*: float
    of Types.List: listValue*: seq[Type]
    of Types.Dict: dictValue*: Table[string, Type]
    of Types.Lambda: lambdaValue*: proc (args: Type): Type {.closure.}

type Iterator = proc (): Type {.closure.}

proc toBool*(self: Type): bool =
  if self.kind == Types.Bool:
    return self.boolValue
  raise newException(ValueError, "XlError: Expected Bool, got " & $self.kind)

proc toString*(self: Type): string =
  if self.kind == Types.String:
    return self.stringValue
  raise newException(ValueError, "XlError: Expected String, got " & $self.kind)

proc toInt*(self: Type): int =
  if self.kind == Types.Int:
    return self.intValue
  raise newException(ValueError, "XlError: Expected Int, got " & $self.kind)

proc toFloat*(self: Type): float =
  if self.kind == Types.Float:
    return self.floatValue
  raise newException(ValueError, "XlError: Expected Float, got " & $self.kind)

proc toList*(self: Type): seq[Type] =
  if self.kind == Types.List:
    return self.listValue
  raise newException(ValueError, "XlError: Expected List, got " & $self.kind)

proc init*(v: bool): Type = Type(kind: Types.Bool, boolValue: v)
proc init*(v: string): Type = Type(kind: Types.String, stringValue: v)
proc init*(v: int): Type = Type(kind: Types.Int, intValue: v)
proc init*(v: float): Type = Type(kind: Types.Float, floatValue: v)
proc init*(v: seq[Type]): Type = Type(kind: Types.List, listValue: v)
proc init*(v: Table[string, Type]): Type = Type(kind: Types.Dict, dictValue: v)
proc init*(v: proc (args: Type): Type {.closure.}): Type = Type(kind: Types.Lambda, lambdaValue: v)
proc init*(t: Type): Type = t
let none* = Type(kind: Types.None)

proc iter*(a: Type): Iterator =
  let itr = iterator(): Type {.closure.} =
    for el in a.toList():
      yield el
  return proc (): Type {.closure.} =
    if finished(itr):
      return none
    return itr()

proc next*(self: Iterator): Type =
  return self()

proc call*(self: Type, va: varargs[Type, init]): Type =
  if self.kind == Types.Lambda:
    return self.lambdaValue(Type(kind: Types.List, listValue: @va))
  raise newException(ValueError, "XlError: Expected Lambda, got " & $self.kind)

proc `$`*(self: Type): string =
  case self.kind:
  of Types.None: "None"
  of Types.Bool: $self.boolValue
  of Types.String: '"' & self.stringValue & '"'
  of Types.Int: $self.intValue
  of Types.Float: $self.floatValue
  of Types.List:
    var l: seq[string] = @[]
    for x in self.listValue: l.add($x)
    "[" & l.join(", ") & "]"
  of Types.Dict:
    var dpl: seq[string] = @[]
    for k, v in self.dictValue.pairs: dpl.add(k & ": " & $v)
    "{" & dpl.join(", ") & "}"
  of Types.Lambda: "\"[object Function]\""

proc escapeString*(s: string): string =
  if s.len == 0:
    return ""
  var r = s
  r = r.replace("\\", "\\\\")
  r = r.replace("\"", "\\\"")
  r = r.replace("\n", "\\n")
  r = r.replace("\r", "\\r")
  r = r.replace("\t", "\\t")
  return r

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
    of Types.None:
      r.add("null")
      continue
    of Types.Bool:
      r.add((if v.boolValue: "true" else: "false"))
      continue
    of Types.String:
      r.add("\"" & escapeString(v.stringValue) & "\"")
      continue
    of Types.Int:
      r.add($v.intValue)
      continue
    of Types.Float:
      r.add($v.floatValue)
      continue
    of Types.Lambda:
      r.add("\"[object Function]\"")
      continue
    of Types.List:
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
    of Types.Dict:
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
