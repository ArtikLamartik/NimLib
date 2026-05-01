typedef struct {
    const char* stdo;
    int exit_code;
} Exec;

typedef struct {
    const char** args;
    int length;
} Getargs;

typedef struct {
    const char* name;
    const char* process_id;
    const char* parent_process_id;
    const char* user_id;
    const char* start_time;
    const char* command;
} Infoproc;

typedef struct {
    const char** name;
    const char** value;
    int length;
} Ladefs;

typedef struct {
    const char** name;
    const char** process_id;
    int length;
} Laprocs;

typedef struct {
    const char** paths;
    const char** types_of;
    int length;
} Lf;

extern void*       allocbuf   (int size);
extern void        cf         (const char* path);
extern void        cls        (void);
extern void        def        (const char* name, const char* value);
extern Exec        exec       (const char* command);
extern const char* fileread   (const char* path);
extern int         filesize   (const char* path);
extern void        filewrite  (const char* path, const char* content);
extern void        freebuf    (void* pointer1);
extern Getargs     getargs    (void);
extern const char* getcf      (void);
extern const char* getchr     (void);
extern const char* getdef     (const char* name);
extern int         getcpid    (void);
extern void        halt       (int exit_code);
extern Infoproc    infoproc   (int process_id);
extern int         isdef      (const char* name);
extern int         isfile     (const char* path);
extern int         isfolder   (const char* path);
extern int         isroot     (void);
extern int         killproc   (int process_id);
extern Ladefs      ladefs     (void);
extern Laprocs     laprocs    (void);
extern Lf          lf         (void);
extern void        mcopy      (const char* source, void* destination, int size);
extern void        mkfile     (const char* path);
extern void        mkfolder   (const char* path);
extern void        mvfile     (const char* old_path, const char* new_path);
extern void        mvfolder   (const char* old_path, const char* new_path);
extern int         randint    (int minimum, int maximum);
extern void*       reallocbuf (void* pointer1, int new_size);
extern void        rmfile     (const char* path);
extern void        rmfolder   (const char* path);
extern int         spawnproc  (const char* command);
extern const char* stdi       (int invisible);
extern void        stdo       (const char* string1);
extern int         strcomp    (const char* string1, const char* string2);
extern const char* strformat  (int count, ...);
extern int         tocintcstr (const char* value);
extern const char* tocstrcint (int value);
extern void        undef      (const char* name);
extern void        wait       (int milliseconds);
