
	.section .data
	# no data

	.section .text

	.globl _start

_start:
	pushq $4	# calculate 4!
	callq fac	# call factorial
	movq %rax, %rbx	# move answer to rbx

	addq $8, %rsp	# de-allocate initial value

	movq $1, %rax	# exit sys call
	int $0x80	# call trap

	.type fac, @function
fac:
	pushq %rbp		# save old base pointer
	movq %rsp, %rbp		# copy stack pointer into base pointer

	movq 16(%rbp), %rbx	# get previous call's value
	cmpq $1, %rbx 		# check if we're at 1
	je done			# if we hit 1, we stop here

	subq $8, %rsp		# allocate space for local variable	
	movq %rbx, -8(%rbp)	# save local variable for calculation

	subq $8, %rsp		# allocate stack space for next call argument
	movq %rbx, -16(%rbp)	# copy current val for the call arg
	subq $1, -16(%rbp)	# subtract 1 to continue factorial
	
	callq fac		# make next call
	imulq -8(%rbp), %rax	# add local var to result, prepare to return
	
	addq $8, %rsp		# de-allocate space for argument
	addq $8, %rsp		# de-allocate space for local var

	movq %rbp, %rsp
	popq %rbp
	ret			# return sum

done:
	movq %rbp, %rsp
	popq %rbp
	movq $1, %rax
	ret
