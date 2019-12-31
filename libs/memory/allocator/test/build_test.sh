#!/bin/bash

# compile c test file
gcc -c test.c -o test.o

# run main directory build script
../build.sh

# compile executable with object files
gcc test.o ../mm.o ../mm_helper.o -o test

# run tests
./test

# cleanup
rm test
rm test.o
