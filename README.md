# byteutils

Some utility function to manipulate buffers as string or seq[byte]

## toByteSeq

Convert ``seq[byte]`` into ``string`` by ``move``. If the original data is immutable a copy will be made (and performance will drop).

## toString

Convert ``string`` into ``seq[byte]`` by ``move``. If the original data is immutable a copy will be made (and performance will drop).

## asString, asByteSeq template

Move memory inside an injected variable ``data`` and back into the original variable. Can only be used on mutable variable.

