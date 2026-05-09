import std/exitprocs
import std/strutils
import std/terminal
import std/random
import std/posix
import osproc
import std/os

{.emit: """
#include <termios.h>
#include <stdarg.h>
#include <string.h>
#include <unistd.h>
#include <stdio.h>
""".}

var exitqueue: seq[proc() {.noconv.}] = @[]

proc runfifoexit() {.noconv.} =
  for f in exitqueue:
    f()

addExitProc(runfifoexit)

proc allocbuf*(size: int): pointer {.exportc, dynlib.} =
  return alloc(size)

proc cf*(path: cstring) {.exportc, dynlib.} =
  setCurrentDir($path)

proc clrscr*() {.exportc, dynlib.} =
  discard execCmd("clear")

proc cursor*(visible: int) {.exportc, dynlib.} =
  if visible == 0:
    stdout.write("\x1b[?25l")
  elif visible == 1:
    stdout.write("\x1b[?25h")
  stdout.flushFile()

proc cursorto*(x: int, y: int) {.exportc, dynlib.} =
  stdout.write("\x1b[" & $(y + 1) & ";" & $(x + 1) & "H")
  stdout.flushFile()

proc def*(name: cstring, value: cstring) {.exportc, dynlib.} =
  putEnv($name, $value)

proc exec*(command: cstring): tuple[stdo: cstring, exit_code: int] {.exportc, dynlib.} =
  let (stdo, exit_code) = execCmdEx($command)
  return (cstring(stdo), int(exit_code))

proc fileread*(path: cstring): cstring {.exportc, dynlib.} =
  return cstring(readFile($path))

proc filesize*(path: cstring): int {.exportc, dynlib.} =
  return int(getFileSize($path))

proc filewrite*(path: cstring, content: cstring) {.exportc, dynlib.} =
  writeFile($path, $content)

proc freebuf*(pointer1: pointer) {.exportc, dynlib.} =
  dealloc(pointer1)

proc getargs*(): tuple[args: ptr UncheckedArray[cstring], length: int] {.exportc, dynlib.} =
  var a: seq[cstring]
  let cmdline = readFile("/proc/self/cmdline")
  let parts = cmdline.split('\0')
  for i in 1..<parts.len:
    if parts[i].len > 0:
      a.add(cstring(parts[i]))
  if a.len == 0:
    a.add(cstring(""))
  return (cast[ptr UncheckedArray[cstring]](addr a[0]), a.len.int)

proc getcf*(): cstring {.exportc, dynlib.} =
  return cstring(getCurrentDir())

proc getchr*(): cstring {.exportc, dynlib.} =
  return cstring($getch())

proc getcpid*(): int {.exportc, dynlib.} =
  return int(getCurrentProcessId())

proc getdef*(name: cstring): cstring {.exportc, dynlib.} =
  if existsEnv($name):
    return cstring($getEnv($name))
  else:
    return ""

proc getprogloc*(): cstring {.exportc, dynlib.} =
  return cstring(getAppFilename())

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

proc ladefs*(): tuple[name: ptr UncheckedArray[cstring], value: ptr UncheckedArray[cstring], length: int] {.exportc, dynlib.} =
  var n: seq[cstring]
  var v: seq[cstring]
  for key, val in envPairs():
    n.add(cstring(key))
    v.add(cstring(val))
  return (cast[ptr UncheckedArray[cstring]](addr n[0]), cast[ptr UncheckedArray[cstring]](addr v[0]), n.len.int)

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
      p.add(cstring(name))
      t.add(cstring("file"))
    elif kind == pcDir:
      p.add(cstring(name))
      t.add(cstring("folder"))
  return (cast[ptr UncheckedArray[cstring]](addr p[0]), cast[ptr UncheckedArray[cstring]](addr t[0]), p.len.int)

proc mcopy*(source: cstring, destination: pointer, size: int) {.exportc, dynlib.} =
  copyMem(destination, source, size)

proc mkfile*(path: cstring) {.exportc, dynlib.} =
  writeFile($path, "")

proc mkfolder*(path: cstring) {.exportc, dynlib.} =
  createDir($path)

