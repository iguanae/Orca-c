#!/usr/bin/env bash
set -eu -o pipefail

os=
case $(uname -s | awk '{print tolower($0)}') in
  linux*) os=linux;;
  darwin*) os=mac;;
  cygwin*) os=cygwin;;
  *bsd*) os=bsd;;
  *) os=unknown;;
esac


print_usage() {
cat <<EOF
Usage: tool [options] command [args]
Options:
    -v            Print important commands as they're executed.
    -c <name>     Use a specific compiler binary instead.
                  Default: \$CC, or cc
    -h or --help  Print this message and exit.
EOF
}

compiler_exe="${CC:-cc}"

verbose=0

while getopts c:hv-: opt_val; do
  case "$opt_val" in
    -)
      case "$OPTARG" in
        help) print_usage; exit 0;;
        *)
          echo "Unknown long option --$OPTARG" >&2
          print_usage >&2
          exit 1
          ;;
      esac
      ;;
    c) compiler_exe="$OPTARG";;
    v) verbose=1;;
    h) print_usage; exit 0;;
    \?) print_usage >&2; exit 1;;
    *) break;;
  esac
done

warn() {
  echo "Warning: $*" >&2
}
fatal() {
  echo "Error: $*" >&2
  exit 1
}
script_error() {
  echo "Script error: $*" >&2
  exit 1
}

verbose_echo() {
  if [[ $verbose = 1 ]]; then
    echo "$@"
  fi
  "$@"
}

if [[ ($os == bsd) || ($os == unknown) ]]; then
  warn "Build script not tested on this platform"
fi

# This is not perfect by any means
cc_id=
compiler_vers=
if ${compiler_exe} --version | grep -q ^clang 2> /dev/null; then
  cc_id=clang
  compiler_vers=$(${compiler_exe} -dumpversion)
# Only gcc has -dumpfullversion
elif compiler_vers=$(${compiler_exe} -dumpfullversion 2> /dev/null); then
  cc_id=gcc
fi

if [[ -z $cc_id ]]; then
  warn "Failed to detect compiler type"
fi
if [[ -z $compiler_vers ]]; then
  warn "Failed to detect compiler version"
fi

add() {
  if [[ -z "${1:-}" ]]; then
    script_error "At least one argument required for array add"
  fi
  local array_name
  array_name=${1}
  shift
  eval "$array_name+=($(printf "'%s' " "$@"))"
}

try_make_dir() {
  if ! [[ -e "$1" ]]; then
    verbose_echo mkdir "$1"
  elif ! [[ -d "$1" ]]; then
    fatal "File $1 already exists but is not a directory"
  fi
}

out_exe=orca
build_dir=build
source_files=()
add source_files field.c mark.c bank.c sim.c

# safety flags:  -D_FORTIFY_SOURCE=2 -fstack-protector-strong -fpie -Wl,-pie
  #local tui_flags=()
  #add tui_flags -D_XOPEN_SOURCE_EXTENDED=1

build_target() {
  local build_subdir
  local compiler_flags=()
  local libraries=()
  add compiler_flags -std=c99 -pipe -Wall -Wpedantic -Wextra -Wconversion -Werror=implicit-function-declaration -Werror=implicit-int -Werror=incompatible-pointer-types -Werror=int-conversion
  case "$1" in
    debug)
      build_subdir=debug
      add compiler_flags -DDEBUG -ggdb -fsanitize=address -fsanitize=undefined
      if [[ $os = mac ]]; then
        # mac clang does not have -Og
        add compiler_flags -O1
        # tui in the future
        # add libraries -lncurses
      else
        add compiler_flags -Og -feliminate-unused-debug-symbols
        # needed if address is already specified? doesn't work on mac clang, at
        # least
        # add compiler_flags -fsanitize=leak
        # add libraries -lncursesw
      fi
      ;;
    release)
      build_subdir=release
      add compiler_flags -DNDEBUG -O2 -g0
      if [[ $os = mac ]]; then
        # todo some stripping option
        true
      else
        # -flto is good on both clang and gcc on Linux
        add compiler_flags -flto -s
      fi
      ;;
    *) fatal "Unknown build target \"$1\"";;
  esac
  add source_files cli_main.c
  try_make_dir "$build_dir"
  try_make_dir "$build_dir/$build_subdir"
  verbose_echo "${compiler_exe}" "${compiler_flags[@]}" -o "$build_dir/$build_subdir/$out_exe" "${source_files[@]}" "${libraries[@]}"
}

shift $((OPTIND - 1))

if [[ -z "${1:-}" ]]; then
  echo "Error: Command required" >&2
  print_usage >&2
  exit 1
fi

case "$1" in
  info)
    echo "OS:               $os"
    echo "Compiler name:    $compiler_exe"
    echo "Compiler type:    $cc_id"
    echo "Compiler version: $compiler_vers"
    exit 0
    ;;
  build)
    if [[ "$#" -gt 2 ]]; then
      fatal "Too many arguments for 'build'"
    fi
    if [ "$#" -lt 1 ]; then
      fatal "Argument required for build target"
      exit 1
    fi
    build_target "$2"
    ;;
  clean)
    if [[ -d "$build_dir" ]]; then
      verbose_echo rm -rf "$build_dir"
    fi
    ;;
  *) echo "Unrecognized command $1"; exit 1;;
esac
