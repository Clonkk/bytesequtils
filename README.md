# bytesequtils

A collections of ``template`` and ``proc`` to make it easier to work with buffer storing data in either ``string`` or ``seq[byte]``

Note that it **doesn't** support ``openArray[byte]``. Conversion to ``string`` do not append `'\0'` therefore using it for as ``cstring`` or with C-API is **unsafe**.

## Installation

``nimble install bytesequtils``

To generate the documentation locally use ``nimble doc --project src/bytesequtils.nim --out:docs/`` or ``nimble gendoc``

## Conversion by moving memory

The goal is to obtains a ``string``representation of ``seq[byte]`` without copy.
To accomplish that, it is necessary to ``move`` memory.
Since ``move``operation can only be done on mutable memory, immutable data will be copied and thus, will be much slower.

## Detailed documentaton

Read the documentation at https://clonkk.github.io/bytesequtils/.
