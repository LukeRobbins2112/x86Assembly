

	# include constants
	# .globl functions are automatically linked
	.include "linux.s"
	.include "record-def.s"

###########################################
.section .data
###########################################

	#
	# These 3 hard-coded records will be written to file
	# Each field is padded with null chars to unify file size
	#

record0:
	# first name: 9 byte + 31 bytes padding
	.ascii "Fredrick\0"
	.rept 31
	.byte 0
	.endr
	# last name
	.ascii "Bartlett\0"
	.rept 31
	.byte 0
	.endr
	# address: 39 bytes + 209 bytes padding
	.ascii "4242 S Prairie\nTulsa, OK 55555\0"
	.rept 209
	.byte 0
	.endr
	# age
	.long 45

record1:
	# first name
	.ascii "Marilyn\0"
	.rept 32
	.byte 0
	.endr
	# last name
	.ascii "Taylor\0"
	.rept 33
	.byte 0
	.endr
	# address
	.ascii "2224 S Johannan St\nChicago, IL 12345\0"
	.rept 203
	.byte 0
	.endr
	# age
	.long 29

record2:
	# first name
	.ascii "Derrick\0"
	.rept 32
	.byte 0
	.endr
	# last name
	.ascii "McIntyre\0"
	.rept 31
	.byte 0
	.endr
	# address
	.ascii "500 S Johannan St\nChicago, IL 12345\0"
	.rept 206
	.byte 0
	.endr
	# age
	.long 36

# output file
file_name:
	.ascii "test.dat\0"

####################################
.section .text
####################################
	
	# local storage to hold output file descriptor
	.equ ST_FILE_DESC, -8

	.globl _start

_start:

	# save stack pointer
	movq %rsp, %rbp

	# allocate space for fd
	subq $8, %rsp

	# open the file to write
	movq $SYS_OPEN, %rax
	movq $file_name, %rdi
	movq $0101, %rsi
	movq $0666, %rdx
	syscall

	# save FD
	movq %rax, ST_FILE_DESC(%rbp)

	# write first record
	pushq %rax		# output fd to write to
	pushq $record0		# immediate address of record0
	callq write_record	# call function
	addq $16, %rsp		# restore stack pointer

	# write second record	
	pushq %rax		# output fd to write to
	pushq $record1		# immediate address of record0
	callq write_record	# call function
	addq $16, %rsp		# restore stack pointer

	# write third record
	pushq %rax		# output fd to write to
	pushq $record2		# immediate address of record0
	callq write_record	# call function
	addq $16, %rsp		# restore stack pointer

	# close the file
	movq $SYS_CLOSE, %rax
	movq ST_FILE_DESC(%rbp), %rdi
	syscall

	# exit process
	movq $SYS_EXIT, %rax
	syscall
	
	
	
