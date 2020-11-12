discard """
  action: "run"
  exitcode: 0
"""

import unittest
import times
import sequtils
import strutils
import byteutils

const LARGE_BYTE_SIZE = 135_579_135

template time_it(name:string, body)=
  let t0 = epochTime()
  body
  let elapsed: float32 = (epochTime() - t0)*1000
  let elapsedStr = elapsed.formatFloat(format = ffDecimal, precision = 6)
  echo("  ", name, "> CPU Time=", elapsedStr, "ms")

suite "largestr":
  proc initLargeString(): string =
    result = newString(LARGE_BYTE_SIZE)
    block:
      let refChar = @['a', 'b', 'c', 'd', 'e']
      for i in 0..<len(result):
        result[i] = refChar[i mod refChar.len]

  test "toByteSeq":
    var buf = initLargeString()

    time_it("toByteSeq"):
      var byteseq = toByteSeq(buf)
      byteseq[0] = 65
      byteseq[1344] = 66

    # Immutable variable do not get modified
    check buf.len == 0

  test "asByteSeq":
    var largestr = initLargeString()
    time_it("asByteSeq"):
      largestr.asByteSeq:
        data[0] = 65
        data[1344] = 66

    check largestr[0] == 'A'
    check largestr[1344] == 'B'

suite "largeseq":
  proc initLargeSeq(): seq[byte] =
    result = newSeq[byte](LARGE_BYTE_SIZE)
    let refByte = mapLiterals(@[0xAB, 0xBC, 0xCD, 0xDE, 0xEF], byte)
    for i in 0..<len(result):
      result[i] = refByte[i mod refByte.len]

  test "asString":
    var largeseq = initLargeSeq()
    time_it("asString"):
      largeseq.asString:
        data[0] = 'A'
        data[1344] = 'B'

    check largeseq[0] == 65
    check largeseq[1344] == 66

  test "toString":
    var buf = initLargeSeq()
    time_it("toString"):
      var str = toString(buf)
      str[0] = 'A'
      str[1344] = 'B'

    # Immutable variable do not get modified
    check buf.len == 0

