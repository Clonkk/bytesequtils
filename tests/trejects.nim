discard """
  action: "reject"
"""
import unittest
import sequtils
import bytesequtils

suite "Rejected":
  test "toString":
    when defined(testing):
      let localbuf = mapLiterals(@[66, 111, 98, 64, 109, 97, 105, 108, 46, 99, 111, 109], uint8)
      var str = toString(localbuf)
      check str == "Bob@mail.com"
      check localbuf.len == 0
    else:
      skip()

  test "toByteSeq":
    when defined(testing):
      let localstr = "azerty"
      var buf = toByteSeq(localstr)
      check buf == mapLiterals(@[97, 122, 101, 114, 116, 121], uint8)
      buf[0] = 65
      check buf == mapLiterals(@[65, 122, 101, 114, 116, 121], uint8)
      # since localstr is immutable it hasn't changed
      check localstr.len == 0
    else:
      skip()
