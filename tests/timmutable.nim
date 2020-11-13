discard """
  action: "run"
  exitcode: 0
"""
import unittest
import sequtils
import bytesequtils

suite "Immutable":
  test "asStrBuf":
    let localbuf: seq[byte] = mapLiterals((48..57).toSeq, uint8)
    let origlen = localbuf.len
    localbuf.asStrBuf:
      check data == "0123456789"
      check data.len == origlen
    check localbuf == mapLiterals((48..57).toSeq, uint8)

  test "asByteSeq":
    let localstr = "abcdefghijklm"
    let origlen = localstr.len
    localstr.asByteSeq:
      check data == mapLiterals((97..109).toSeq, uint8)
      check data.len == origlen
    check localstr == "abcdefghijklm"

