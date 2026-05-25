import std/exitprocs
import std/sequtils
import std/strutils
import std/terminal
import std/base64
import std/random
import std/posix
import std/times
import osproc
import std/os
import std/re
import math

var VERSION = "0.1.7"

{.emit: """
#include <sys/ioctl.h>
#include <pthread.h>
#include <termios.h>
#include <signal.h>
#include <stdarg.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <stdio.h>
#include <time.h>
#define MAX_THREADS 65536
static pthread_t thread_handles[MAX_THREADS];
static void* thread_fns[MAX_THREADS];
static int thread_count = 0;
#define MAX_JOBS 65536
static pthread_t job_handles[MAX_JOBS];
static void* job_fns[MAX_JOBS];
static int job_active[MAX_JOBS];
static int job_count = 0;
typedef struct { void (*fn)(); int ms; int repeat; int* active; } JobArgs;
static void* job_runner(void* arg) {
  JobArgs* a = (JobArgs*)arg;
  do {
    usleep(a->ms * 1000);
    if (*a->active)
      a->fn();
  } while (a->repeat && *a->active);
  free(a);
  return NULL;
}
#define MAX_TIMERS 65536
typedef struct { const char* name; struct timespec start; } Timer;
static Timer timers[MAX_TIMERS];
static int timer_count = 0;
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

proc cron*(milliseconds: int, function: proc() {.noconv.}) {.exportc, dynlib.} =
  {.emit: """
  int idx = job_count;
  job_active[idx] = 1;
  job_fns[idx] = (void*)`function`;
  JobArgs* args = (JobArgs*)malloc(sizeof(JobArgs));
  args->fn = (void(*)())`function`;
  args->ms = `milliseconds`;
  args->repeat = 1;
  args->active = &job_active[idx];
  pthread_create(&job_handles[idx], NULL, job_runner, args);
  job_count++;
  """.}

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

proc exec*(command: cstring): tuple[output: cstring, exit_code: int] {.exportc, dynlib.} =
  let (stdo, exit_code) = execCmdEx($command)
  return (cstring(stdo), int(exit_code))

proc fileinfo*(path: cstring): tuple[name: cstring, creator: cstring, last_edit: int, file_size: int] {.exportc, dynlib.} =
  let p = $path
  if not fileExists(p):
    return ("".cstring, "".cstring, 0, 0)
  let name = p.splitPath().tail
  let last_edit = int(getFileInfo(p).lastWriteTime.toUnix())
  let file_size = int(getFileSize(p))
  when defined(linux):
    let (creator, _) = execCmdEx("stat -c '%U' " & p)
  elif defined(bsd) or defined(macosx):
    let (creator, _) = execCmdEx("stat -f '%Su' " & p)
  return (cstring(name), cstring(creator.strip()), last_edit, file_size)

proc fileread*(path: cstring): cstring {.exportc, dynlib.} =
  return cstring(readFile($path))

proc filewrite*(path: cstring, content: cstring) {.exportc, dynlib.} =
  writeFile($path, $content)

proc find*(text: cstring, pattern: cstring): tuple[start_index: ptr UncheckedArray[int], stop_index: ptr UncheckedArray[int], length: int] {.exportc, dynlib.} =
  let t = $text
  let rePattern = re($pattern)
  var starts: seq[int]
  var stops: seq[int]
  var offset = 0
  while offset < t.len:
    let bounds = findBounds(t, rePattern, start = offset)
    if bounds.first < 0:
      break
    starts.add(bounds.first)
    stops.add(bounds.last)
    offset = bounds.last + 1
  starts.add(0)
  stops.add(0)
  return (cast[ptr UncheckedArray[int]](addr starts[0]), cast[ptr UncheckedArray[int]](addr stops[0]), starts.len.int - 1)

proc folderinfo*(path: cstring): tuple[name: cstring, creator: cstring, last_edit: int, folder_size: int] {.exportc, dynlib.} =
  let p = $path
  if not dirExists(p):
    return ("".cstring, "".cstring, 0, 0)
  let name = p.splitPath().tail
  let last_edit = int(getFileInfo(p).lastWriteTime.toUnix())
  var folder_size: int = 0
  for file in walkDirRec(p):
    folder_size += int(getFileSize(file))
  when defined(linux):
    let (creator, _) = execCmdEx("stat -c '%U' " & p)
  elif defined(bsd) or defined(macosx):
    let (creator, _) = execCmdEx("stat -f '%Su' " & p)
  result = (cstring(name), cstring(creator.strip()), last_edit, folder_size)

proc freebuf*(pointer1: pointer) {.exportc, dynlib.} =
  dealloc(pointer1)

proc getargs*(): tuple[args: ptr UncheckedArray[cstring], length: int] {.exportc, dynlib.} =
  var a: seq[cstring]
  when defined(linux):
    let cmdline = readFile("/proc/self/cmdline")
    let parts = cmdline.split('\0')
    for i in 1..<parts.len:
      if parts[i].len > 0:
        a.add(cstring(parts[i]))
  elif defined(bsd) or defined(macosx):
    let output = execProcess("sysctl -n kern.proc.args " & $getCurrentProcessId())
    for arg in output.splitWhitespace():
      a.add(cstring(arg))
  if a.len == 0:
    a.add(cstring(""))
  result = (cast[ptr UncheckedArray[cstring]](addr a[0]), a.len.int)

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

proc getermsize*(): tuple[colums: int, rows: int] {.exportc, dynlib.} =
  {.emit: """
  struct winsize ws;
  int cols = 80;
  int rows = 24;
  if (ioctl(1, TIOCGWINSZ, &ws) == 0) {
    cols = ws.ws_col;
    rows = ws.ws_row;
    if (cols <= 0) cols = 80;
    if (rows <= 0) rows = 24;
  }
  `result`.Field0 = cols;
  `result`.Field1 = rows;
  """.}

proc halt*(atexit: int, exit_code: int) {.exportc, dynlib.} =
  if atexit == 0:
    {.emit: """
    _exit(`exit_code`);
    """.}
  elif atexit == 1:
    quit(exit_code)

proc has*(text: cstring, pattern: cstring): int {.exportc, dynlib.} =
  let t = $text
  if t.contains(re($pattern)):
    return 1
  return 0

proc isdef*(name: cstring): int {.exportc, dynlib.} =
  return int(existsEnv($name) == true)

proc isfile*(path: cstring): int {.exportc, dynlib.} =
  return int(fileExists($path) == true)

proc isfolder*(path: cstring): int {.exportc, dynlib.} =
  return int(dirExists($path) == true)

proc isroot*(): int {.exportc, dynlib.} =
  return int(isAdmin() == true)

proc killjob*(function: proc() {.noconv.}) {.exportc, dynlib.} =
  {.emit: """
  for (int i = 0; i < job_count; i++) {
    if (job_fns[i] == (void*)`function`) {
      job_active[i] = 0;
      pthread_join(job_handles[i], NULL);
      job_fns[i] = NULL;
      break;
    }
  }
  """.}

proc killproc*(process_id: int) {.exportc, dynlib.} =
  discard kill(Pid(process_id), SIGKILL)

proc killthr*(function: proc() {.noconv.}) {.exportc, dynlib.} =
  {.emit: """
  for (int i = 0; i < thread_count; i++) {
    if (thread_fns[i] == (void*)`function`) {
      pthread_cancel(thread_handles[i]);
      break;
    }
  }
  """.}

proc ladefs*(): tuple[name: ptr UncheckedArray[cstring], value: ptr UncheckedArray[cstring], length: int] {.exportc, dynlib.} =
  var n: seq[cstring]
  var v: seq[cstring]
  for key, val in envPairs():
    n.add(cstring(key))
    v.add(cstring(val))
  return (cast[ptr UncheckedArray[cstring]](addr n[0]), cast[ptr UncheckedArray[cstring]](addr v[0]), n.len.int)

proc laprocs*(): tuple[name: ptr UncheckedArray[cstring], process_id: ptr UncheckedArray[int], length: int] {.exportc, dynlib.} =
  var p: seq[string]
  var n: seq[string]
  when defined(linux):
    let output = execProcess("ps -eo pid,comm --no-headers")
  elif defined(bsd) or defined(macosx):
    let output = execProcess("ps -eo pid,comm")
  for line in output.splitLines():
    let stripped = line.strip()
    if stripped.len == 0:
      continue
    let parts = stripped.splitWhitespace()
    if parts.len >= 2:
      when defined(linux):
        p.add(parts[0])
        n.add(parts[1])
      elif defined(bsd) or defined(macosx):
        if parts[0] != "PID":
          p.add(parts[0])
          n.add(parts[1])
  var nc = n.mapIt(cstring(it))
  var pc = p.mapIt(parseInt(it))
  var cnc = cast[ptr UncheckedArray[cstring]](addr nc[0])
  var cpc = cast[ptr UncheckedArray[int]](addr pc[0])
  echo cnc[1], " - ", cpc[1]
  return (cast[ptr UncheckedArray[cstring]](addr nc[0]), cast[ptr UncheckedArray[int]](addr pc[0]), nc.len.int)

proc lf*(): tuple[paths: ptr UncheckedArray[cstring], type_of: ptr UncheckedArray[cstring], length: int] {.exportc, dynlib.} =
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

proc mvfile*(old_path: cstring, new_path: cstring) {.exportc, dynlib.} =
  moveFile($old_path, $new_path)

proc mvfolder*(old_path: cstring, new_path: cstring) {.exportc, dynlib.} =
  moveDir($old_path, $new_path)

proc ping*(url: cstring): int {.exportc, dynlib.} =
  when defined(macosx):
    let (_, code) = execCmdEx("ping -c 1 -t 1 " & $url)
  elif defined(linux) or defined(bsd):
    let (_, code) = execCmdEx("ping -c 1 -W 1 " & $url)
  return int(code == 0)

proc procinfo*(process_id: int): tuple[name: cstring, process_id: int, parent_process_id: int, user_name: cstring, start_time: int, command: cstring] {.exportc, dynlib.} =
  when defined(linux):
    let output = execProcess("ps -p " & $process_id & " -o comm,pid,ppid,user,etimes,cmd --no-headers")
    let line = output.strip()
    let parts = line.splitWhitespace(maxsplit=5)
  elif defined(bsd) or defined(macosx):
    let output = execProcess("ps -p " & $process_id & " -o comm,pid,ppid,user,etimes,command")
    let lines = output.strip().splitLines()
    let line = if lines.len > 1: lines[1] else: ""
    let parts = line.splitWhitespace(maxsplit=5)
  return (cstring(parts[0]), int(parseInt(parts[1])), int(parseInt(parts[2])), cstring(parts[3]), int(int(epochTime()) - parseInt(parts[4])), cstring(parts[5]))

proc randint*(minimum: int, maximum: int): int {.exportc, dynlib.} =
  randomize()
  return rand(minimum..maximum)

proc reallocbuf*(pointer1: pointer, new_size: int): pointer {.exportc, dynlib.} =
  return realloc(pointer1, new_size)

proc replacing*(text: cstring, pattern: cstring, replacement: cstring): cstring {.exportc, dynlib.} =
  let rePattern = re($pattern)
  return cstring(replace($text, rePattern, $replacement))

proc resetbgfg*() {.exportc, dynlib.} =
  stdout.write("\x1b[0m")
  stdout.flushFile()

proc rmfile*(path: cstring) {.exportc, dynlib.} =
  removeFile($path)

proc rmfolder*(path: cstring) {.exportc, dynlib.} =
  removeDir($path)

proc schedule*(milliseconds: int, function: proc() {.noconv.}) {.exportc, dynlib.} =
  {.emit: """
  int idx = job_count;
  job_active[idx] = 1;
  job_fns[idx] = (void*)`function`;
  JobArgs* args = (JobArgs*)malloc(sizeof(JobArgs));
  args->fn = (void(*)())`function`;
  args->ms = `milliseconds`;
  args->repeat = 0;
  args->active = &job_active[idx];
  pthread_create(&job_handles[idx], NULL, job_runner, args);
  job_count++;
  """.}

proc scope*(atexit: int, function: proc() {.noconv.}) {.exportc, dynlib.} =
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

proc sig*(signal: int, function: proc() {.noconv.}) {.exportc, dynlib.} =
  signal(cint(signal), cast[proc(_: cint) {.noconv.}](function))

proc spawnproc*(command: cstring): int {.exportc, dynlib.} =
  return int(startProcess($command).processID)

proc spawnthr*(function: proc() {.noconv.}) {.exportc, dynlib.} =
  {.emit: """
  pthread_t t;
  pthread_create(&t, NULL, (void*(*)(void*))`function`, NULL);
  thread_handles[thread_count] = t;
  thread_fns[thread_count] = (void*)`function`;
  thread_count++;
  """.}

proc splitting*(text: cstring, pattern: cstring): tuple[parts: ptr UncheckedArray[cstring], length: int] {.exportc, dynlib.} =
  let t = $text
  let rePattern = re($pattern)
  var storage: seq[string]
  var parts: seq[cstring]
  var offset = 0
  while offset < t.len:
    let bounds = findBounds(t, rePattern, start = offset)
    if bounds.first < 0:
      break
    storage.add(t[offset..bounds.first - 1])
    offset = bounds.last + 1
  storage.add(t[offset..^1])
  storage.add("")
  for s in storage.mitems:
    parts.add(cstring(s))
  return (cast[ptr UncheckedArray[cstring]](addr parts[0]), parts.len.int - 1)

proc stdi*(visible: int): cstring {.exportc, dynlib.} =
  if visible == 0:
    return cstring(readPasswordFromStdin(prompt = ""))
  elif visible == 1:
    return cstring(readLine(stdin))

proc stdo*(string1: cstring) {.exportc, dynlib.} =
  stdout.write(string1)
  stdout.flushFile()

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

proc strsize*(string1: cstring): int {.exportc, dynlib.} =
  return int(len($string1))

proc syncthr*(function: proc() {.noconv.}) {.exportc, dynlib.} =
  {.emit: """
  for (int i = 0; i < thread_count; i++) {
    if (thread_fns[i] == (void*)`function`) {
      pthread_join(thread_handles[i], NULL);
      thread_fns[i] = NULL;
      break;
    }
  }
  """.}

proc timern*(): float {.exportc, dynlib.} =
  return epochTime()

proc timerstart*(name: cstring) {.exportc, dynlib.} =
  {.emit: """
  for (int i = 0; i < timer_count; i++) {
    if (strcmp(timers[i].name, `name`) == 0) {
      clock_gettime(CLOCK_MONOTONIC, &timers[i].start);
      return;
    }
  }
  timers[timer_count].name = `name`;
  clock_gettime(CLOCK_MONOTONIC, &timers[timer_count].start);
  timer_count++;
  """.}

proc timerstop*(name: cstring): int {.exportc, dynlib.} =
  {.emit: """
  struct timespec end;
  clock_gettime(CLOCK_MONOTONIC, &end);
  for (int i = 0; i < timer_count; i++) {
    if (strcmp(timers[i].name, `name`) == 0) {
      long ms = (end.tv_sec - timers[i].start.tv_sec) * 1000 + (end.tv_nsec - timers[i].start.tv_nsec) / 1000000;
      `result` = ms;
      return;
    }
  }
  `result` = -1;
  """.}

proc tob64str*(forurl: int, value: cstring, key: cstring): cstring {.exportc, dynlib.} =
  let vLen = value.len
  let kLen = key.len
  var buf = newString(vLen)
  for i in 0 ..< vLen:
    buf[i] = value[i]
  for i in 0 ..< vLen:
    buf[i] = char(uint8(buf[i]) xor uint8(key[i mod kLen]))
  for i in 0 ..< vLen:
    let b = uint8(buf[i])
    buf[i] = char((b shl 3) or (b shr 5))
  for i in 0 ..< vLen:
    buf[i] = char(uint8(buf[i]) xor uint8(key[(kLen - 1) - (i mod kLen)]))
  for i in 0 ..< vLen:
    let b = uint8(buf[i])
    buf[i] = char((b shr 2) or (b shl 6))
  for i in 0 ..< vLen - 1:
    buf[i] = char(uint8(buf[i]) xor uint8(buf[i + 1]))
  for i in 0 ..< vLen:
    let b = uint8(buf[i])
    let rotated = char((b shl 5) or (b shr 3))
    buf[i] = char(uint8(rotated) xor uint8(key[i mod kLen]) xor uint8(i and 0xFF))
  for i in 0 ..< vLen:
    let b = uint8(buf[i])
    let rotated = char((b shr 4) or (b shl 4))
    buf[i] = char(uint8(rotated) xor uint8(key[(kLen - 1) - (i mod kLen)]))
  if forurl == 0:
    return cstring(encode(buf, safe = false))
  if forurl == 1:
    return cstring(encode(buf, safe = true))

proc tofltint*(value: int): float {.exportc, dynlib.} =
  return float(value)

proc tofltstr*(value: cstring): float {.exportc, dynlib.} =
  return float(parseInt($value))

proc tointflt*(value: float): int {.exportc, dynlib.} =
  return int(value)

proc tointstr*(value: cstring): int {.exportc, dynlib.} =
  return parseInt($value)

proc tostrb64*(value: cstring, key: cstring): cstring {.exportc, dynlib.} =
  let decoded = decode($value)
  let vLen = decoded.len
  let kLen = key.len
  var buf = newString(vLen)
  for i in 0 ..< vLen:
    buf[i] = decoded[i]
  for i in 0 ..< vLen:
    let b = uint8(buf[i]) xor uint8(key[(kLen - 1) - (i mod kLen)])
    buf[i] = char((b shr 4) or (b shl 4))
  for i in 0 ..< vLen:
    let b = uint8(buf[i]) xor uint8(key[i mod kLen]) xor uint8(i and 0xFF)
    buf[i] = char((b shr 5) or (b shl 3))
  for i in countdown(vLen - 2, 0):
    buf[i] = char(uint8(buf[i]) xor uint8(buf[i + 1]))
  for i in 0 ..< vLen:
    let b = uint8(buf[i])
    buf[i] = char((b shl 2) or (b shr 6))
  for i in 0 ..< vLen:
    buf[i] = char(uint8(buf[i]) xor uint8(key[(kLen - 1) - (i mod kLen)]))
  for i in 0 ..< vLen:
    let b = uint8(buf[i])
    buf[i] = char((b shr 3) or (b shl 5))
  for i in 0 ..< vLen:
    buf[i] = char(uint8(buf[i]) xor uint8(key[i mod kLen]))
  return cstring(buf)

proc tostrflt*(value: float): cstring {.exportc, dynlib.} =
  return cstring($value)

proc tostrint*(value: int): cstring {.exportc, dynlib.} =
  return cstring($value)

proc undef*(name: cstring) {.exportc, dynlib.} =
  delEnv($name)

proc until*(timestamp: float) {.exportc, dynlib.} =
  if timestamp > epochTime():
    sleep(int(round((timestamp - epochTime()) * 1000.0)))

proc version*(): cstring {.exportc, dynlib.} =
  return VERSION.cstring

proc vidbuf*(mode: int) {.exportc, dynlib.} =
  {.emit: """
  if (`mode` == 0) {
    fprintf(stdout, "\033[?1049l");
  } else if (`mode` == 1) {
    fprintf(stdout, "\033[?1049h");
  }
  fflush(stdout);
  """.}

proc wait*(milliseconds: int) {.exportc, dynlib.} =
  sleep(milliseconds)

proc where*(command: cstring): cstring {.exportc, dynlib.} =
  return cstring($execProcess("which " & $command).strip())

proc cleanup() {.noconv.} =
  resetbgfg()
  cursor(1)
  {.emit: """
  for (int i = 0; i < job_count; i++) {
    if (job_active[i]) {
      job_active[i] = 0;
      pthread_join(job_handles[i], NULL);
    }
  }
  for (int i = 0; i < thread_count; i++) {
    if (thread_fns[i] != NULL) {
      pthread_cancel(thread_handles[i]);
      pthread_join(thread_handles[i], NULL);
      thread_fns[i] = NULL;
    }
  }
  """.}

scope(1, cleanup)
