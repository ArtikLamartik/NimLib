struct Exec {
    const char* output;
    int exit_code;
};

struct Fileinfo {
    const char* name;
    const char* creator;
    long        last_edit;
    long        file_size;
};

struct Folderinfo {
    const char* name;
    const char* creator;
    long        last_edit;
    long        folder_size;
};

struct Getargs {
    const char** args;
    int          length;
};

struct Ladefs {
    const char** name;
    const char** value;
    int          length;
};

struct Laprocs {
    const char** name;
    const char** process_id;
    int          length;
};

struct Lf {
    const char** paths;
    const char** types_of;
    int          length;
};

struct Procinfo {
    const char* name;
    const char* process_id;
    const char* parent_process_id;
    const char* user_name;
    const char* start_time;
    const char* command;
};

extern "C" {
    void*       allocbuf   (int size);
    void        cf         (const char* path);
    void        clrscr     (void);
    void        cursor     (int visible);
    void        cursorto   (int x, int y);
    void        def        (const char* name, const char* value);
    Exec        exec       (const char* command);
    Fileinfo    fileinfo   (const char* path);
    const char* fileread   (const char* path);
    void        filewrite  (const char* path, const char* content);
    Folderinfo  folderinfo (const char* path);
    void        freebuf    (void* pointer1);
    Getargs     getargs    (void);
    const char* getcf      (void);
    const char* getchr     (void);
    int         getcpid    (void);
    const char* getdef     (const char* name);
    const char* getprogloc (void);
    void        halt       (int exit_code);
    int         isdef      (const char* name);
    int         isfile     (const char* path);
    int         isfolder   (const char* path);
    int         isroot     (void);
    int         killproc   (int process_id);
    Ladefs      ladefs     (void);
    Laprocs     laprocs    (void);
    Lf          lf         (void);
    void        mcopy      (const char* source, void* destination, int size);
    void        mkfile     (const char* path);
    void        mkfolder   (const char* path);
    int         msgbox     (const char* title, int count, ...);
    void        mvfile     (const char* old_path, const char* new_path);
    void        mvfolder   (const char* old_path, const char* new_path);
    int         ping       (const char* url);
    Procinfo    procinfo   (int process_id);
    int         randint    (int minimum, int maximum);
    void*       reallocbuf (void* pointer1, int new_size);
    void        resetbgfg  (void);
    void        rmfile     (const char* path);
    void        rmfolder   (const char* path);
    void        scope      (int atexit, void (*function)(void));
    void        setbg      (int r, int g, int b);
    void        setfg      (int r, int g, int b);
    void        sig        (int signal, void (*function)(void));
    void        spawnthr   (void (*function)(void))
    int         spawnproc  (const char* command);
    const char* stdi       (int visible);
    void        stdo       (const char* string1);
    int         strcomp    (const char* string1, const char* string2);
    const char* strformat  (int count, ...);
    void        syncthr    (void (*function)(void))
    long        timern     (void);
    int         tointstr   (const char* value);
    const char* tostrint   (int value);
    void        undef      (const char* name);
    void        wait       (int milliseconds);
    const char* where      (const char* command);
}
