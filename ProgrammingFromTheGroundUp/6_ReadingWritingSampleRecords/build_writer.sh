#!/bin/bash

# assemble files
as write-record.s -o write-record.o
as write-records.s -o write-records.o

# link files
ld write-records.o write-record.o -o write-records
