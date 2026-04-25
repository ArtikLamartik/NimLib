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
  proc allocbuf*(size: int): pointer
  proc cf*(path: cstring)
  proc cls*()
  proc def*(name: cstring; value: cstring)
  proc exec*(command: cstring): tuple[stdo: cstring, exit_code: int]
  proc fileread*(path: cstring): cstring
  proc filesize*(path: cstring): int
  proc filewrite*(path: cstring; content: cstring)
  proc freebuf*(pointer1: pointer)
  proc getcf*(): cstring
  proc getdef*(name: cstring): cstring
  proc getprocid*(): int
  proc halt*(exit_code: int)
  proc isdef*(name: cstring): int
  proc isfile*(path: cstring): int
  proc isfolder*(path: cstring): int
  proc isroot*(): int
  proc lf*(): tuple[paths: ptr UncheckedArray[cstring], types_of: ptr UncheckedArray[cstring], len: cint]
  proc mcopy*(source: cstring; destination: pointer; size: int)
  proc mkfile*(path: cstring)
  proc mkfolder*(path: cstring)
  proc reallocbuf*(pointer1: pointer; new_size: int): pointer
  proc rmfile*(path: cstring)
  proc rmfolder*(path: cstring)
  proc mvfile*(old_path: cstring; new_path: cstring)
  proc mvfolder*(old_path: cstring; new_path: cstring)
  proc stdi*(): cstring
  proc stdo*(string1: cstring)
  proc strcomp*(string1: cstring; string2: cstring): int
  proc undef*(name: cstring)
  proc wait*(milliseconds: int)
