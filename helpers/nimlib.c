typedef struct {
    const char* stdo;
    int exit_code;
} Exec;

typedef struct {
    const char** paths;
    const char** types_of;
    int len;
} Lf;

extern void*       allocbuf   (int size);
extern void        cf         (const char* path);
extern void        cls        (void);
extern void        def        (const char* name, const char* value);
extern Exec        exec       (const char* command);
extern int         filesize   (const char* path);
extern const char* fileread   (const char* path);
extern void        filewrite  (const char* path, const char* content);
extern void        freebuf    (void* pointer1);
extern const char* getcf      (void);
extern const char* getdef     (const char* name);
extern int         getprocid  (void);
extern void        halt       (int exit_code);
extern int         isdef      (const char* name);
extern int         isfile     (const char* path);
extern int         isfolder   (const char* path);
extern int         isroot     (void);
extern Lf          lf         (void);
extern void        mcopy      (const char* source, void* destination, int size);
extern void        mkfile     (const char* path);
extern void        mkfolder   (const char* path);
extern void*       reallocbuf (void* pointer1, int new_size);
extern void        rm         (const char* path);
extern void        rmfolder   (const char* path);
extern void        mv         (const char* old_path, const char* new_path);
extern void        mvfolder   (const char* old_path, const char* new_path);
extern const char* stdi       (void);
extern void        stdo       (const char* string1);
extern int         strcomp    (const char* string1, const char* string2);
extern void        undef      (const char* name);
extern void        wait       (int milliseconds);
