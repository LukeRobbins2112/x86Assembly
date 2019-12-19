#!/bin/bash

# assemble
as itoa.s -o itoa.o
as itoa_driver.s -o itoa_driver.o

# link
ld itoa_driver.o itoa.o -o itoa_driver
