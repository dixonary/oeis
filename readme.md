# oeis: An executable program for retrieving data from OEIS.

A Linux build is available on the [releases page](./releases). 
Alternatively, follow the build instructions given below.

### Build instructions:

1. Install `cabal` and `ghc`.
1. Download this repository.
1. Run `cabal build`.
1. (Optional) Use `cabal install --installdir=. --install-method=copy` to move the generated binary to the root of the project.
1. (Optional) Haskell binaries are not optimised for size. Consider using [`strip`](https://linux.die.net/man/1/strip) and [`upx`](https://linux.die.net/man/1/upx) to deflate the binary.

### Usage:

```
oeis [-l|--one-per-line] [-i|--id] QUERY|ID

Available options:
  -l,--one-per-line        Print one integer per line
  -i,--id                  Search by OEIS ID
  -h,--help                Show this help text
```