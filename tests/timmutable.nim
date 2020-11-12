discard """
  action: "run"
  exitcode: 0
"""
import unittest
import sequtils
import byteutils

suite "Immutable":
  test "asString":
    let myByteSeq: seq[byte] = mapLiterals((48..57).toSeq, uint8)
    myByteSeq.asString:
      check data == "0123456789"
    check myByteSeq == mapLiterals((48..57).toSeq, uint8)

  test "asByteSeq":
    let localstr = "abcdefghijklm"
    localstr.asByteSeq:
      check data == mapLiterals((97..109).toSeq, uint8)
    check localstr == "abcdefghijklm"

