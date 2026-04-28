import std/strutils
import std/terminal
import std/posix
import osproc
import std/os

proc allocbuf*(size: int): pointer {.exportc, dynlib.} =
  return alloc(size)

proc cf*(path: cstring) {.exportc, dynlib.} =
  setCurrentDir($path)

proc cls*() {.exportc, dynlib.} =
  stdout.write("\x1b[2J\x1b[H")
  stdout.flushFile()

proc def*(name: cstring; value: cstring) {.exportc, dynlib.} =
  putEnv($name, $value)

proc exec*(command: cstring): tuple[stdo: cstring, exit_code: int] {.exportc, dynlib.} =
  let (stdo, exit_code) = execCmdEx($command)
  return (cstring(stdo), int(exit_code))

proc fileread*(path: cstring): cstring {.exportc, dynlib.} =
  return cstring(readFile($path))

proc filesize*(path: cstring): int {.exportc, dynlib.} =
  return int(getFileSize($path))

proc filewrite*(path: cstring; content: cstring) {.exportc, dynlib.} =
  writeFile($path, $content)

proc freebuf*(pointer1: pointer) {.exportc, dynlib.} =
  dealloc(pointer1)

proc getcf*(): cstring {.exportc, dynlib.} =
  return cstring(getCurrentDir())

proc getchr*(): cstring {.exportc, dynlib.} =
  return cstring($getch())

proc getdef*(name: cstring): cstring {.exportc, dynlib.} =
  if existsEnv($name):
    return cstring($getEnv($name))
  else:
    return ""

proc getcpid*(): int {.exportc, dynlib.} =
  return int(getCurrentProcessId())

proc halt*(exit_code: int) {.exportc, dynlib.} =
  quit(exit_code)

proc infoproc*(process_id: int): tuple[name: cstring, process_id: cstring, parent_process_id: cstring, user_id: cstring, start_time: cstring, command: cstring] {.exportc, dynlib.} =
  let output = execProcess("ps -p " & $process_id & " -o comm,pid,ppid,user,stime,cmd --no-headers")
  let line = output.strip()
  let parts = line.splitWhitespace(maxsplit=5)
  return (cstring(parts[0]), cstring(parts[1]), cstring(parts[2]), cstring(parts[3]), cstring(parts[4]), cstring(parts[5]))

proc isdef*(name: cstring): int {.exportc, dynlib.} =
  return int(existsEnv($name) == true)

proc isfile*(path: cstring): int {.exportc, dynlib.} =
  return int(fileExists($path) == true)

proc isfolder*(path: cstring): int {.exportc, dynlib.} =
  return int(dirExists($path) == true)

proc isroot*(): int {.exportc, dynlib.} =
  return int(isAdmin() == true)

proc killproc*(process_id: int) {.exportc, dynlib.} =
  discard kill(Pid(process_id), SIGKILL)

proc laprocs*(): tuple[name: ptr UncheckedArray[cstring], process_id: ptr UncheckedArray[cstring], length: int] {.exportc, dynlib.} =
  var n: seq[cstring]
  var p: seq[cstring]
  let output = execProcess("ps -eo pid,comm --no-headers")
  for line in output.splitLines():
    let parts = line.strip().split()
    if parts.len == 2:
      p.add(cstring(parts[0]))
      n.add(cstring(parts[1]))
  return (cast[ptr UncheckedArray[cstring]](addr n[0]), cast[ptr UncheckedArray[cstring]](addr p[0]), n.len.int)

proc lf*(): tuple[paths: ptr UncheckedArray[cstring], types_of: ptr UncheckedArray[cstring], length: int] {.exportc, dynlib.} =
  var p: seq[cstring]
  var t: seq[cstring]
  for kind, name in walkDir(getCurrentDir()):
    if kind == pcFile:
      p.add(cstring(name)); t.add(cstring("file"))
    elif kind == pcDir:
      p.add(cstring(name)); t.add(cstring("folder"))
  return (cast[ptr UncheckedArray[cstring]](addr p[0]), cast[ptr UncheckedArray[cstring]](addr t[0]), p.len.int)

proc mcopy*(source: cstring; destination: pointer; size: int) {.exportc, dynlib.} =
  copyMem(destination, source, size)

proc mkfile*(path: cstring) {.exportc, dynlib.} =
  writeFile($path, "")

proc mkfolder*(path: cstring) {.exportc, dynlib.} =
  createDir($path)

proc mvfile*(old_path: cstring; new_path: cstring) {.exportc, dynlib.} =
  moveFile($old_path, $new_path)

proc mvfolder*(old_path: cstring; new_path: cstring) {.exportc, dynlib.} =
  moveDir($old_path, $new_path)

proc reallocbuf*(pointer1: pointer; new_size: int): pointer {.exportc, dynlib.} =
  return realloc(pointer1, new_size)

proc rmfile*(path: cstring) {.exportc, dynlib.} =
  removeFile($path)

proc rmfolder*(path: cstring) {.exportc, dynlib.} =
  removeDir($path)

proc spawnproc*(command: cstring): int {.exportc, dynlib.} =
  return int(startProcess($command).processID)

proc stdi*(invisible: int = 0): cstring {.exportc, dynlib.} =
  try:
    if invisible == 0:
      return cstring(readLine(stdin))
    elif invisible == 1:
      return cstring(readPasswordFromStdin(prompt = ""))
  except EOFError:
    return ""

proc stdo*(string1: cstring) {.exportc, dynlib.} =
  write(stdout, string1)

proc strcomp*(string1: cstring; string2: cstring): int {.exportc, dynlib.} =
  return int(cmp(string1, string2) != 0)

proc strformat*(count: int): cstring {.exportc, dynlib, varargs.} =
  {.emit: """
  #include <stdarg.h>
  static char buf[65536];
  buf[0] = '\0';
  va_list args;
  va_start(args, `count`);
  for (int i = 0; i < `count`; i++) {
    const char* s = va_arg(args, const char*);
    if (s != NULL) strcat(buf, s);
  }
  va_end(args);
  return buf;
  """.}

proc undef*(name: cstring) {.exportc, dynlib.} =
  delEnv($name)

proc wait*(milliseconds: int) {.exportc, dynlib.} =
  sleep(milliseconds)
