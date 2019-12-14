
# build the program object file
as helloworld-lib.s -o helloworld-lib.o

# dynamically link with ld-linux and libc
ld -o helloworld-lib -dynamic-linker /lib64/ld-linux-x86-64.so.2 helloworld-lib.o -lc
