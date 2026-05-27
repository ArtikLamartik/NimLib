import std/macros

macro importAll(lib: static[string], body: untyped): untyped =
  result = newStmtList()
  for node in body:
    if node.kind == nnkProcDef:
      node.addPragma(newColonExpr(ident("importc"), newStrLitNode($node.name)))
      node.addPragma(newColonExpr(ident("dynlib"), newStrLitNode(lib)))
      node.body = newEmptyNode()
      result.add(node)

importAll("/usr/lib32/nimlib.so"):
  proc allocbuf*   (size: int): pointer
  proc cf*         (path: cstring)
  proc clrscr*     ()
  proc cpfile*     (source: cstring, destination: cstring)
  proc cpfolder*   (source: cstring, destination: cstring)
  proc cron*       (milliseconds: int, function: proc() {.noconv.})
  proc cursor*     (visible: int)
  proc cursorto*   (x: int, y: int)
  proc def*        (name: cstring; value: cstring)
  proc exec*       (command: cstring): tuple[output: cstring, exit_code: int]
  proc execlive*   (command: cstring)
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
  proc getermsize* (): tuple[columns: int, rows: int]
  proc halt*       (atexit: int, exit_code: int)
  proc has*        (string1: cstring, pattern: cstring): int
  proc isdef*      (name: cstring): int
  proc isfile*     (path: cstring): int
  proc isfolder*   (path: cstring): int
  proc isroot*     (): int
  proc killjob*    (function: proc() {.noconv.})
  proc killproc*   (process_id: int)
  proc killthr*    (function: proc() {.noconv.})
  proc ladefs*     (): tuple[name: ptr UncheckedArray[cstring], value: ptr UncheckedArray[cstring], length: int]
  proc laprocs*    (): tuple[name: ptr UncheckedArray[cstring], process_id: ptr UncheckedArray[int], length: int]
  proc lf*         (): tuple[paths: ptr UncheckedArray[cstring], type_of: ptr UncheckedArray[cstring], length: int]
  proc lowstr*     (string1: cstring): cstring
  proc mcopy*      (source: cstring; destination: pointer; size: int)
  proc mkfile*     (path: cstring)
  proc mkfolder*   (path: cstring)
  proc mvfile*     (old_path: cstring; new_path: cstring)
  proc mvfolder*   (old_path: cstring; new_path: cstring)
  proc ping*       (url: cstring): int
  proc procinfo*   (process_id: int): tuple[name: cstring, process_id: int, parent_process_id: int, user_name: cstring, start_time: int, command: cstring]
  proc randint*    (minimum: int, maximum: int): int
  proc reallocbuf* (pointer1: pointer; new_size: int): pointer
  proc replacestr* (string1: cstring, pattern: cstring, replacement: cstring): cstring
  proc repstr*     (string1: cstring, count: int): cstring
  proc resetbgfg*  ()
  proc revstr*     (string1: cstring): cstring
  proc rmfile*     (path: cstring)
  proc rmfolder*   (path: cstring)
  proc schedule*   (milliseconds: int, function: proc() {.noconv.})
  proc scope*      (atexit: int, function: proc() {.noconv.})
  proc search*     (string1: cstring, pattern: cstring): tuple[matches: ptr UncheckedArray[cstring], length: int]
  proc setbg*      (r: int, g: int, b: int)
  proc setfg*      (r: int, g: int, b: int)
  proc sig*        (signal: int, function: proc() {.noconv.})
  proc sockacc*    (): cstring
  proc sockclose*  ()
  proc sockcon*    (ipaddress: cstring, port: int)
  proc sockdiscon* ()
  proc sockopen*   (port: int): cstring
  proc sockrecv*   (): cstring
  proc socksend*   (data: cstring)
  proc spawnproc*  (command: cstring): int
  proc spawnthr*   (function: proc() {.noconv.})
  proc splitstr*   (string1: cstring, pattern: cstring): tuple[parts: ptr UncheckedArray[cstring], length: int]
  proc stdi*       (visible: int): cstring
  proc stdo*       (string1: cstring)
  proc strcomp*    (string1: cstring; string2: cstring): int
  proc strformat*  (count: int): cstring {.varargs.}
  proc strsize*    (string1: cstring): int
  proc substr*     (string1: cstring, start_index: int, stop_index: int): cstring
  proc syncthr*    (function: proc() {.noconv.})
  proc timern*     (): float
  proc timerstart* (name: cstring)
  proc timerstop*  (name: cstring): int
  proc tob64str*   (forurl: int, value: cstring, key: cstring): cstring
  proc tofltint*   (value: int): float
  proc tofltstr*   (value: cstring): float
  proc tohexstr*   (value: cstring): cstring
  proc tointflt*   (value: float): int
  proc tointstr*   (value: cstring): int
  proc tostrb64*   (value: cstring, key: cstring): cstring
  proc tostrflt*   (value: float): cstring
  proc tostrhex*   (value: cstring): cstring
  proc tostrint*   (value: int): cstring
  proc trimstr*    (sides: int, string1: cstring, pattern: cstring): cstring
  proc undef*      (name: cstring)
  proc until*      (timestamp: float)
  proc upstr*      (string1: cstring): cstring
  proc version*    (): cstring
  proc vidbuf*     (mode: int)
  proc wait*       (milliseconds: int)
  proc where*      (command: cstring): cstring
