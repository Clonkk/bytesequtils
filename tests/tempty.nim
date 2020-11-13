discard """
  action: "run"
  exitcode: 0
"""
import unittest
import sequtils
import byteutils

suite "Empty":
  test "asString":
    var localbuf: seq[byte]
    check localbuf == newSeqUninitialized[uint8](0)
    localbuf.asString:
      check data == ""

  test "asByteArray":
    var localstr: string
    check localstr == ""
    localstr.asByteArray:
      check data == newSeqUninitialized[uint8](0)

  test "toString ":
    var localbuf: seq[byte]
    check localbuf == newSeqUninitialized[uint8](0)
    var str = toString(localbuf)
    check str == ""

  test "toByteArray":
    var localstr: string
    check localstr == ""
    var buf = toByteArray(localstr)
    check buf == newSeqUninitialized[uint8](0)

