# NimLib - A Library made in Nim

[***Only works on `Linux`, `MacOS` and `BSD`***]

> **Reminder:** If you are on `Linux` or `BSD`, use the `nimlib.so`. But if you are on `MacOS`, use the `nimlib.dynlib`.

> **Note:** If you are on `Windows`, use `WSL`.

Version `0.3.1`

## NimLib Documentation

#### **Name:** `allocbuf`

**Arguments:**
```c
long size
```

**Return:**
```c
void*
```

**Description:** Allocates a raw memory buffer of the given byte size. Free it with `freebuf`.

---

#### **Name:** `broadcasthr`

**Arguments:**
```c
void* cond
```

**Return:**
```c
void
```

**Description:** It broadcasts a signal to all threads.

---

#### **Name:** `cf`

**Arguments:**
```c
const char* path
```

**Return:**
```c
void
```

**Description:** Changes the current working folder to the given path.

---

#### **Name:** `clrscr`

**Arguments:**
```c
void
```

**Return:**
```c
void
```

**Description:** Clears the terminal screen.

---

#### **Name:** `condthr`

**Arguments:**
```c
void
```

**Return:**
```c
void*
```

**Description:** Creates a condition variable for a thread.

---

#### **Name:** `cpfile`

**Arguments:**
```c
const char* source, const char* destination
```

**Return:**
```c
void
```

**Description:** Copies a file from `source` to `destination`.

---

#### **Name:** `cpfolder`

**Arguments:**
```c
const char* source, const char* destination
```

**Return:**
```c
void
```

**Description:** Copies a folder from `source` into `destination`, including the folder itself.

---

#### **Name:** `cron`

**Arguments:**
```c
long milliseconds, void (*function)(void)
```

**Return:**
```c
void
```

**Description:** Schedules a function to run repeatedly on the given interval of milliseconds. Runs until `killjob` is called with the same function.

---

#### **Name:** `cursor`

**Arguments:**
```c
long visible
```

**Return:**
```c
void
```

**Description:** Shows or hides the terminal cursor. `0` = hide, `1` = show.

---

#### **Name:** `cursorto`

**Arguments:**
```c
long x, long y
```

**Return:**
```c
void
```

**Description:** Moves the terminal cursor to the given column and row (0-indexed).

---

#### **Name:** `def`

**Arguments:**
```c
const char* name, const char* value
```

**Return:**
```c
void
```

**Description:** Sets an environment variable by name.

---

#### **Name:** `exec`

**Arguments:**
```c
const char* command
```

**Return:**
```c
Exec
```

**Exec:**
```c
typedef struct {
    const char* output;
    long        exit_code;
} Exec;
```

**Description:** Runs a shell command synchronously and returns its stdout output and exit code.

---

#### **Name:** `execlive`

**Arguments:**
```c
const char* command
```

**Return:**
```c
void
```

**Description:** Runs a shell command synchronously and live in the terminal/console.

---

#### **Name:** `fileinfo`

**Arguments:**
```c
const char* path
```

**Return:**
```c
Fileinfo
```

**Fileinfo:**
```c
typedef struct {
    const char* name;
    const char* creator;
    long        last_edit;
    long        file_size;
} Fileinfo;
```

**Description:** Returns metadata for a file: base name, owning user, last modification time (Unix timestamp), and size in bytes. Returns empty/zero values if the file does not exist.

---

#### **Name:** `fileread`

**Arguments:**
```c
const char* path
```

**Return:**
```c
const char*
```

**Description:** Reads the entire contents of a file and returns it as a string.

---

#### **Name:** `filewrite`

**Arguments:**
```c
const char* path, const char* content
```

**Return:**
```c
void
```

**Description:** Writes a string to a file, overwriting any existing content.

---

#### **Name:** `folderinfo`

**Arguments:**
```c
const char* path
```

**Return:**
```c
Folderinfo
```

**Folderinfo:**
```c
typedef struct {
    const char* name;
    const char* creator;
    long        last_edit;
    long        folder_size;
} Folderinfo;
```

**Description:** Returns metadata for a folder: base name, owning user, last modification time (Unix timestamp), and total recursive size in bytes. Returns empty/zero values if the folder does not exist.

---

#### **Name:** `freebuf`

**Arguments:**
```c
void* pointer1
```

**Return:**
```c
void
```

**Description:** Frees a memory buffer previously allocated with `allocbuf`.

---

#### **Name:** `getargs`

**Arguments:**
```c
void
```

**Return:**
```c
Getargs
```

