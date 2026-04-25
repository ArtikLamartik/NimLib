import std/macros

macro importAll(lib: static[string], body: untyped): untyped =
  result = newStmtList()
  for node in body:
    if node.kind == nnkProcDef:
      node.addPragma(newColonExpr(ident("importc"), newStrLitNode($node.name)))
      node.addPragma(newColonExpr(ident("dynlib"), newStrLitNode(lib)))
      node.body = newEmptyNode()
      result.add(node)

importAll("/path/to/nimlib.so"):
  proc allocbuf*(size: int): pointer {.exportc, dynlib.}
  proc cf*(path: cstring) {.exportc, dynlib.}
  proc cls*() {.exportc, dynlib.}
  proc def*(name: cstring; value: cstring) {.exportc, dynlib.}
  proc exec*(command: cstring): tuple[stdo: cstring, exit_code: int] {.exportc, dynlib.}
  proc filesize*(path: cstring): int {.exportc, dynlib.}
  proc fileread*(path: cstring): cstring {.exportc, dynlib.}
  proc filewrite*(path: cstring; content: cstring) {.exportc, dynlib.}
  proc freebuf*(pointer1: pointer) {.exportc, dynlib.}
  proc getcf*(): cstring {.exportc, dynlib.}
  proc getdef*(name: cstring): cstring {.exportc, dynlib.}
  proc getprocid*(): int {.exportc, dynlib.}
  proc halt*(exit_code: int) {.exportc, dynlib.}
  proc isdef*(name: cstring): int {.exportc, dynlib.}
  proc isfile*(path: cstring): int {.exportc, dynlib.}
  proc isfolder*(path: cstring): int {.exportc, dynlib.}
  proc isroot*(): int {.exportc, dynlib.}
  proc lf*(): tuple[paths: ptr UncheckedArray[cstring], types_of: ptr UncheckedArray[cstring], len: cint] {.exportc, dynlib.}
  proc mcopy*(source: cstring; destination: pointer; size: int) {.exportc, dynlib.}
  proc mkfile*(path: cstring) {.exportc, dynlib.}
  proc mkfolder*(path: cstring) {.exportc, dynlib.}
  proc reallocbuf*(pointer1: pointer; new_size: int): pointer {.exportc, dynlib.}
  proc rm*(path: cstring) {.exportc, dynlib.}
  proc rmfolder*(path: cstring) {.exportc, dynlib.}
  proc mv*(old_path: cstring; new_path: cstring) {.exportc, dynlib.}
  proc mvfolder*(old_path: cstring; new_path: cstring) {.exportc, dynlib.}
  proc stdi*(): cstring {.exportc, dynlib.}
  proc stdo*(string1: cstring) {.exportc, dynlib.}
  proc strcomp*(string1: cstring; string2: cstring): int {.exportc, dynlib.}
  proc undef*(name: cstring) {.exportc, dynlib.}
  proc wait*(milliseconds: int) {.exportc, dynlib.}
