discard """
  action: "run"
  exitcode: 0
"""
import unittest
import sequtils
import byteutils

test "toString":
  let localbuf = mapLiterals(@[66, 111, 98, 64, 109, 97, 105, 108, 46, 99, 111, 109], uint8)
  var str = toString(localbuf)
  check str == "Bob@mail.com"


test "toByteSeq":
  var localstr = "azerty"
  check localstr == "azerty"
  ## You cannot use localstr after this point
  var buf = toByteSeq(localstr)
  check buf == mapLiterals(@[97, 122, 101, 114, 116, 121], uint8)
  buf[0] = 65
  check buf == mapLiterals(@[65, 122, 101, 114, 116, 121], uint8)

  # localstr has been moved
  check localstr == ""

test "asString":
  var myByteSeq: seq[byte] = mapLiterals((48..57).toSeq, uint8)
  myByteSeq.asString:
    data[0] = 'a'
    data[1] = 'b'

  check myByteSeq[0] == 97
  check myByteSeq[1] == 98

test "asByteSeq":
  var localstr = "abcdefghijklm"
  localstr.asByteSeq:
    check data == mapLiterals((97..109).toSeq, uint8)
    data[0] = 65 # uint8 value of ASCII char 'A'
    data[1] = 66 # uint8 value of ASCII char 'B'
  check localstr[0] == 'A'
  check localstr[1] == 'B'


