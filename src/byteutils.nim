# import macros
# import strutils

# macro asByteopenArray(buf, body): untyped =
#   var tree = newStmtList()
#   let varName = ident(buf.toStrLit.strVal & "_data")
#   tree.add quote do:
#     var `varName` {.inject.} = (toByteArray(`buf`))
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
#     `buf` = (toByteArray(`varName`))
#   result = newBlockStmt(tree)
#   # echo result.repr

## Mutable version with addr
proc toString*(buf: var openArray[byte]): string {.inline.} =
  ## Move memory from a ``var openArray[byte]`` into a ``string``
  runnableExamples:
    # Create a buffer
    let buf_size = 10*1024
    var buffer = newopenArray[byte](buf_size)
    # insert data into buffer
    # Move data from the buffer into a string
    var strbuf = buffer.toString
    doAssert strBuf.len == 10*1024
    doAssert buffer.len == 0
  move(cast[ptr string](buf.addr)[])

proc toByteArray*(data: var string): seq[byte] {.inline.} =
  ## Move memory from a ``var string`` into a ``seq[byte]``
  runnableExamples:
    # Create a buffer
    let buf_size = 10*1024
    var strbuf = newString(buf_size)
    # insert data into buffer
    # Move data from the buffer into a string
    var buf = buffer.toString
    doAssert strbuf.len == 0
    doAssert buf.len == 10*1024
  move(cast[ptr seq[byte]](data.addr)[])


## AsString template
## Can only works with mutable
template asString*(buf: var openArray[byte], body) =
  ## Inject a mutable string ``data`` containing openArray[byte] ``buf``
  runnableExamples:
    var myByteopenArray: openArray[byte] = mapLiterals((48..57).toopenArray, uint8)
    myByteopenArray.asString:
      check data == "0123456789"

  block:
    var data {.inject.} = toString(buf)
    body
    buf = toByteArray(data)

template asByteopenArray*(buf: var string, body) =
  ## Inject a mutable openArray[byte] ``data`` containing the string ``buf``
  runnableExamples:
    var localstr = "abcdefghijklm"
    localstr.asByteopenArray:
      check data == mapLiterals((97..109).toopenArray, uint8)

  block:
    var data {.inject.} = toByteArray(buf)
    body
    buf = toString(data)

## Immutable version can only works with copy
## Using move here would break immutability for asString / asByteopenArray

## Don't export conversion as it copy data => User owuld end up with 2 different buffer and it's not the goal
## `=` will take care of copy -> leave it to the compiler to optimize
func toString(buf: openArray[byte]): string =
  cast[ptr string](buf.unsafeAddr)[]

func toByteArray(data: string): seq[byte] =
  cast[ptr seq[byte]](data.unsafeAddr)[]

# Is letting the compiler copy memory thorugh `=` identical to copyMem manually ?
# func toByteArray*(str: string): openArray[byte] {.inline.} =
#   ## Converts a byte openArrayuence to the corresponding string.
#   let length = str.len
#   if length > 0:
#     result = newopenArray[byte](length)
#     copyMem(result[0].unsafeAddr, str.cstring, length)
# func toString*(bytes: openArray[byte]): string {.inline.} =
#   ## Converts a byte openArrayuence to the corresponding string.
#   let length = bytes.len
#   if length > 0:
#     result = newString(length)
#     copyMem(result.cstring, bytes[0].unsafeAddr, length)

## No need for reassignment since data can't change
## This template is tolerated on immutable because it does not break immutability
template asString*(buf: openArray[byte], body) =
  ## ``asString`` immutable version.
  block:
    let data {.inject.} = toString(buf)
    body

template asByteopenArray*(buf: string, body) =
  ## ``asByteopenArray`` immutable version.
  block:
    let data {.inject.} = toByteArray(buf)
    body