proc msgbox*(title: cstring, count: int): int {.exportc, dynlib, varargs.} =
  {.emit: """
  printf("\x1b[0m");
  fflush(stdout);
  const char* items[65536];
  va_list args;
  va_start(args, `count`);
  for (int i = 0; i < `count`; i++)
    items[i] = va_arg(args, const char*);
  va_end(args);
  int maxw = strlen(`title`);
  for (int i = 0; i < `count`; i++) {
    int l = strlen(items[i]);
    if (l > maxw) maxw = l;
  }
  maxw += 4;
  struct termios oldt, newt;
  tcgetattr(STDIN_FILENO, &oldt);
  newt = oldt;
  newt.c_lflag &= ~(ICANON | ECHO);
  tcsetattr(STDIN_FILENO, TCSANOW, &newt);
  int selected = 0;
  printf("\033[?1049h");
  fflush(stdout);
  while (1) {
    printf("\033[2J\033[H");
    fflush(stdout);
    printf("+");
    for (int i = 0; i < maxw; i++) printf("-");
    printf("+\n");
    printf("| \033[1m%-*s\033[0m |\n", maxw - 2, `title`);
    for (int i = 0; i < `count`; i++) {
      printf("+");
      for (int j = 0; j < maxw; j++) printf("-");
      printf("+\n");
      if (i == selected)
        printf("| \033[7m%-*s\033[0m |\n", maxw - 2, items[i]);
      else
        printf("| %-*s |\n", maxw - 2, items[i]);
    }
    printf("+");
    for (int i = 0; i < maxw; i++) printf("-");
    printf("+\n");
    fflush(stdout);
    char c = getchar();
    if (c == '\033') {
      getchar();
      char arrow = getchar();
      if (arrow == 'A' && selected > 0) selected--;
      if (arrow == 'B' && selected < `count` - 1) selected++;
    } else if (c == '\n') {
      break;
    }
  }
  tcsetattr(STDIN_FILENO, TCSANOW, &oldt);
  printf("\033[?1049l");
  fflush(stdout);
  return selected;
  """.}

proc mvfile*(old_path: cstring, new_path: cstring) {.exportc, dynlib.} =
  moveFile($old_path, $new_path)

proc mvfolder*(old_path: cstring, new_path: cstring) {.exportc, dynlib.} =
  moveDir($old_path, $new_path)

proc randint*(minimum: int, maximum: int): int {.exportc, dynlib.} =
  randomize()
  return rand(minimum..maximum)

proc reallocbuf*(pointer1: pointer, new_size: int): pointer {.exportc, dynlib.} =
  return realloc(pointer1, new_size)

proc resetbgfg*() {.exportc, dynlib.} =
  stdout.write("\x1b[0m")
  stdout.flushFile()

proc rmfile*(path: cstring) {.exportc, dynlib.} =
  removeFile($path)

proc rmfolder*(path: cstring) {.exportc, dynlib.} =
  removeDir($path)

proc scope*(atexit: int, function: proc () {.noconv.}) {.exportc, dynlib.} =
  if atexit == 0:
    defer: function()
  elif atexit == 1:
    exitqueue.add(function)

proc setbg*(r: int, g: int, b: int) {.exportc, dynlib.} =
  stdout.write("\x1b[48;2;" & $r & ";" & $g & ";" & $b & "m")
  stdout.flushFile()

proc setfg*(r: int, g: int, b: int) {.exportc, dynlib.} =
  stdout.write("\x1b[38;2;" & $r & ";" & $g & ";" & $b & "m")
  stdout.flushFile()

proc sig*(signal: int, function: proc(_: int) {.noconv.}) {.exportc, dynlib.} =
  discard signal(cint(signal), cast[proc(_: cint) {.noconv.}](function))

proc spawnproc*(command: cstring): int {.exportc, dynlib.} =
  return int(startProcess($command).processID)

proc stdi*(visible: int): cstring {.exportc, dynlib.} =
  if visible == 0:
    return cstring(readPasswordFromStdin(prompt = ""))
  elif visible == 1:
    return cstring(readLine(stdin))

proc stdo*(string1: cstring) {.exportc, dynlib.} =
  write(stdout, string1)

proc strcomp*(string1: cstring, string2: cstring): int {.exportc, dynlib.} =
  return int(cmp(string1, string2) == 0)

proc strformat*(count: int): cstring {.exportc, dynlib, varargs.} =
  {.emit: """
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

proc tocintcstr*(value: cstring): int {.exportc, dynlib.} =
  return parseInt($value)

proc tocstrcint*(value: int): cstring {.exportc, dynlib.} =
  return cstring($value)

proc undef*(name: cstring) {.exportc, dynlib.} =
  delEnv($name)

proc wait*(milliseconds: int) {.exportc, dynlib.} =
  sleep(milliseconds)

proc where*(command: cstring): cstring {.exportc, dynlib.} =
  return cstring($execProcess("which " & $command).strip())

proc cleanup() {.noconv.} =
  cursor(1)
  discard execCmdEx("stty sane")
  resetbgfg()

addExitProc(cleanup)
