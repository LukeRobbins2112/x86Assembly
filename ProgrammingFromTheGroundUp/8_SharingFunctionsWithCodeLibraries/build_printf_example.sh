
# build the program object file
as printf-example.s -o printf-example.o

# dynamically link with ld-linux and libc
ld -o printf-example -dynamic-linker /lib64/ld-linux-x86-64.so.2 printf-example.o -lc
