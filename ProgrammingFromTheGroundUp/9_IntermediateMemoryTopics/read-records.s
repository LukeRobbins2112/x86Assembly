
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
	.equ STACK_SIZE, 16

	
	.globl _start
_start:
	movq %rsp, %rbp

	subq $STACK_SIZE, %rsp

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
	movq INPUT_FD(%rbp), %rdi
	movq $RECORD_BUFFER, %rsi
	callq read_record

	# make sure we read the proper record size
	# in error or EOF, we're done
	cmpq $RECORD_SIZE, %rax
	jne end_loop

	# otherwise, continue
	# handle first name: count chars then print
	pushq $RECORD_FIRSTNAME + RECORD_BUFFER	# push firstname location
	callq count_chars			# count the chars
	addq $8, %rsp				# restore stack

	# print first name
	movq %rax, %rdx		# num chars
	movq $SYS_WRITE, %rax
	movq OUTPUT_FD(%rbp), %rdi
	movq $RECORD_FIRSTNAME + RECORD_BUFFER, %rsi
	syscall

	# add new line
	pushq OUTPUT_FD(%rbp)
	callq write_newline
	addq $8, %rsp			#restore stack pointer

	# continue loop
	jmp record_read_loop

end_loop:
	movq $SYS_EXIT, %rax
	movq $0, %rdi
	syscall
	
	

	
	
	
