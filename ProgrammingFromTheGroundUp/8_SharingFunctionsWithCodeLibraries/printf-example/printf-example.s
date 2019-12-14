
##################################
.section .data
##################################

format_string:
	.asciz "Hello! %s is a %s who loves the number %ld\n"

person_name:
	.asciz "David"
person_type:
	.asciz "person"
number_loved:
	.long 7

	
##################################
.section .text
##################################

	.globl _start
_start:
	movq $format_string, %rdi
	movq $person_name, %rsi
	movq $person_type, %rdx
	movq number_loved, %rcx
	callq printf

	movq $0, %rdi
	callq exit

	
