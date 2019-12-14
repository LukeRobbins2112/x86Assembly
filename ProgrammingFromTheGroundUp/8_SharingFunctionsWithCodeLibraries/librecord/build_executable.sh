#!/bin/bash

# created shared library
ld -shared write-record.o read-record.o -o librecord.so

# link write-records object file against our shared library
ld -L . -dynamic-linker /lib64/ld-linux-x86-64.so.2 -o write-records -lrecord write-records.o

# set LD_LIBRARY_PATH to include current directory when looking
export LD_LIBRARY_PATH=$LD_LIBARY_PATH:.

