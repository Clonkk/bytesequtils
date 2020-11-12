# import macros
# import times
# import strutils

func toByteSeq*(str: string): seq[byte] {.inline.} =
  ## Converts a string to the corresponding byte sequence.
  @(str.toOpenArrayByte(0, str.high))

func toString*(bytes: openArray[byte]): string {.inline.} =
  ## Converts a byte sequence to the corresponding string.
  let length = bytes.len
  if length > 0:
    result = newString(length)
    copyMem(result.cstring, bytes[0].unsafeAddr, length)

# macro asByteSeq(buf, body): untyped =
#   var tree = newStmtList()
#   let varName = ident(buf.toStrLit.strVal & "_data")
#   tree.add quote do:
#     var `varName` {.inject.} = (toByteSeq(`buf`))
#     `body`
#     `buf` = (toString(`varName`))
#   result = newBlockStmt(tree)
#   # echo result.repr

# macro asString(buf, body): untyped =
#   var tree = newStmtList()
#   let varName = ident(buf.toStrLit.strVal & "_data")
#   tree.add quote do:
#     var `varName` {.inject.} = (toString(`buf`))
#     `body`
#     `buf` = (toByteSeq(`varName`))
#   result = newBlockStmt(tree)
#   # echo result.repr

proc toString*(buf: var seq[byte]): string = move(cast[ptr string](buf.addr)[])
proc toByteSeq*(data: var string): seq[byte] = move(cast[ptr seq[byte]](data.addr)[])

# template toString(buf: var seq[byte]) : string = move(cast[string](buf))
# template toByteSeq(data: var string)  : seq[byte] = move(cast[seq[byte]](data))

template asString*(buf: seq[byte], body)=
  block:
    var data {.inject.} = toString(buf)
    body
    buf = toByteSeq(data)

template asByteSeq*(buf: string, body)=
  block:
    var data {.inject.} = toByteSeq(buf)
    body
    buf = toString(data)

