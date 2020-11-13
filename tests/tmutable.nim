discard """
  action: "run"
  exitcode: 0
"""
import unittest
import sequtils
import bytesequtils

suite "Mutable":
  test "toStrBuf ":
    var localbuf = mapLiterals(@[66, 111, 98, 64, 109, 97, 105, 108, 46, 99, 111, 109], uint8)
    let origlen = localbuf.len
    var str = toStrBuf(localbuf)
    check str == "Bob@mail.com"
    check str.len == origlen
    check localbuf.len == 0

  test "toByteSeq":
    var localstr = "azerty"
    let origlen = localstr.len
    check localstr == "azerty"
    ## You cannot use localstr after this point
    var buf = toByteSeq(localstr)
    check buf == mapLiterals(@[97, 122, 101, 114, 116, 121], uint8)
    buf[0] = 65
    check buf == mapLiterals(@[65, 122, 101, 114, 116, 121], uint8)
    check buf.len == origlen
    check localstr.len == 0

  test "asStrBuf":
    var localbuf: seq[byte] = mapLiterals((48..57).toSeq, uint8)
    let origlen = localbuf.len
    localbuf.asStrBuf:
      check data == "0123456789"
      data[0] = 'a'
      data[1] = 'b'
      check data.len == origlen

    check localbuf[0] == 97
    check localbuf[1] == 98

  test "asByteSeq":
    var localstr = "abcdefghijklm"
    let origlen = localstr.len
    localstr.asByteSeq:
      check data == mapLiterals((97..109).toSeq, uint8)
      data[0] = 65 # uint8 value of ASCII char 'A'
      data[1] = 66 # uint8 value of ASCII char 'B'
      check data.len == origlen

    check localstr[0] == 'A'
    check localstr[1] == 'B'

