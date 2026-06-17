import std/tables

type
  DynamicTypeKeys* = enum
    dynamicTypeKeyNone,
    dynamicTypeKeyBool,
    dynamicTypeKeyString,
    dynamicTypeKeyInt,
    dynamicTypeKeyFloat,
    dynamicTypeKeyList,
    dynamicTypeKeyDict,
    dynamicTypeKeyClosure
  DynamicType* = object
    case kind*: DynamicTypeKeys
    of dynamicTypeKeyNone: discard
    of dynamicTypeKeyBool: dynamicTypeBoolValue*: bool
    of dynamicTypeKeyString: dynamicTypeStringValue*: string
    of dynamicTypeKeyInt: dynamicTypeIntValue*: int
    of dynamicTypeKeyFloat: dynamicTypeFloatValue*: float
    of dynamicTypeKeyList: dynamicTypeListValue*: seq[DynamicType]
    of dynamicTypeKeyDict: dynamicTypeDictValue*: OrderedTable[string, DynamicType] 
    of dynamicTypeKeyClosure: dynamicTypeClosureValue*: proc (getNextArguments: proc (): DynamicType {.closure.}): DynamicType {.closure.}

proc toDynamicType*(nimTypeBoolValue: bool): DynamicType = DynamicType(kind: dynamicTypeKeyBool, dynamicTypeBoolValue: nimTypeBoolValue)
proc toDynamicType*(nimTypeStringValue: string): DynamicType = DynamicType(kind: dynamicTypeKeyString, dynamicTypeStringValue: nimTypeStringValue)
proc toDynamicType*(nimTypeIntValue: int): DynamicType = DynamicType(kind: dynamicTypeKeyInt, dynamicTypeIntValue: nimTypeIntValue)
proc toDynamicType*(nimTypeFloatValue: float): DynamicType = DynamicType(kind: dynamicTypeKeyFloat, dynamicTypeFloatValue: nimTypeFloatValue)
proc toDynamicType*(nimTypeListValue: seq[DynamicType]): DynamicType = DynamicType(kind: dynamicTypeKeyList, dynamicTypeListValue: nimTypeListValue)
proc toDynamicType*(nimTypeDictValue: OrderedTable[string, DynamicType]): DynamicType = DynamicType(kind: dynamicTypeKeyDict, dynamicTypeDictValue: nimTypeDictValue)
proc toDynamicType*(nimTypeClosureValue: proc (getNextArguments: proc (): DynamicType {.closure.}): DynamicType {.closure.}): DynamicType = DynamicType(kind: dynamicTypeKeyClosure, dynamicTypeClosureValue: nimTypeClosureValue)
proc toDynamicType*(dynamicType: DynamicType): DynamicType = dynamicType
let nimNone* = DynamicType(kind: dynamicTypeKeyNone)

proc createListIterator*(nimTypeListValueCopy: seq[DynamicType]): proc (): DynamicType {.closure.} =
  let listIterator = iterator(): DynamicType {.closure.} =
    for nimTypeListValueCopyItem in nimTypeListValueCopy:
      yield nimTypeListValueCopyItem
  return proc (): DynamicType {.closure.} =
    return listIterator()

proc call*(self: DynamicType, variadicArguments: varargs[DynamicType, toDynamicType]): DynamicType =
  if self.kind == dynamicTypeKeyClosure:
    var getNextArguments = createListIterator(@variadicArguments)
    return self.dynamicTypeClosureValue(getNextArguments)
  raise newException(ValueError, "Error: Can not call non-closure.")

type
  StackItemKind = enum
    stValue, stKey, stCloseList, stCloseDict, stComma

  StackItem = object
    case kind: StackItemKind
    of stValue: val: DynamicType
    of stKey: keyName: string
    of stCloseList, stCloseDict, stComma: discard

