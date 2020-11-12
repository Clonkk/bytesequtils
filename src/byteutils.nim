# import macros
# import times
# import strutils

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
proc toString*(buf: var seq[byte]): string {.inline.} =
  move(cast[ptr string](buf.addr)[])
proc toByteSeq*(data: var string): seq[byte] {.inline.} =
  move(cast[ptr seq[byte]](data.addr)[])

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
## `=` will take care of copy -> leave it to the compiler to optimize
func toString(buf: seq[byte]): string =
  cast[ptr string](buf.unsafeAddr)[]
func toByteSeq(data: string): seq[byte] =
  cast[ptr seq[byte]](data.unsafeAddr)[]

## Is that equivalent to let the Nim compiler copy memory ?
# func toByteSeq*(str: string): seq[byte] {.inline.} =
#   ## Converts a byte sequence to the corresponding string.
#   let length = str.len
#   if length > 0:
#     result = newSeq[byte](length)
#     copyMem(result[0].unsafeAddr, str.cstring, length)
# func toString*(bytes: openArray[byte]): string {.inline.} =
#   ## Converts a byte sequence to the corresponding string.
#   let length = bytes.len
#   if length > 0:
#     result = newString(length)
#     copyMem(result.cstring, bytes[0].unsafeAddr, length)


## No need for reassignment since data can't change
template asString*(buf: seq[byte], body) =
  block:
    let data {.inject.} = toString(buf)
    body

template asByteSeq*(buf: string, body) =
  block:
    let data {.inject.} = toByteSeq(buf)
    body

