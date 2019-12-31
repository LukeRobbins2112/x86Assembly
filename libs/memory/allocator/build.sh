#!/bin/bash

# change to current dir
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $DIR

# clean
rm *.o

# Build source files
as mm_helper.s -o mm_helper.o
as mm.s -o mm.o
as driver.s -o driver.o

# link
ld driver.o mm.o -o driver
