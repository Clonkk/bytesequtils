# Package

version       = "1.2.0"
author        = "rcaillaud"
description   = "Nim package to manipulate buffer as either seq[byte] or string"
license       = "MIT"
srcDir        = "src"


# Dependencies

requires "nim >= 1.4.0"
task gendoc, "gen doc":
  exec("nimble doc --project src/bytesequtils.nim --out:docs/")
