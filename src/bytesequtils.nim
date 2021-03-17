# import macros

# macro asByteSeq(buf, body): untyped =
#   var tree = newStmtList()
#   let varName = ident(buf.toStrLit.strVal & "_data")
#   tree.add quote do:
#     var `varName` {.inject.} = (toByteSeq(`buf`))
#     `body`
#     `buf` = (toStrBuf(`varName`))
#   result = newBlockStmt(tree)
#   # echo result.repr

# macro asStrBuf(buf, body): untyped =
#   var tree = newStmtList()
#   let varName = ident(buf.toStrLit.strVal & "_data")
#   tree.add quote do:
#     var `varName` {.inject.} = (toStrBuf(`buf`))
#     `body`
#     `buf` = (toByteSeq(`varName`))
#   result = newBlockStmt(tree)
#   # echo result.repr

## A collections of ``template`` and ``proc`` to work with binary data stored in either ``string`` or ``seq[byte]`` buffer.
## Converting a seq[byte] into a string do not append a `'\\0'`. Be careful when interacting with `cstring` or C-API.

# Immutable version can only works with copy
# Using move here would break immutability for asStrBuf / asByteSeq
# Don't export immutable conversion as it copy data => User would end up with 2 different buffer and it's not the goal
func toByteSeq(str: string): seq[byte] {.inline.} =
  ## Copy ``string`` memory into an immutable``seq[byte]``.
  let length = str.len
  if length > 0:
    result = newSeq[byte](length)
    copyMem(result[0].unsafeAddr, str[0].unsafeAddr, length)

proc toByteSeq*(str: var string): seq[byte] {.inline.} =
  ## Move memory from a mutable ``string`` into a ``seq[byte]``.
  runnableExamples:
      # Create a buffer
      let buf_size = 10*1024
      var strbuf = newString(buf_size)
      # insert data into buffer
      # Move data from the buffer into a string
      var buffer = strbuf.toByteSeq
      doAssert strbuf.len == 0
      doAssert buffer.len == 10*1024

  if str.len > 0:
    result = move(cast[ptr seq[byte]](str.addr)[])

func toStrBuf(bytes: seq[byte]): string {.inline.} =
  ## Copy ``seq[byte]`` memory into an immutable ``string``.
  ## Do not handle null termination. Manually add `'\\0'` if you need to use cstring.
  let length = bytes.len
  if length > 0:
    result = newString(length)
    copyMem(result[0].unsafeAddr, bytes[0].unsafeAddr, length)

# Mutable version don't deal properly with null termination
proc toStrBuf*(bytes: var seq[byte]): string {.inline.} =
  ## Move memory from a mutable``seq[byte]`` into a ``string``
  ## Do not handle null termination. Manually add `'\0'` if you need to use cstring.
  runnableExamples:
    # Create a buffer
    let buf_size = 10*1024
    var buffer = newSeq[byte](buf_size)
    # insert data into buffer
    # Move data from the buffer into a string
    var strbuf = buffer.toStrBuf
    doAssert strbuf.len == 10*1024
    doAssert buffer.len == 0

  if bytes.len > 0:
    result = move(cast[ptr string](bytes.addr)[])

template asStrBuf*(bytes: var seq[byte], body) =
  ## Inject a mutable string ``data`` containing seq[byte] ``buf``
  runnableExamples:
    import sequtils
    var bytesBuffer: seq[byte] = mapLiterals((48..57).toSeq, uint8)
    bytesBuffer.asStrBuf:
      # ASCII representation of the bytes stored in bytesBuffer
      doAssert data == "0123456789"

  block:
    var data {.inject.} = toStrBuf(bytes)
    body
    bytes = toByteSeq(data)

# This template is tolerated on immutable because it does not break immutability
template asStrBuf*(bytes: seq[byte], body) =
  ##[
    ``asStrBuf`` immutable ``template`` that uses ``copyMem`` instead of ``move``.
    It is slower, but doesn't break immutability.
  ]##
  block:
    let data {.inject.} = toStrBuf(bytes)
    body

template asByteSeq*(str: var string, body) =
  ## Inject a mutable seq[byte] ``data`` containing the string ``buf``
  runnableExamples:
    import sequtils
    var strBuffer = "abcdefghijklm"
    strBuffer.asByteSeq:
      # ASCII value of the characters stored in strBuffer
      doAssert data == mapLiterals((97..109).toSeq, uint8)

  block:
    var data {.inject.} = toByteSeq(str)
    body
    str = toStrBuf(data)

# This template is tolerated on immutable because it does not break immutability
template asByteSeq*(str: string, body) =
  ##[
    ``asByteSeq`` immutable ``template`` that uses ``copyMem`` instead of ``move``.
    It is slower, but doesn't break immutability.
  ]##
  block:
    let data {.inject.} = toByteSeq(str)
    body

