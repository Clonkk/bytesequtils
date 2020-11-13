discard """
  action: "run"
  exitcode: 0
"""
import unittest
import bytesequtils

suite "Empty":
  test "asStrBuf":
    var localbuf: seq[byte]
    check localbuf == newSeqUninitialized[uint8](0)
    localbuf.asStrBuf:
      check data == ""

  test "asByteSeq":
    var localstr: string
    check localstr == ""
    localstr.asByteSeq:
      check data == newSeqUninitialized[uint8](0)

  test "toStrBuf ":
    var localbuf: seq[byte]
    check localbuf == newSeqUninitialized[uint8](0)
    var str = toStrBuf(localbuf)
    check str == ""

  test "toByteSeq":
    var localstr: string
    check localstr == ""
    var buf = toByteSeq(localstr)
    check buf == newSeqUninitialized[uint8](0)

