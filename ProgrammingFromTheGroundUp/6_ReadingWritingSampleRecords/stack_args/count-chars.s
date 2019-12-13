

###################################
.section .text
###################################

.equ BUFFER_LOC, 16
	
	.globl count_chars
	.type count_chars @function
count_chars:
	# save rbp
	pushq %rbp
	movq %rsp, %rbp

	# initialize char count
	movq $0, %rax

	# get buffer location
	movq BUFFER_LOC(%rbp), %rdi

	# initialize index
	movq $0, %rsi

count_loop:
	movb (%rdi, %rsi, 1), %cl
	cmpb $0, %cl
	je done_counting

	incq %rax
	incq %rsi
	jmp count_loop

done_counting:
	movq %rbp, %rsp
	popq %rbp
	ret
	
