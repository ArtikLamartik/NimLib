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

var VERSION = "0.2.5"

{.emit: """
#include <netinet/in.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <sys/ioctl.h>
#include <pthread.h>
#include <termios.h>
#include <signal.h>
#include <stdarg.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <netdb.h>
#include <stdio.h>
#include <time.h>
#define MAX_THREADS 131072
static pthread_t thread_handles[MAX_THREADS];
static void* thread_fns[MAX_THREADS];
static int thread_count = 0;
#define MAX_JOBS 131072
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
#define MAX_TIMERS 131072
typedef struct { const char* name; struct timespec start; } Timer;
static Timer timers[MAX_TIMERS];
static int timer_count = 0;
static int sock_server_fd = -1;
static int sock_client_fd = -1;
static int sock_conn_fd = -1;
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

proc cpfile*(source: cstring, destination: cstring) {.exportc, dynlib.} =
  let src = $source
  let dst = $destination
  let filename = src.splitPath().tail
  if dirExists(dst):
    copyFile(src, dst / filename)
  else:
    copyFile(src, dst)

proc cpfolder*(source: cstring, destination: cstring) {.exportc, dynlib.} =
  let src = $source
  let dst = $destination
  let foldername = src.splitPath().tail
  copyDir(src, dst / foldername)

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

proc execlive*(command: cstring) {.exportc, dynlib.} =
  discard execCmd($command)

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
  var args: seq[string]
  when defined(linux):
    let cmdline = readFile("/proc/self/cmdline")
    let parts = cmdline.split('\0')
    for i in 1..<parts.len:
      if parts[i].len > 0:
        args.add(parts[i])
  elif defined(bsd) or defined(macosx):
    let output = execProcess("sysctl -n kern.proc.args " & $getCurrentProcessId())
    for arg in output.splitWhitespace():
      args.add(arg)
  if args.len == 0:
    args.add("")
  var args_cstr = args.mapIt(cstring(it))
  result = (cast[ptr UncheckedArray[cstring]](addr args_cstr[0]), args.len.int)

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
  var names: seq[string]
  var values: seq[string]
  for key, val in envPairs():
    names.add(key)
    values.add(val)
  var names_cstr = names.mapIt(cstring(it))
  var values_cstr = values.mapIt(cstring(it))
  return (cast[ptr UncheckedArray[cstring]](addr names_cstr[0]), cast[ptr UncheckedArray[cstring]](addr values_cstr[0]), names_cstr.len.int)

proc laprocs*(): tuple[name: ptr UncheckedArray[cstring], process_id: ptr UncheckedArray[int], length: int] {.exportc, dynlib.} =
  var process_ids: seq[string]
  var names: seq[string]
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
        process_ids.add(parts[0])
        names.add(parts[1])
      elif defined(bsd) or defined(macosx):
        if parts[0] != "PID":
          process_ids.add(parts[0])
          names.add(parts[1])
  var names_cstr = names.mapIt(cstring(it))
  var process_ids_int = process_ids.mapIt(parseInt(it))
  return (cast[ptr UncheckedArray[cstring]](addr names_cstr[0]), cast[ptr UncheckedArray[int]](addr process_ids_int[0]), names_cstr.len.int)

proc lf*(): tuple[paths: ptr UncheckedArray[cstring], type_of: ptr UncheckedArray[cstring], length: int] {.exportc, dynlib.} =
  var paths: seq[string]
  var types: seq[string]
  for entry in walkDir(getCurrentDir()):
    if entry.kind == pcFile:
      paths.add(entry.path)
      types.add("file")
    elif entry.kind == pcDir:
      paths.add(entry.path)
      types.add("folder")
  var paths_cstr = paths.mapIt(cstring(it))
  var types_cstr = types.mapIt(cstring(it))
  return (cast[ptr UncheckedArray[cstring]](addr paths_cstr[0]), cast[ptr UncheckedArray[cstring]](addr types_cstr[0]), paths_cstr.len.int)

proc lowstr*(text: cstring): cstring =
  return cstring(toLower($text))

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

proc randflt*(minimum: float, maximum: float): float {.exportc, dynlib.} =
  randomize()
  return rand(minimum..maximum)

proc randint*(minimum: int, maximum: int): int {.exportc, dynlib.} =
  randomize()
  return rand(minimum..maximum)

proc reallocbuf*(pointer1: pointer, new_size: int): pointer {.exportc, dynlib.} =
  return realloc(pointer1, new_size)

proc replacestr*(text: cstring, pattern: cstring, replacement: cstring): cstring {.exportc, dynlib.} =
  let rePattern = re($pattern)
  return cstring(replace($text, rePattern, $replacement))

proc repstr*(text: cstring, count: int): cstring {.exportc, dynlib.} =
  return cstring(repeat($text, count))

proc resetbgfg*() {.exportc, dynlib.} =
  stdout.write("\x1b[0m")
  stdout.flushFile()

proc revstr*(text: cstring): cstring {.exportc, dynlib.} =
  var t = $text
  for i in 0..<t.len div 2:
    swap(t[i], t[t.len - 1 - i])
  return cstring(t)

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

proc search*(text: cstring, pattern: cstring): tuple[matches: ptr UncheckedArray[cstring], length: int] {.exportc, dynlib.} =
  var find_matches: seq[string]
  let t = $text
  let rePattern = re($pattern)
  for m in findAll(t, rePattern):
    find_matches.add(m)
  if find_matches.len == 0:
    find_matches.add("")
  var matches_cstr = find_matches.mapIt(cstring(it))
  return (cast[ptr UncheckedArray[cstring]](addr matches_cstr[0]), find_matches.len.int)

proc setbg*(r: int, g: int, b: int) {.exportc, dynlib.} =
  stdout.write("\x1b[48;2;" & $r & ";" & $g & ";" & $b & "m")
  stdout.flushFile()

proc setfg*(r: int, g: int, b: int) {.exportc, dynlib.} =
  stdout.write("\x1b[38;2;" & $r & ";" & $g & ";" & $b & "m")
  stdout.flushFile()

proc sig*(signal: int, function: proc() {.noconv.}) {.exportc, dynlib.} =
  signal(cint(signal), cast[proc(_: cint) {.noconv.}](function))

proc sockacc*(): cstring {.exportc, dynlib.} =
  {.emit: """
  struct sockaddr_in client_addr;
  socklen_t client_len = sizeof(client_addr);
  sock_conn_fd = accept(sock_server_fd, (struct sockaddr*)&client_addr, &client_len);
  `result` = inet_ntoa(client_addr.sin_addr);
  """.}

proc sockclose*() {.exportc, dynlib.} =
  {.emit: """
  if (sock_conn_fd != -1) { close(sock_conn_fd); sock_conn_fd = -1; }
  if (sock_server_fd != -1) { close(sock_server_fd); sock_server_fd = -1; }
  """.}

proc sockcon*(ipaddress: cstring, port: int) {.exportc, dynlib.} =
  {.emit: """
  struct sockaddr_in addr;
  sock_client_fd = socket(AF_INET, SOCK_STREAM, 0);
  addr.sin_family = AF_INET;
  addr.sin_port = htons(`port`);
  inet_pton(AF_INET, `ipaddress`, &addr.sin_addr);
  connect(sock_client_fd, (struct sockaddr*)&addr, sizeof(addr));
  """.}

proc sockdiscon*() {.exportc, dynlib.} =
  {.emit: """
  if (sock_client_fd != -1) { close(sock_client_fd); sock_client_fd = -1; }
  """.}

proc sockopen*(port: int): cstring {.exportc, dynlib.} =
  {.emit: """
  struct sockaddr_in addr;
  socklen_t addrlen = sizeof(addr);
  sock_server_fd = socket(AF_INET, SOCK_STREAM, 0);
  int opt = 1;
  setsockopt(sock_server_fd, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(opt));
  addr.sin_family = AF_INET;
  addr.sin_addr.s_addr = INADDR_ANY;
  addr.sin_port = htons(`port`);
  bind(sock_server_fd, (struct sockaddr*)&addr, sizeof(addr));
  listen(sock_server_fd, 1);
  struct sockaddr_in client_addr;
  socklen_t client_len = sizeof(client_addr);
  sock_conn_fd = accept(sock_server_fd, (struct sockaddr*)&client_addr, &client_len);
  `result` = inet_ntoa(client_addr.sin_addr);
  """.}

proc sockrecv*(): cstring {.exportc, dynlib.} =
  {.emit: """
  int fd = (sock_conn_fd != -1) ? sock_conn_fd : sock_client_fd;
  if (fd == -1) { `result` = ""; return; }
  size_t total = 0;
  size_t capacity = 131072;
  char* buf = (char*)malloc(capacity);
  if (!buf) { `result` = ""; return; }
  while (1) {
    if (total >= capacity - 1) {
      capacity *= 2;
      char* newbuf = (char*)realloc(buf, capacity);
      if (!newbuf) { free(buf); `result` = ""; return; }
      buf = newbuf;
    }
    int n = recv(fd, buf + total, capacity - total - 1, 0);
    if (n <= 0) break;
    total += n;
    int available = 0;
    ioctl(fd, FIONREAD, &available);
    if (available == 0) break;
  }
  buf[total] = '\0';
  `result` = buf;
  """.}

proc socksend*(data: cstring) {.exportc, dynlib.} =
  {.emit: """
  int fd = (sock_conn_fd != -1) ? sock_conn_fd : sock_client_fd;
  if (fd != -1) send(fd, `data`, strlen(`data`), 0);
  """.}

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

proc splitstr*(text: cstring, pattern: cstring): tuple[parts: ptr UncheckedArray[cstring], length: int] {.exportc, dynlib.} =
  let t = $text
  let rePattern = re($pattern)
  var storage: seq[string]
  var parts: seq[string]
  var offset = 0
  while offset < t.len:
    let bounds = findBounds(t, rePattern, start = offset)
    if bounds.first < 0:
      break
    storage.add(t[offset..bounds.first - 1])
    offset = bounds.last + 1
  storage.add(t[offset..^1])
  storage.add("")
  for t in storage.mitems:
    parts.add(t)
  var parts_cstr = parts.mapIt(cstring(it))
  return (cast[ptr UncheckedArray[cstring]](addr parts_cstr[0]), parts_cstr.len.int - 1)

proc stdi*(visible: int): cstring {.exportc, dynlib.} =
  if visible == 0:
    return cstring(readPasswordFromStdin(prompt = ""))
  elif visible == 1:
    return cstring(readLine(stdin))

proc stdo*(text: cstring) {.exportc, dynlib.} =
  stdout.write(text)
  stdout.flushFile()

proc strcomp*(text1: cstring, text2: cstring): int {.exportc, dynlib.} =
  return int(cmp(text1, text2) == 0)

proc strformat*(count: int): cstring {.exportc, dynlib, varargs.} =
  {.emit: """
  static char buf[131072];
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

proc strinsert*(text1: cstring, text2: cstring, index: int): cstring {.exportc, dynlib.} =
  var t1 = $text1
  var t2 = $text2
  var idx = index
  if idx < 0:
    idx = 0
  elif idx > t1.len:
    idx = t1.len
  t1.insert(t2, idx)
  return cstring(t1)

proc strsize*(text: cstring): int {.exportc, dynlib.} =
  return int(len($text))

proc substr*(text: cstring, start_index: int, stop_index: int): cstring {.exportc, dynlib.} =
  var t = $text
  var strt_index = 0
  var stp_index = t.len - 1
  if start_index >= 0:
    strt_index = start_index
  if stop_index <= t.len:
    stp_index = stop_index
  return cstring(t[strt_index..stp_index])

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

proc timeformat*(timestamp: float, format: cstring): cstring {.exportc, dynlib.} =
  let t = fromUnix(int(timestamp))
  return cstring(t.format($format))

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

proc tohexstr*(value: cstring): cstring {.exportc, dynlib.} =
  var v = $value
  return cstring(v.toHex())

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

proc tostrhex*(value: cstring): cstring {.exportc, dynlib.} =
  var v = $value
  var str = ""
  for i in countup(0, v.len - 2, 2):
    str.add(char(parseHexInt(v[i..i+1])))
  return cstring(str)

proc tostrint*(value: int): cstring {.exportc, dynlib.} =
  return cstring($value)

proc trimstr*(text: cstring, sides: int, pattern: cstring): cstring {.exportc, dynlib.} =
  let t = $text
  let p = $pattern
  if sides == 0:
    return cstring(t.replacef(re("^(?:" & p & ")"), "").replacef(re("(?:" & p & ")$"), ""))
  elif sides == 1:
    return cstring(t.replacef(re("^(?:" & p & ")"), ""))
  elif sides == 2:
    return cstring(t.replacef(re("(?:" & p & ")$"), ""))

proc undef*(name: cstring) {.exportc, dynlib.} =
  delEnv($name)

proc until*(timestamp: float) {.exportc, dynlib.} =
  if timestamp > epochTime():
    sleep(int(round((timestamp - epochTime()) * 1000.0)))

proc upstr*(text: cstring): cstring {.exportc, dynlib.} =
  return cstring(toUpper($text))

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