**Getargs:**
```c
typedef struct {
    const char** args;
    long         length;
} Getargs;
```

**Description:** Returns the command-line arguments passed to the current process, excluding `argv[0]`.

---

#### **Name:** `getcf`

**Arguments:**
```c
void
```

**Return:**
```c
const char*
```

**Description:** Returns the current working folder as a string.

---

#### **Name:** `getchr`

**Arguments:**
```c
void
```

**Return:**
```c
const char*
```

**Description:** Reads a single keypress from stdin without echoing it and returns it as a string.

---

#### **Name:** `getcpid`

**Arguments:**
```c
void
```

**Return:**
```c
long
```

**Description:** Returns the process ID of the current process.

---

#### **Name:** `getdef`

**Arguments:**
```c
const char* name
```

**Return:**
```c
const char*
```

**Description:** Gets the value of an environment variable. Returns an empty string if not set.

---

#### **Name:** `getip`

**Arguments:**
```c
void
```

**Return:**
```c
const char*
```

**Description:** Returns the IP of the caller.

---

#### **Name:** `getprogloc`

**Arguments:**
```c
void
```

**Return:**
```c
const char*
```

**Description:** Returns the full path of the currently running executable.

---

#### **Name:** `getermsize`

**Arguments:**
```c
void
```

**Return:**
```c
Getermsize
```

**Getermsize:**
```c
typedef struct {
    long columns;
    long rows;
} Getermsize;
```

**Description:** Returns the current terminal dimensions. Defaults to 80×24 if the size cannot be determined.

---

#### **Name:** `halt`

**Arguments:**
```c
long atexit, long exit_code
```

**Return:**
```c
void
```

**Description:** Terminates the process immediately with the given exit code. If `atexit` is `0` then it exits hardly, exits softly if `1` and it will wait for threads if `2`.

---

#### **Name:** `has`

**Arguments:**
```c
const char* text, const char* pattern
```

**Return:**
```c
long
```

**Description:** Returns `1` if the string contains a match for the regular expression pattern, `0` otherwise.

---

#### **Name:** `httpget`

**Arguments:**
```c
const char* url
```

**Return:**
```c
const char*
```

**Description:** Returns the content of a public website or ipaddress.

---

#### **Name:** `httpost`

**Arguments:**
```c
const char* url, const char* body, const char* content_type
```

**Return:**
```c
const char*
```

**Description:** Sends a `POST` request to a public website or ipaddress.

---

#### **Name:** `httpserver`

**Arguments:**
```c
long port, const char* (*function)(const char* pth, const char* mth, const char* bdy)
```

**Return:**
```c
void
```

**Description:** Starts a webserver on the caller's IP address at the specified `port` and `handle-function`, that will handle the requests. `pth` is the path of the request, `mth` is the method they used to request and the `bdy` is the body of the request.

---

#### **Name:** `isdef`

**Arguments:**
```c
const char* name
```

**Return:**
```c
long
```

**Description:** Returns `1` if the environment variable is set, `0` otherwise.

---

#### **Name:** `isfile`

**Arguments:**
```c
const char* path
```

**Return:**
```c
long
```

**Description:** Returns `1` if the path exists and is a file, `0` otherwise.

---

#### **Name:** `isfolder`

**Arguments:**
```c
const char* path
```

**Return:**
```c
long
```

**Description:** Returns `1` if the path exists and is a folder, `0` otherwise.

---

#### **Name:** `isroot`

**Arguments:**
```c
void
```

**Return:**
```c
long
```

**Description:** Returns `1` if the process is running with root/administrator privileges, `0` otherwise.

---

#### **Name:** `killjob`

**Arguments:**
```c
void (*function)(void)
```

**Return:**
```c
void
```

**Description:** Stops a repeating job started with `cron`, matched by function pointer. Waits for the job to finish before returning.

---

#### **Name:** `killproc`

**Arguments:**
```c
long process_id
```

**Return:**
```c
void
```

**Description:** Sends `SIGKILL` to the given PID, terminating it immediately.

---

#### **Name:** `killthr`

**Arguments:**
```c
void (*function)(void)
```

**Return:**
```c
void
```

**Description:** Cancels a running thread identified by its function pointer.

---

#### **Name:** `ladefs`

**Arguments:**
```c
void
```

**Return:**
```c
Ladefs
```

**Ladefs:**
```c
typedef struct {
    const char** name;
    const char** value;
    long         length;
} Ladefs;
```

**Description:** Returns all current environment variables as parallel arrays of names and values.

