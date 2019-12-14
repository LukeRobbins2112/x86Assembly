

##########################################
.section .data
##########################################
	
err_code:
	.asciz "001: "
err_msg:
	.asciz "Misc error"

##########################################
.section .text
##########################################

	.globl _start
_start:
	# test error_exit
	movq $err_code, %rdi
	movq $err_msg, %rsi
	callq error_exit


	
