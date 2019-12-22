#!/bin/bash

# clean
rm *~
rm *.o

# Build source files
as mm_helper.s -o mm_helper.o
as driver.s -o driver.o

# link
ld driver.o mm_helper.o -o driver
