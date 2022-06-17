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

### Examples:

```sh
./oeis 1 1 2 3 5  
0 1 1 2 3 5 8 13 21 34 55 89 144 233 377 610 987 1597 2584 4181 6765 10946 17711 28657 46368 75025 121393 196418 317811 514229 832040 1346269 2178309 3524578 5702887 9227465 14930352 24157817 39088169 63245986 102334155
```

```sh
./oeis -l -i 55
1 1 1 1 2 3 6 11 23 47 106 235 551 1301 3159 7741 19320 48629 123867 317955 823065 2144505 5623756 14828074 39299897 104636890 279793450 751065460 2023443032 5469566585 14830871802 40330829030 109972410221 300628862480 823779631721 2262366343746 6226306037178
```

```sh
/oeis -l -i A001002
1
1
3
10
38
154
654
[...and so on]
```