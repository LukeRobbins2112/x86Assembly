#!/bin/bash

# assemble helper functions
as read-record.s -o read-record.o
as count-chars.s -o count-chars.o
as write-newline.s -o write-newline.o

#  assemble main program
as read-records.s -o read-records.o

# link program
ld read-records.o read-record.o count-chars.o write-newline.o -o read-records
