# import macros
# import times
# import strutils

# func toByteSeq*(str: string): seq[byte] {.inline.} =
#   ## Converts a string to the corresponding byte sequence.
#   @(str.toOpenArrayByte(0, str.high))

# func toString*(bytes: openArray[byte]): string {.inline.} =
#   ## Converts a byte sequence to the corresponding string.
#   let length = bytes.len
#   if length > 0:
#     result = newString(length)
#     copyMem(result.cstring, bytes[0].unsafeAddr, length)

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

## Mutable version with addr
template toString*(buf: var seq[byte]): string = move(cast[ptr string](buf.addr)[])
template toByteSeq*(data: var string): seq[byte] = move(cast[ptr seq[byte]](data.addr)[])

## AsString template
## Can only works with mutable
template asString*(buf: var seq[byte], body) =
  block:
    var data {.inject.} = toString(buf)
    body
    buf = toByteSeq(data)

template asByteSeq*(buf: var string, body) =
  block:
    var data {.inject.} = toByteSeq(buf)
    body
    buf = toString(data)

## Immutable version can only works with copy
## Using move here would break immutability for asString / asByteSeq

## Don't export conversion as it copy data => User owuld end up with 2 different buffer and it's not the goal
template toString(buf: seq[byte]): string = (cast[ptr string](buf.unsafeAddr)[])
template toByteSeq(data: string):  seq[byte] = (cast[ptr seq[byte]](data.unsafeAddr)[])

## No need for reassignment since data can't change
template asString*(buf: seq[byte], body) =
  block:
    let data {.inject.} = toString(buf)
    body

template asByteSeq*(buf: string, body) =
  block:
    let data {.inject.} = toByteSeq(buf)
    body

