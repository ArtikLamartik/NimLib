typedef struct {
    const char* output;
    long        exit_code;
} Exec;

typedef struct {
    const char* name;
    const char* creator;
    long        last_edit;
    long        file_size;
} Fileinfo;

typedef struct {
    const char* name;
    const char* creator;
    long        last_edit;
    long        folder_size;
} Folderinfo;

typedef struct {
    const char** args;
    long         length;
} Getargs;

typedef struct {
    long columns;
    long rows;
} Getermsize;

typedef struct {
    const char** name;
    const char** value;
    long         length;
} Ladefs;

typedef struct {
    const char** name;
    long         process_id;
    long         length;
} Laprocs;

typedef struct {
    const char** paths;
    const char** type_of;
    long         length;
} Lf;

typedef struct {
    const char* name;
    long        process_id;
    long        parent_process_id;
    const char* user_name;
    long        start_time;
    const char* command;
} Procinfo;

extern void*       allocbuf   (long size);
extern void        cf         (const char* path);
extern void        clrscr     (void);
extern void        cron       (long milliseconds, void (*function)(void));
extern void        cursor     (long visible);
extern void        cursorto   (long x, long y);
extern void        def        (const char* name, const char* value);
extern Exec        exec       (const char* command);
extern Fileinfo    fileinfo   (const char* path);
extern const char* fileread   (const char* path);
extern void        filewrite  (const char* path, const char* content);
extern Folderinfo  folderinfo (const char* path);
extern void        freebuf    (void* pointer1);
extern Getargs     getargs    (void);
extern const char* getcf      (void);
extern const char* getchr     (void);
extern long        getcpid    (void);
extern const char* getdef     (const char* name);
extern const char* getprogloc (void);
extern Getermsize  getermsize (void);
extern void        halt       (long exit_code);
extern long        has        (const char* text, const char* pattern);
extern long        isdef      (const char* name);
extern long        isfile     (const char* path);
extern long        isfolder   (const char* path);
extern long        isroot     (void);
extern void        killjob    (void (*function)(void));
extern long        killproc   (long process_id);
extern void        killthr    (void (*function)(void));
extern Ladefs      ladefs     (void);
extern Laprocs     laprocs    (void);
extern Lf          lf         (void);
extern void        mcopy      (const char* source, void* destination, long size);
extern void        mkfile     (const char* path);
extern void        mkfolder   (const char* path);
extern void        mvfile     (const char* old_path, const char* new_path);
extern void        mvfolder   (const char* old_path, const char* new_path);
extern long        ping       (const char* url);
extern Procinfo    procinfo   (long process_id);
extern long        randint    (long minimum, long maximum);
extern void*       reallocbuf (void* pointer1, long new_size);
extern void        resetbgfg  (void);
extern void        rmfile     (const char* path);
extern void        rmfolder   (const char* path);
extern void        schedule   (long milliseconds, void (*function)(void));
extern void        scope      (long atexit, void (*function)(void));
extern void        setbg      (long r, long g, long b);
extern void        setfg      (long r, long g, long b);
extern void        sig        (long signal, void (*function)(void));
extern void        spawnthr   (void (*function)(void));
extern long        spawnproc  (const char* command);
extern const char* stdi       (long visible);
extern void        stdo       (const char* string1);
extern long        strcomp    (const char* string1, const char* string2);
extern const char* strformat  (long count, ...);
extern void        syncthr    (void (*function)(void));
extern double      timern     (void);
extern void        timerstart (const char* name);
extern long        timerstop  (const char* name);
extern const char* tob64str   (long forurl, const char* value, const char* key);
extern double      tofltint   (long value);
extern double      tofltstr   (const char* value);
extern long        tointflt   (double value);
extern long        tointstr   (const char* value);
extern const char* tostrb64   (const char* value, const char* key);
extern const char* tostrflt   (double value);
extern const char* tostrint   (long value);
extern void        undef      (const char* name);
extern void        until      (double timestamp);
extern void        vidbuf     (long mode);
extern void        wait       (long milliseconds);
extern const char* where      (const char* command);