---

#### **Name:** `laprocs`

**Arguments:**
```c
void
```

**Return:**
```c
Laprocs
```

**Laprocs:**
```c
typedef struct {
    const char** name;
    long*        process_id;
    long         length;
} Laprocs;
```

**Description:** Returns a snapshot of all running processes as parallel arrays of names and PIDs.

---

#### **Name:** `lf`

**Arguments:**
```c
void
```

**Return:**
```c
Lf
```

**Lf:**
```c
typedef struct {
    const char** paths;
    const char** type_of;
    long         length;
} Lf;
```

**Description:** Lists the contents of the current folder. `type_of` values are `"file"` or `"folder"`.

---

#### **Name:** `lockthr`

**Arguments:**
```c
void* mutex
```

**Return:**
```c
void
```

**Description:** Locks a thread with the specified mutex.

---

#### **Name:** `lowstr`

**Arguments:**
```c
const char* text
```

**Return:**
```c
const char*
```

**Description:** Converts a string to lowercase.

---

#### **Name:** `mcopy`

**Arguments:**
```c
const char* source, void* destination, long size
```

**Return:**
```c
void
```

**Description:** Copies `size` bytes from `source` into `destination`. The destination must be pre-allocated.

---

#### **Name:** `mkfile`

**Arguments:**
```c
const char* path
```

**Return:**
```c
void
```

**Description:** Creates an empty file at the given path.

---

#### **Name:** `mkfolder`

**Arguments:**
```c
const char* path
```

**Return:**
```c
void
```

**Description:** Creates a folder (and any necessary parent directories) at the given path.

---

#### **Name:** `mutexthr`

**Arguments:**
```c
void
```

**Return:**
```c
void*
```

**Description:** Creates a mutex.

---

#### **Name:** `mvfile`

**Arguments:**
```c
const char* old_path, const char* new_path
```

**Return:**
```c
void
```

**Description:** Moves or renames a file.

---

#### **Name:** `mvfolder`

**Arguments:**
```c
const char* old_path, const char* new_path
```

**Return:**
```c
void
```

**Description:** Moves or renames a folder.

---

#### **Name:** `ping`

**Arguments:**
```c
const char* url
```

**Return:**
```c
long
```

**Description:** Sends a single ICMP ping to the given host. Returns `1` if it responds, `0` otherwise. Timeout is 1 second.

---

#### **Name:** `procinfo`

**Arguments:**
```c
long process_id
```

**Return:**
```c
Procinfo
```

**Procinfo:**
```c
typedef struct {
    const char* name;
    long        process_id;
    long        parent_process_id;
    const char* user_name;
    long        start_time;
    const char* command;
} Procinfo;
```

**Description:** Returns details about a running process: name, PID, parent PID, owning user, start time (Unix timestamp), and full command string.

---

#### **Name:** `randflt`

**Arguments:**
```c
double minimum, double maximum
```

**Return:**
```c
double
```

**Description:** Returns a random float in the inclusive range `[minimum, maximum]`.

---

#### **Name:** `randint`

**Arguments:**
```c
long minimum, long maximum
```

**Return:**
```c
long
```

**Description:** Returns a random integer in the inclusive range `[minimum, maximum]`.

---

#### **Name:** `reallocbuf`

**Arguments:**
```c
void* pointer1, long new_size
```

**Return:**
```c
void*
```

**Description:** Resizes a previously allocated memory buffer to `new_size` bytes.

---

#### **Name:** `replacestr`

**Arguments:**
```c
const char* text, const char* pattern, const char* replacement
```

**Return:**
```c
const char*
```

**Description:** Replaces all the regular expression `pattern` matches in `text` with `replacement`, returning the replaced string.

---

#### **Name:** `repstr`

**Arguments:**
```c
const char* text, long count
```

**Return:**
```c
const char*
```

**Description:** Repeats a string `count` times.

---

#### **Name:** `resetbgfg`

**Arguments:**
```c
void
```

**Return:**
```c
void
```

**Description:** Resets the terminal foreground and background colors to their defaults.

---

#### **Name:** `revstr`

**Arguments:**
```c
const char* text
```

**Return:**
```c
const char*
```

**Description:** Reverses a string.

---

#### **Name:** `rmfile`

**Arguments:**
```c
const char* path
```

**Return:**
```c
void
```

**Description:** Deletes a file at the given path.

---

#### **Name:** `rmfolder`

**Arguments:**
```c
const char* path
```

**Return:**
```c
void
```

