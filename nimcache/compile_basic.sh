clang -c -w   -IC:\Users\me\.choosenim\toolchains\nim-1.2.0\lib -IC:\p\em2 -o stdlib_io.nim.c.o stdlib_io.nim.c
clang -c -w   -IC:\Users\me\.choosenim\toolchains\nim-1.2.0\lib -IC:\p\em2 -o stdlib_system.nim.c.o stdlib_system.nim.c
clang -c -w   -IC:\Users\me\.choosenim\toolchains\nim-1.2.0\lib -IC:\p\em2 -o @mbasic.nim.c.o @mbasic.nim.c
clang.exe   -o basic  stdlib_io.nim.c.o stdlib_system.nim.c.o @mbasic.nim.c.o   "-s TOTAL_MEMORY=536870912 -s SAFE_HEAP=1 -s WARN_UNALIGNED=1 --use-preload-plugins --preload-file out --preload-file fonts"  -g
