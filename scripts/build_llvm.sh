#!/usr/bin/env bash
# Builds LLVM, clang and lld from the deps/llvm submodule and installs them into build/llvm.
#
# At runtime the backend uses the LLVM shared library bundled with rustc, so deps/llvm must be
# checked out at the same LLVM commit rustc was built with (see src/llvm-project in rust-lang/rust).
# This LLVM is only used to compile llvm-wrapper and TPDE (which also needs a matching clang).
#
# The build system picks up build/llvm/bin/llvm-config automatically unless LLVM_CONFIG is set.

set -xeuo pipefail
unset MALLOC_PERTURB_

ROOT=$(git -C "$(dirname "$0")" rev-parse --show-toplevel)
SRC=${LLVM_SRC:-$ROOT/deps/llvm}
PREFIX=${LLVM_PREFIX:-$ROOT/build/llvm}
BUILD=${LLVM_BUILD_DIR:-$ROOT/build/llvm-build}

git -C "$ROOT" submodule update --init deps/llvm

# Prefer clang and lld for building, like rustc's LLVM, but fall back to the system defaults.
EXTRA_ARGS=()
if command -v clang >/dev/null && command -v clang++ >/dev/null; then
  export CC=${CC:-clang} CXX=${CXX:-clang++}
fi
if command -v ld.lld >/dev/null; then
  EXTRA_ARGS+=(-DLLVM_ENABLE_LLD=ON)
fi

cmake -G Ninja -S "$SRC"/llvm -B "$BUILD" \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="$PREFIX" \
  -DLLVM_ENABLE_PROJECTS="clang;lld" \
  -DLLVM_TARGETS_TO_BUILD="X86;AArch64" \
  -DLLVM_LINK_LLVM_DYLIB=ON \
  -DLLVM_ENABLE_ASSERTIONS=OFF \
  -DLLVM_INCLUDE_EXAMPLES=OFF \
  -DLLVM_INCLUDE_TESTS=OFF \
  -DLLVM_INCLUDE_BENCHMARKS=OFF \
  -DCLANG_ENABLE_STATIC_ANALYZER=OFF \
  "${EXTRA_ARGS[@]}"
ninja -C "$BUILD" install