**Description:** Recursively deletes a folder and all its contents.

---

#### **Name:** `schedule`

**Arguments:**
```c
long milliseconds, void (*function)(void)
```

**Return:**
```c
void
```

**Description:** Schedules a function to run once after the given delay in milliseconds. Does not repeat (see `cron` for repeating jobs).

---

#### **Name:** `scope`

**Arguments:**
```c
long atexit, void (*function)(void)
```

**Return:**
```c
void
```

**Description:** Registers a cleanup function. `0` = run at end of current scope (defer), `1` = run on process exit.

---

#### **Name:** `search`

**Arguments:**
```c
const char* text, const char* pattern
```

**Return:**
```c
Search
```

**Search:**
```c
typedef struct {
    const char** matches;
    long         length;
} Search;
```

**Description:** Searches all the regular expression `pattern` matches in `text`, returning them and their count.

---

#### **Name:** `setbg`

**Arguments:**
```c
long r, long g, long b
```

**Return:**
```c
void
```

**Description:** Sets the terminal background color using 24-bit RGB via ANSI escape codes.

---

#### **Name:** `setfg`

**Arguments:**
```c
long r, long g, long b
```

**Return:**
```c
void
```

**Description:** Sets the terminal foreground color using 24-bit RGB via ANSI escape codes.

---

#### **Name:** `sig`

**Arguments:**
```c
long signal, void (*function)(void)
```

**Return:**
```c
void
```

**Description:** Registers a handler for a POSIX signal number. The function is called when the signal is received.

---

#### **Name:** `sigthr`

**Arguments:**
```c
void* cond
```

**Return:**
```c
void
```

**Description:** It sends a signal to one thread.

---

#### **Name:** `spawnthr`

**Arguments:**
```c
void (*function)(void)
```

**Return:**
```c
void
```

**Description:** Launches the given function in a new POSIX thread. Use `syncthr` to wait for it or `killthr` to cancel it.

---

#### **Name:** `spawnproc`

**Arguments:**
```c
const char* command
```

**Return:**
```c
long
```

**Description:** Starts a command as a new child process and returns its PID.

---

#### **Name:** `splitstr`

**Arguments:**
```c
const char* text, const char* pattern
```

**Return:**
```c
Splitstr
```

**Splitstr:**
```c
typedef struct {
    const char** parts;
    long         length;
} Splitstr;
```

**Description:** Splits the `text` string into an array of substrings using the regular expression `pattern` as the delimiter.

---

#### **Name:** `stdi`

**Arguments:**
```c
long visible
```

**Return:**
```c
const char*
```

**Description:** Reads a line from stdin. `0` = hidden input (password mode), `1` = visible input.

---

#### **Name:** `stdo`

**Arguments:**
```c
const char* text
```

**Return:**
```c
void
```

**Description:** Writes a string to stdout without appending a newline.

---

#### **Name:** `strcomp`

**Arguments:**
```c
const char* text1, const char* text2
```

**Return:**
```c
long
```

**Description:** Returns `1` if the two strings are equal, `0` otherwise.

---

#### **Name:** `strcount`

**Arguments:**
```c
const char* text, const char* pattern
```

**Return:**
```c
long
```

**Description:** Returns the number of times `pattern` is found in `text`.

---

#### **Name:** `strdel`

**Arguments:**
```c
const char* text, long index
```

**Return:**
```c
const char*
```

**Description:** Deletes the character at the `index` position.

---

#### **Name:** `strformat`

**Arguments:**
```c
long count, ...
```

**Return:**
```c
const char*
```

**Description:** Concatenates `count` variadic string arguments into a single string. Uses a static 128 KB internal buffer.

---

#### **Name:** `strinsert`

**Arguments:**
```c
const char* text1, const char* text2, long index
```

**Return:**
```c
const char*
```

**Description:** Inserts `text2` into `text1` at the specified `index`.

---

#### **Name:** `substr`

**Arguments:**
```c
const char* text, long start_index, long stop_index
```

**Return:**
```c
const char*
```

**Description:** Returns of a substring of `text` from `start` to `stop` index (inclusive).

---

#### **Name:** `syncthr`

**Arguments:**
```c
void (*function)(void)
```

**Return:**
```c
void
```

**Description:** Blocks until the thread identified by its function pointer finishes (pthread join).

---

#### **Name:** `timeformat`

**Arguments:**
```c
double timestamp, const char* format
```

**Return:**
```c
const char*
```

**Description:** Converts a Unix epoch timestamp into a human-readable date and time string using the specified format pattern.

