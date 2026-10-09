; --------------------------
; Vector extensions
; --------------------------

; Written as byte broadcast + bit test (rather than a bitcast to <32 x i1>), as
; some LLVM versions lower the latter to instructions we cannot encode (CMTST).
define <32 x i8> @sext_v32i1(i32 %0) {
entry:
  %1 = bitcast i32 %0 to <4 x i8>
  %2 = shufflevector <4 x i8> %1, <4 x i8> poison, <32 x i32> <i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 2, i32 2, i32 2, i32 2, i32 2, i32 2, i32 2, i32 2, i32 3, i32 3, i32 3, i32 3, i32 3, i32 3, i32 3, i32 3>
  %3 = shl <32 x i8> %2, <i8 7, i8 6, i8 5, i8 4, i8 3, i8 2, i8 1, i8 0, i8 7, i8 6, i8 5, i8 4, i8 3, i8 2, i8 1, i8 0, i8 7, i8 6, i8 5, i8 4, i8 3, i8 2, i8 1, i8 0, i8 7, i8 6, i8 5, i8 4, i8 3, i8 2, i8 1, i8 0>
  %4 = icmp slt <32 x i8> %3, zeroinitializer
  %5 = sext <32 x i1> %4 to <32 x i8>
  ret <32 x i8> %5
}

define <32 x i8> @zext_v32i1(i32 %0) {
entry:
  %1 = bitcast i32 %0 to <4 x i8>
  %2 = shufflevector <4 x i8> %1, <4 x i8> poison, <32 x i32> <i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 2, i32 2, i32 2, i32 2, i32 2, i32 2, i32 2, i32 2, i32 3, i32 3, i32 3, i32 3, i32 3, i32 3, i32 3, i32 3>
  %3 = shl <32 x i8> %2, <i8 7, i8 6, i8 5, i8 4, i8 3, i8 2, i8 1, i8 0, i8 7, i8 6, i8 5, i8 4, i8 3, i8 2, i8 1, i8 0, i8 7, i8 6, i8 5, i8 4, i8 3, i8 2, i8 1, i8 0, i8 7, i8 6, i8 5, i8 4, i8 3, i8 2, i8 1, i8 0>
  %4 = icmp slt <32 x i8> %3, zeroinitializer
  %5 = sext <32 x i1> %4 to <32 x i8>
  %6 = and <32 x i8> %5, <i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1>
  ret <32 x i8> %6
}

define <8 x i16> @sext_v8i8(<8 x i8> %0) {
entry:
  %2 = sext <8 x i8> %0 to <8 x i16>
  ret <8 x i16> %2
}

define <8 x i16> @zext_v8i8(<8 x i8> %0) {
entry:
  %2 = zext <8 x i8> %0 to <8 x i16>
  ret <8 x i16> %2
}

define <16 x i16> @sext_v16i8(<16 x i8> %0) {
entry:
  %2 = sext <16 x i8> %0 to <16 x i16>
  ret <16 x i16> %2
}

define <16 x i16> @zext_v16i8(<16 x i8> %0) {
entry:
  %2 = zext <16 x i8> %0 to <16 x i16>
  ret <16 x i16> %2
}

define <4 x i32> @sext_v4i16(<4 x i16> %0) {
entry:
  %2 = sext <4 x i16> %0 to <4 x i32>
  ret <4 x i32> %2
}

define <4 x i32> @zext_v4i16(<4 x i16> %0) {
entry:
  %2 = zext <4 x i16> %0 to <4 x i32>
  ret <4 x i32> %2
}

define <8 x i32> @sext_v8i16(<8 x i16> %0) {
entry:
  %2 = sext <8 x i16> %0 to <8 x i32>
  ret <8 x i32> %2
}

define <8 x i32> @zext_v8i16(<8 x i16> %0) {
entry:
  %2 = zext <8 x i16> %0 to <8 x i32>
  ret <8 x i32> %2
}

define <2 x i64> @sext_v2i32(<2 x i32> %0) {
entry:
  %2 = sext <2 x i32> %0 to <2 x i64>
  ret <2 x i64> %2
}

define <2 x i64> @zext_v2i32(<2 x i32> %0) {
entry:
  %2 = zext <2 x i32> %0 to <2 x i64>
  ret <2 x i64> %2
}
