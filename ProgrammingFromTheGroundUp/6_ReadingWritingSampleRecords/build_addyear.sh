#!/bin/bash

# build relocatable object files
as write-record.s -o write-record.o
as read-record.s -o read-record.o
as error-exit.s -o error-exit.o
as count-chars.s -o count-chars.o
as write-newline.s -o write-newline.o
as add-year.s -o add-year.o

# link
ld add-year.o error-exit.o write-record.o read-record.o count-chars.o write-newline.o -o add-year