---

#### **Name:** `timern`

**Arguments:**
```c
void
```

**Return:**
```c
double
```

**Description:** Returns the current Unix epoch time in seconds as a float.

---

#### **Name:** `timerstart`

**Arguments:**
```c
const char* name
```

**Return:**
```c
void
```

**Description:** Starts or resets a named monotonic timer. Multiple named timers can run concurrently.

---

#### **Name:** `timerstop`

**Arguments:**
```c
const char* name
```

**Return:**
```c
long
```

**Description:** Stops a named timer and returns elapsed milliseconds. Returns `-1` if the timer name was not found.

---

#### **Name:** `tob64str`

**Arguments:**
```c
long forurl, const char* value, const char* key
```

**Return:**
```c
const char*
```

**Description:** Encrypts a string with a multi-round XOR/rotation cipher then Base64-encodes it. `forurl = 1` uses URL-safe encoding. Reverse with `tostrb64`.

---

#### **Name:** `tofltint`

**Arguments:**
```c
long value
```

**Return:**
```c
double
```

**Description:** Converts an integer to a float.

---

#### **Name:** `tofltstr`

**Arguments:**
```c
const char* value
```

**Return:**
```c
double
```

**Description:** Parses a string and returns it as a float.

---

#### **Name:** `tohexstr`

**Arguments:**
```c
const char* value
```

**Return:**
```c
const char* value
```

**Description:** Turns a string in to hexadecimal.

---

#### **Name:** `tointflt`

**Arguments:**
```c
double value
```

**Return:**
```c
long
```

**Description:** Converts a float to an integer.

---

#### **Name:** `tointstr`

**Arguments:**
```c
const char* value
```

**Return:**
```c
long
```

**Description:** Parses an integer from a string.

---

#### **Name:** `tostrb64`

**Arguments:**
```c
const char* value, const char* key
```

**Return:**
```c
const char*
```

**Description:** Base64-decodes and decrypts a string previously encoded with `tob64str`. The key must match.

---

#### **Name:** `tostrflt`

**Arguments:**
```c
double value
```

**Return:**
```c
const char*
```

**Description:** Converts a float to its string representation.

---

#### **Name:** `tostrhex`

**Arguments:**
```c
const char* value
```

**Return:**
```c
const char* value
```

**Description:** Turns a hexadecimal string in to a normal string.

---

#### **Name:** `tostrint`

**Arguments:**
```c
long value
```

**Return:**
```c
const char*
```

**Description:** Converts an integer to its string representation.

---

#### **Name:** `trimstr`

**Arguments:**
```c
long sides, const char* text, const char* pattern
```

**Return:**
```c
const char*
```

**Description:** Trims `pattern` from a string. If `sides` is `0` then it trims from both sides, but if it is either `1` or `2` it will trim from the left and the right respectively.

---

#### **Name:** `undef`

**Arguments:**
```c
const char* name
```

**Return:**
```c
void
```

**Description:** Deletes an environment variable by name.

---

#### **Name:** `unlockthr`

**Arguments:**
```c
void* mutex
```

**Return:**
```c
void
```

**Description:** Unlocks a thread with the specified mutex.

---

#### **Name:** `until`

**Arguments:**
```c
double timestamp
```

**Return:**
```c
void
```

**Description:** Sleeps until the given Unix timestamp (as returned by `timern`). Returns immediately if the timestamp is in the past.

---

#### **Name:** `upstr`

**Arguments:**
```c
const char* text
```

**Return:**
```c
const char*
```

**Description:** Converts a string to uppercase.

---

#### **Name:** `version`

**Arguments:**
```c
void
```

**Return:**
```c
const char*
```

**Description:** Returns the library version string.

---

#### **Name:** `vidbuf`

**Arguments:**
```c
long mode
```

**Return:**
```c
void
```

**Description:** Switches between the terminal's main screen buffer (`0`) and alternate screen buffer (`1`). Useful for full-screen TUI apps.

---

#### **Name:** `wait`

**Arguments:**
```c
long milliseconds
```

**Return:**
```c
void
```

**Description:** Pauses execution for the given number of milliseconds.

---

#### **Name:** `waithr`

**Arguments:**
```c
void* cond, void* mutex
```

**Return:**
```c
void
```

**Description:** Waits for a signal from another thread.

---

#### **Name:** `where`

**Arguments:**
```c
const char* command
```

**Return:**
```c
const char*
```

**Description:** Returns the full path of a command via `which`. Returns an empty string if not found.
