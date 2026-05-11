typedef struct {
    const char* output;
    int         exit_code;
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
    int          length;
} Getargs;

typedef struct {
    const char** name;
    const char** value;
    int          length;
} Ladefs;

typedef struct {
    const char** name;
    const char** process_id;
    int          length;
} Laprocs;

typedef struct {
    const char** paths;
    const char** types_of;
    int          length;
} Lf;

typedef struct {
    const char* name;
    const char* process_id;
    const char* parent_process_id;
    const char* user_name;
    const char* start_time;
    const char* command;
} Procinfo;

extern void*       allocbuf   (int size);
extern void        cf         (const char* path);
extern void        clrscr     (void);
extern void        cursor     (int visible);
extern void        cursorto   (int x, int y);
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
extern int         getcpid    (void);
extern const char* getdef     (const char* name);
extern const char* getprogloc (void);
extern void        halt       (int exit_code);
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
extern int         msgbox     (const char* title, int count, ...);
extern void        mvfile     (const char* old_path, const char* new_path);
extern void        mvfolder   (const char* old_path, const char* new_path);
extern int         ping       (const char* url);
extern Procinfo    procinfo   (int process_id);
extern int         randint    (int minimum, int maximum);
extern void*       reallocbuf (void* pointer1, int new_size);
extern void        resetbgfg  (void);
extern void        rmfile     (const char* path);
extern void        rmfolder   (const char* path);
extern void        scope      (int atexit, void (*function)(void));
extern void        setbg      (int r, int g, int b);
extern void        setfg      (int r, int g, int b);
extern void        sig        (int signal, void (*function)(void));
extern void        spawnthr   (void (*function)(void))
extern int         spawnproc  (const char* command);
extern const char* stdi       (int visible);
extern void        stdo       (const char* string1);
extern int         strcomp    (const char* string1, const char* string2);
extern const char* strformat  (int count, ...);
extern void        syncthr    (void (*function)(void))
extern int         timern     (void);
extern int         tointstr   (const char* value);
extern const char* tostrint   (int value);
extern void        undef      (const char* name);
extern void        wait       (int milliseconds);
extern const char* where      (const char* command);
