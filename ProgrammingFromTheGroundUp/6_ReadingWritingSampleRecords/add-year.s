
	.include "linux.s"
	.include "record-def.s"
	.include "error_codes.s"


##################################
.section .data
##################################

input_file:
	.asciz "test.dat"
output_file:
	.asciz "test_updated.dat"
	
##################################
.section .bss
##################################	

	.lcomm MODIFY_BUFFER, RECORD_SIZE

##################################
.section .text
##################################

	.equ STACK_SIZE, 16
	.equ INPUT_FD, -8
	.equ OUTPUT_FD, -16

	.globl _start
_start:
	# save stack pointer
	movq %rsp, %rbp

	# allocate space for FD's
	subq $STACK_SIZE, %rsp

open_input_file:	
	# open input file
	movq $SYS_OPEN, %rax
	movq $input_file, %rdi
	movq $0, %rsi
	movq $0666, %rdx
	syscall

	# check return code for error
	cmpq $0, %rax
	movq $open_err_code, %rdi
	movq $open_err_msg, %rsi
	jl handle_error

	# save input fd
	movq %rax, INPUT_FD(%rbp)

open_output_file:	
	# open output file
	movq $SYS_OPEN, %rax
	movq $output_file, %rdi
	movq $0101, %rsi
	movq $0666, %rdx
	syscall

	cmpq $0, %rax
	movq $open_err_code, %rdi
	movq $open_err_msg, %rsi
	jl handle_error

	# save output fd
	movq %rax, OUTPUT_FD(%rbp)

update_loop:
	# read record into buffer
	movq INPUT_FD(%rbp), %rdi
	movq $MODIFY_BUFFER, %rsi
	callq read_record

	# if EOF, we're done
	cmpq $EOF, %rax
	je end_update

	# if otherwise not equal to record size, error
	cmpq $RECORD_SIZE, %rax
	movq $read_err_code, %rdi
	movq $read_err_msg, %rsi
	jne handle_error

	# update age directly in memory
	incq MODIFY_BUFFER + RECORD_AGE

	# write to output file
	movq OUTPUT_FD(%rbp), %rdi
	movq $MODIFY_BUFFER, %rsi
	callq write_record

	# make sure we wrote it all
	cmpq $RECORD_SIZE, %rax
	movq $write_err_code, %rdi
	movq $write_err_msg, %rsi
	jne handle_error


	jmp update_loop


end_update:
	# close files

	# input file
	movq $SYS_CLOSE, %rax
	movq INPUT_FD(%rbp), %rdi
	syscall

	# output file
	movq $SYS_CLOSE, %rax
	movq OUTPUT_FD(%rbp), %rdi
	syscall
	
exit_program:	
	movq %rbp, %rsp

	movq $SYS_EXIT, %rax
	movq $0, %rdi
	syscall


handle_error:
	callq error_exit