proc jsonStringifyVersionOne*(variadicArguments: DynamicType): string =
  let self = variadicArguments.dynamicTypeListValue[0]
  let pretty = variadicArguments.dynamicTypeListValue[1]
  # Shortcut untuk tipe primitif tunggal di root
  case self.kind
  of dynamicTypeKeyNone: return "null"
  of dynamicTypeKeyBool: return $self.dynamicTypeBoolValue
  of dynamicTypeKeyString: return "\"" & self.dynamicTypeStringValue & "\""
  of dynamicTypeKeyInt: return $self.dynamicTypeIntValue
  of dynamicTypeKeyFloat: return $self.dynamicTypeFloatValue
  of dynamicTypeKeyClosure: return "\"[object Function]\""
  else: discard

  result = ""
  var stack: seq[StackItem] = @[StackItem(kind: stValue, val: self)]

  while stack.len > 0:
    let curr = stack.pop()
    
    case curr.kind
    of stCloseList:
      result.add("]")
    of stCloseDict:
      result.add("}")
    of stComma:
      result.add(",")
    of stKey:
      # Cetak key string tepat sebelum nilainya diproses
      result.add("\"" & curr.keyName & "\":")
    of stValue:
      let item = curr.val
      case item.kind
      of dynamicTypeKeyNone: result.add("null")
      of dynamicTypeKeyBool: result.add($item.dynamicTypeBoolValue)
      of dynamicTypeKeyString: result.add("\"" & item.dynamicTypeStringValue & "\"")
      of dynamicTypeKeyInt: result.add($item.dynamicTypeIntValue)
      of dynamicTypeKeyFloat: result.add($item.dynamicTypeFloatValue)
      of dynamicTypeKeyClosure: result.add("\"[object Function]\"")
        
      of dynamicTypeKeyList:
        result.add("[")
        stack.add(StackItem(kind: stCloseList))
        let len = item.dynamicTypeListValue.len
        for i in countdown(len - 1, 0):
          stack.add(StackItem(kind: stValue, val: item.dynamicTypeListValue[i]))
          if i > 0:
            stack.add(StackItem(kind: stComma))
            
      of dynamicTypeKeyDict:
        result.add("{")
        stack.add(StackItem(kind: stCloseDict))
        
        # Kumpulkan pasangan key-value ke seq agar bisa di-push terbalik (LIFO)
        var pairs: seq[tuple[k: string, v: DynamicType]] = @[]
        for k, v in item.dynamicTypeDictValue:
          pairs.add((k, v))
          
        let len = pairs.len
        for i in countdown(len - 1, 0):
          # Push VALUE dulu ke stack, baru push KEY di atasnya agar KEY diekstrak duluan
          stack.add(StackItem(kind: stValue, val: pairs[i].v))
          stack.add(StackItem(kind: stKey, keyName: pairs[i].k))
          if i > 0:
            stack.add(StackItem(kind: stComma))

proc jsonStringifyVersionTwo*(variadicArguments: DynamicType): string =
  let self = variadicArguments.dynamicTypeListValue[0]
  let pretty = variadicArguments.dynamicTypeListValue[1]
  result = ""
  
  # Struktur penampung state pemrosesan koleksi
  type 
    Frame = object
      val: DynamicType
      isDict: bool
      keys: seq[string] # Hanya dipakai jika berupa dict
      index: int        # Indeks elemen yang sedang diproses
      total: int

  var stack: seq[Frame] = @[]
  
  # Masukkan root element ke dalam stack tracker
  if self.kind == dynamicTypeKeyList:
    stack.add(Frame(val: self, isDict: false, index: 0, total: self.dynamicTypeListValue.len))
    result.add("[")
  elif self.kind == dynamicTypeKeyDict:
    var dictKeys: seq[string] = @[]
    for k in self.dynamicTypeDictValue.keys: dictKeys.add(k)
    stack.add(Frame(val: self, isDict: true, keys: dictKeys, index: 0, total: dictKeys.len))
    result.add("{")
  else:
    # Elemen primitif tunggal (Bukan list/dict)
    case self.kind
    of dynamicTypeKeyNone: return "null"
    of dynamicTypeKeyBool: return $self.dynamicTypeBoolValue
    of dynamicTypeKeyString: return "\"" & self.dynamicTypeStringValue & "\""
    of dynamicTypeKeyInt: return $self.dynamicTypeIntValue
    of dynamicTypeKeyFloat: return $self.dynamicTypeFloatValue
    of dynamicTypeKeyClosure: return "\"[object Function]\""
    else: discard

  # Loop utama pengganti rekursif
  while stack.len > 0:
    # Intip frame teratas tanpa menghapusnya (peek)
    let topIdx = stack.len - 1
    
    # Jika elemen di dalam frame ini sudah habis diproses
    if stack[topIdx].index >= stack[topIdx].total:
      if stack[topIdx].isDict: result.add("}")
      else: result.add("]")
      discard stack.pop()
      continue

    # Tambahkan koma pemisah untuk elemen kedua dan seterusnya
    if stack[topIdx].index > 0:
      result.add(",")

    # Ambil elemen aktif saat ini
    var currentItem: DynamicType
    if stack[topIdx].isDict:
      let key = stack[topIdx].keys[stack[topIdx].index]
      result.add("\"" & key & "\":")
      currentItem = stack[topIdx].val.dynamicTypeDictValue[key]
    else:
      currentItem = stack[topIdx].val.dynamicTypeListValue[stack[topIdx].index]

    # Geser pointer indeks untuk iterasi berikutnya
    stack[topIdx].index += 1

    # Proses nilai dari elemen aktif
    case currentItem.kind
    of dynamicTypeKeyNone: result.add("null")
    of dynamicTypeKeyBool: result.add($currentItem.dynamicTypeBoolValue)
    of dynamicTypeKeyString: result.add("\"" & currentItem.dynamicTypeStringValue & "\"")
    of dynamicTypeKeyInt: result.add($currentItem.dynamicTypeIntValue)
    of dynamicTypeKeyFloat: result.add($currentItem.dynamicTypeFloatValue)
    of dynamicTypeKeyClosure: result.add("\"[object Function]\"")
    of dynamicTypeKeyList:
      result.add("[")
      stack.add(Frame(val: currentItem, isDict: false, index: 0, total: currentItem.dynamicTypeListValue.len))
    of dynamicTypeKeyDict:
      var subKeys: seq[string] = @[]
      for k in currentItem.dynamicTypeDictValue.keys: subKeys.add(k)
      result.add("{")
      stack.add(Frame(val: currentItem, isDict: true, keys: subKeys, index: 0, total: subKeys.len))
