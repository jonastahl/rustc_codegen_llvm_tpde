#!/bin/sh

set -e
ROOT="$(git rev-parse --show-toplevel)"

# Build LLVM from deps/llvm unless an LLVM was given explicitly or it is already up to date.
if [ -z "$LLVM_CONFIG" ]; then
    LLVM_COMMIT="$(git -C "$ROOT" ls-files -s deps/llvm | cut -d" " -f2)"
    if [ "$(cat "$ROOT/build/llvm/.commit" 2>/dev/null)" != "$LLVM_COMMIT" ]; then
        echo "[BUILD] llvm" 1>&2
        "$ROOT/scripts/build_llvm.sh"
        echo "$LLVM_COMMIT" > "$ROOT/build/llvm/.commit"
    fi
fi

echo "[BUILD] build system" 1>&2
exec cargo run --manifest-path "$ROOT/build_system/Cargo.toml" -- "$@"
