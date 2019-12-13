#!/bin/bash

# assemble helper functions
as read-record.s -o read-record.o

#  assemble main program
as find-oldest.s -o find-oldest.o

# link program
ld find-oldest.o read-record.o -o find-oldest
