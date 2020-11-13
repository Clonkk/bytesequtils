# import macros

# macro asByteArray(buf, body): untyped =
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
proc toString*(bytes: var seq[byte]): string {.inline.} =
  ## Move memory from a ``var seq[byte]`` into a ``string``
  runnableExamples:
    # Create a buffer
    let buf_size = 10*1024
    var buffer = newSeq[byte](buf_size)
    # insert data into buffer
    # Move data from the buffer into a string
    var strbuf = buffer.toString
    doAssert strbuf.len == 10*1024
    doAssert buffer.len == 0

  if bytes.len > 0:
    result = move(cast[ptr string](bytes.addr)[])


proc toByteArray*(str: var string): seq[byte] {.inline.} =
  ## Move memory from a ``var string`` into a ``seq[byte]``
  runnableExamples:
    # Create a buffer
    let buf_size = 10*1024
    var strbuf = newString(buf_size)
    # insert data into buffer
    # Move data from the buffer into a string
    var buffer = strbuf.toByteArray
    doAssert strbuf.len == 0
    doAssert buffer.len == 10*1024

  if str.len > 0:
    result = move(cast[ptr seq[byte]](str.addr)[])

## AsString template
## Can only works with mutable
template asString*(bytes: var seq[byte], body) =
  ## Inject a mutable string ``data`` containing seq[byte] ``buf``
  runnableExamples:
    import sequtils
    var myByteseq: seq[byte] = mapLiterals((48..57).toSeq, uint8)
    myByteseq.asString:
      doAssert data == "0123456789"

  block:
    var data {.inject.} = toString(bytes)
    body
    bytes = toByteArray(data)

template asByteArray*(str: var string, body) =
  ## Inject a mutable seq[byte] ``data`` containing the string ``buf``
  runnableExamples:
    import sequtils
    var localstr = "abcdefghijklm"
    localstr.asByteArray:
      doAssert data == mapLiterals((97..109).toSeq, uint8)

  block:
    var data {.inject.} = toByteArray(str)
    body
    str = toString(data)

## Immutable version can only works with copy
## Using move here would break immutability for asString / asByteArray

## Don't export conversion as it copy data => User would end up with 2 different buffer and it's not the goal
func toByteArray*(str: string): seq[byte] {.inline.} =
  ## Converts a byte sequence to the corresponding string.
  let length = str.len
  if length > 0:
    result = newSeq[byte](length)
    copyMem(result[0].unsafeAddr, str.cstring, length)

func toString*(bytes: seq[byte]): string {.inline.} =
  ## Converts a byte sequence to the corresponding string.
  let length = bytes.len
  if length > 0:
    result = newString(length)
    copyMem(result.cstring, bytes[0].unsafeAddr, length)

## No need for reassignment since data can't change
## This template is tolerated on immutable because it does not break immutability
template asString*(bytes: seq[byte], body) =
  ## ``asString`` immutable version.
  block:
    let data {.inject.} = toString(bytes)
    body

template asByteArray*(str: string, body) =
  ## ``asByteArray`` immutable version.
  block:
    let data {.inject.} = toByteArray(str)
    body

