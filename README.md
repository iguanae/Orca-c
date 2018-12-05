# ORCΛ

<img src='https://raw.githubusercontent.com/hundredrabbits/Orca/master/resources/logo.png' width="600"/>

**Each letter of the alphabet is an operation**, lowercase letters typically operate on bang(`*`), uppercase letters operate on each frame. Bangs can be generated by various operations, such as `E` colliding with a `0`, see the [bang.orca](https://github.com/hundredrabbits/Orca/blob/master/examples/bang.orca) example. Watch a music video of [ORCΛ in action](https://twitter.com/neauoire/status/1069129232708657152).

**C Port** for the [ORCΛ](https://github.com/hundredrabbits/Orca) programming environment, with a commandline interpreter.

## Prerequisites

Core library: A C99 compiler (no VLAs required), plus enough libc for `malloc`, `realloc`, `free`, `memcpy`, `memset`, and `memmove`.

Command-line interpreter: The above, plus POSIX.

Interactive terminal UI: The above, plus ncurses (or compatible curses library).

## Build

The build script is in `bash`. It should work with `gcc` (including the `musl-gcc` wrapper) and `clang`, and will automatically detect your compiler.

Currently known to build on macOS (`gcc`, `clang`) and Linux (`gcc`, `musl-gcc`, and `clang`, optionally with `LLD`).

Not yet tested on Windows, but it's likely that it already works under `cygwin`. Further testing will be performed soon.

There is a fire-and-forget `make` wrapper around the build script.

### Make

```sh
make debug      # debugging build, binary placed at build/debug/orca
make release    # optimized build, binary placed at build/release/orca
make clean      # removes build/
```

### Build Script

Run `./tool --help` to see usage info. Examples:

```sh
./tool -c clang-7 build release orca
    # build the terminal ui with a compiler named
    # clang-7, with optimizations enabled.
    # binary placed at build/release/orca

./tool build debug cli
    # debug build of the headless CLI interpreter
    # binary placed at build/debug/cli

./tool clean
    # same as make clean, removes build/
```

## Run

### Interactive terminal UI

```sh
orca [options] [file]
```

Run the interactive terminal UI, useful for debugging or observing behavior. Pass `-h` or `--help` to see command-line argument usage.

#### Controls

- `ctrl+q` or `ctrl+d` or `ctrl+g`: quit
- Arrow keys or `ctrl+h/j/k/l`: move cursor
- `A`-`Z`, `a`-`z`, `0`-`9`, and other printable characters: write character to grid at cursor
- Spacebar: step the simulation one tick
- `ctrl+u`: undo
- `/`: change into or out of key-trigger mode (for the `!` operator)
- `[` and `]`: Adjust cosmetic grid rulers horizontally
- `{` and `}`: Adjust cosmetic grid rulers vertically
- `(` and `)`: resize grid horizontally
- `_` and `+`: resize grid vertically

### CLI interpreter

The CLI (`cli` binary) reads from a file and runs the orca simulation for 1 timestep (default) or a specified number (`-t` option) and writes the resulting state of the grid to stdout.

```sh
cli [-t timesteps] infile
```

You can also make `cli` read from stdin:
```sh
echo -e "...\na34\n..." | cli /dev/stdin
```

## Extras

- Support this project through [Patreon](https://patreon.com/100).
- See the [License](LICENSE.md) file for license rights and limitations (MIT).
- Pull Requests are welcome!
