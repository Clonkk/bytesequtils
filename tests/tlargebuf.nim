discard """
  cmd: "nim r -d:release $file"
  exitcode: 0
"""
import unittest
import times
import sequtils
import strutils
import byteutils

suite "largestr":
  setup:
    var largestr = newString(1e9.int)
    block:
      let refChar = @['a', 'b', 'c', 'd', 'e']
      for i in 0..<len(largestr):
        largestr[i] = refChar[i mod refChar.len]

  test "asByteSeq":
    let t0 = epochTime()

    largestr.asByteSeq:
      data[0] = 65
      data[1344] = 66

    let elapsed: float32 = (epochTime() - t0)*1000
    let elapsedStr = elapsed.formatFloat(format = ffDecimal, precision = 6)
    echo("CPU Time=", elapsedStr, "ms")

    check largestr[0] == 'A'
    check largestr[1344] == 'B'

suite "largeseq":
  setup:
    var largeseq = newSeq[byte](1e9.int)
    block:
      let refByte = mapLiterals(@[0xAB, 0xBC, 0xCD, 0xDE, 0xEF], byte)
      for i in 0..<len(largeseq):
        largeseq[i] = refByte[i mod refByte.len]

  test "asString":
    let t0 = epochTime()

    largeseq.asString:
      data[0] =  'A'
      data[1344] = 'B'

    let elapsed: float32 = (epochTime() - t0)*1000
    let elapsedStr = elapsed.formatFloat(format = ffDecimal, precision = 6)
    echo("CPU Time=", elapsedStr, "ms")

    check largeseq[0] == 65
    check largeseq[1344] == 66


