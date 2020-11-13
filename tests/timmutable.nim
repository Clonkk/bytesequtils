discard """
  action: "run"
  exitcode: 0
"""
import unittest
import sequtils
import byteutils

suite "Immutable":
  test "asString":
    let localbuf: seq[byte] = mapLiterals((48..57).toSeq, uint8)
    let origlen = localbuf.len
    localbuf.asString:
      check data == "0123456789"
      check data.len == origlen
    check localbuf == mapLiterals((48..57).toSeq, uint8)

  test "asByteArray":
    let localstr = "abcdefghijklm"
    let origlen = localstr.len
    localstr.asByteArray:
      check data == mapLiterals((97..109).toSeq, uint8)
      check data.len == origlen
    check localstr == "abcdefghijklm"

