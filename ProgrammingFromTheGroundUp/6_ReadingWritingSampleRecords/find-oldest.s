
	.include "linux.s"
	.include "record-def.s"

	##########################################
	.section .data
	##########################################

filename:
	.ascii "test.dat\0"

	##########################################
	.section .bss
	##########################################

	.lcomm RECORD_BUFFER, RECORD_SIZE

	##########################################
	.section .text
	##########################################

	.equ INPUT_FD, -8
	.equ OUTPUT_FD, -16
	.equ LARGEST_AGE, -24
	.equ STACK_SIZE, 24

	
	.globl _start
_start:
	movq %rsp, %rbp

	subq $STACK_SIZE, %rsp

	# initialize largest val
	movq $0, LARGEST_AGE(%rbp)

	# open the records file for reading
	movq $SYS_OPEN, %rax
	movq $filename, %rdi
	movq $0, %rsi
	movq $0666, %rdx
	syscall

	movq %rax, INPUT_FD(%rbp)	# save input FD
	movq $STDOUT, OUTPUT_FD(%rbp)	# for now, use STDOUT as output FD

record_read_loop:

	# read a record into the buffer
#	pushq $RECORD_BUFFER	# arg 1
#	pushq INPUT_FD(%rbp)	# arg 0
	movq INPUT_FD(%rbp), %rdi
	movq $RECORD_BUFFER, %rsi
	callq read_record

	# make sure we read the proper record size
	# in error or EOF, we're done
	cmpq $RECORD_SIZE, %rax
	jne end_loop

	# otherwise, continue
#	addq $16, %rsp		# remove args from stack

	# get age of record
	movq RECORD_AGE + RECORD_BUFFER, %rdi

	# if new age <= current largest, just continue
	cmpq LARGEST_AGE(%rbp), %rdi
	jle record_read_loop

	# if new age is larger, update largest
	movq %rdi, LARGEST_AGE(%rbp)

	# continue loop
	jmp record_read_loop

end_loop:
	movq $SYS_EXIT, %rax
	movq LARGEST_AGE(%rbp), %rdi
	syscall
	
	

	
	
	
