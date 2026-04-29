struct Exec {
    const char* stdo;
    int exit_code;
};

struct Infoproc {
    const char* name;
    const char* process_id;
    const char* parent_process_id;
    const char* user_id;
    const char* start_time;
    const char* command;
};

struct Laprocs {
    const char** name;
    const char** process_id;
    int length;
};

struct Lf {
    const char** paths;
    const char** types_of;
    int length;
};

extern "C" {
    void*       allocbuf   (int size);
    void        cf         (const char* path);
    void        cls        (void);
    void        def        (const char* name, const char* value);
    Exec        exec       (const char* command);
    const char* fileread   (const char* path);
    int         filesize   (const char* path);
    void        filewrite  (const char* path, const char* content);
    void        freebuf    (void* pointer1);
    const char* getcf      (void);
    const char* getchr     (void);
    const char* getdef     (const char* name);
    int         getcpid    (void);
    void        halt       (int exit_code);
    Infoproc    infoproc   (int process_id);
    int         isdef      (const char* name);
    int         isfile     (const char* path);
    int         isfolder   (const char* path);
    int         isroot     (void);
    int         killproc   (int process_id);
    Laprocs     laprocs    (void);
    Lf          lf         (void);
    void        mcopy      (const char* source, void* destination, int size);
    void        mkfile     (const char* path);
    void        mkfolder   (const char* path);
    void        mvfile     (const char* old_path, const char* new_path);
    void        mvfolder   (const char* old_path, const char* new_path);
    extern int  randint    (int minimum, int maximum);
    void*       reallocbuf (void* pointer1, int new_size);
    void        rmfile     (const char* path);
    void        rmfolder   (const char* path);
    int         spawnproc  (const char* command);
    const char* stdi       (int invisible = 0);
    void        stdo       (const char* string1);
    int         strcomp    (const char* string1, const char* string2);
    const char* strformat  (int count, ...);
    void        undef      (const char* name);
    void        wait       (int milliseconds);
}
