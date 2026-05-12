import std/macros

macro importAll(lib: static[string], body: untyped): untyped =
  result = newStmtList()
  for node in body:
    if node.kind == nnkProcDef:
      node.addPragma(newColonExpr(ident("importc"), newStrLitNode($node.name)))
      node.addPragma(newColonExpr(ident("dynlib"), newStrLitNode(lib)))
      node.body = newEmptyNode()
      result.add(node)

importAll("../build/nimlib.so"):
  proc allocbuf*   (size: int): pointer
  proc cf*         (path: cstring)
  proc clrscr*     ()
  proc cursor*     (visible: int)
  proc cursorto*   (x: int, y: int)
  proc def*        (name: cstring; value: cstring)
  proc exec*       (command: cstring): tuple[output: cstring, exit_code: int]
  proc fileinfo*   (path: cstring): tuple[name: cstring, creator: cstring, last_edit: int, file_size: int]
  proc fileread*   (path: cstring): cstring
  proc filewrite*  (path: cstring; content: cstring)
  proc folderinfo* (path: cstring): tuple[name: cstring, creator: cstring, last_edit: int, folder_size: int]
  proc freebuf*    (pointer1: pointer)
  proc getargs*    (): tuple[args: ptr UncheckedArray[cstring], length: int]
  proc getcf*      (): cstring
  proc getchr*     (): cstring
  proc getcpid*    (): int
  proc getdef*     (name: cstring): cstring
  proc getprogloc* (): cstring
  proc halt*       (exit_code: int)
  proc isdef*      (name: cstring): int
  proc isfile*     (path: cstring): int
  proc isfolder*   (path: cstring): int
  proc isroot*     (): int
  proc killproc*   (process_id: int)
  proc killthr*    (function: proc() {.noconv.})
  proc ladefs*     (): tuple[name: ptr UncheckedArray[cstring], value: ptr UncheckedArray[cstring], length: int]
  proc laprocs*    (): tuple[name: ptr UncheckedArray[cstring], process_id: ptr UncheckedArray[cstring], length: int]
  proc lf*         (): tuple[paths: ptr UncheckedArray[cstring], types_of: ptr UncheckedArray[cstring], length: int]
  proc mcopy*      (source: cstring; destination: pointer; size: int)
  proc mkfile*     (path: cstring)
  proc mkfolder*   (path: cstring)
  proc msgbox*     (title: cstring, count: int): int {.varargs.}
  proc mvfile*     (old_path: cstring; new_path: cstring)
  proc mvfolder*   (old_path: cstring; new_path: cstring)
  proc ping*       (url: cstring): int
  proc procinfo*   (process_id: int): tuple[name: cstring, process_id: int, parent_process_id: int, user_name: cstring, start_time: int, command: cstring]
  proc randint*    (minimum: int, maximum: int): int
  proc reallocbuf* (pointer1: pointer; new_size: int): pointer
  proc resetbgfg*  ()
  proc rmfile*     (path: cstring)
  proc rmfolder*   (path: cstring)
  proc scope*      (atexit: int, function: proc() {.noconv.})
  proc setbg*      (r: int, g: int, b: int)
  proc setfg*      (r: int, g: int, b: int)
  proc sig*        (signal: int, function: proc() {.noconv.})
  proc spawnthr*   (function: proc() {.noconv.})
  proc spawnproc*  (command: cstring): int
  proc stdi*       (visible: int): cstring
  proc stdo*       (string1: cstring)
  proc strcomp*    (string1: cstring; string2: cstring): int
  proc strformat*  (count: int): cstring {.varargs.}
  proc syncthr*    (function: proc() {.noconv.})
  proc timern*     (): int
  proc tofltint*   (value: int): float
  proc tofltstr*   (value: cstring): float
  proc tointflt*   (value: float): int
  proc tointstr*   (value: cstring): int
  proc tostrflt*   (value: float): cstring
  proc tostrint*   (value: int): cstring
  proc undef*      (name: cstring)
  proc wait*       (milliseconds: int)
  proc where*      (command: cstring): cstring
