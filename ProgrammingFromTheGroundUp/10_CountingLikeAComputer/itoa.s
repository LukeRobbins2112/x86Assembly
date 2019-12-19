

###################################
.section .text
###################################


	#####################
	# @FUNCTION
	# Convert integer to string
	#
	# @ARGS
	# Arg0 (%rdi): integer to conver
	# Arg1 (%rsi): Result buffer
	#
	# @RETURN
	# No return - result is put into buffer
	#

	.globl itoa
	.type itoa @function
itoa:
	# division uses %rax as dividend
	movq %rdi, %rax

	# count the number of digits
	movq $0, %rcx

convert_digit_loop:

	# Divide remaining number by 10
	# Result in %rax, remainder in %rdx
	movq $0, %rdx
	movq $10, %rbx
	divq %rbx

	# convert remainder to char
	addq $'0', %rdx

	# save character on stack so we can pop in reverse order
	# when constructing the result
	pushq %rdx

	# increment number of digits
	incq %rcx
	
	# now check if there are remaining digits
	cmpq $0, %rax
	jne convert_digit_loop

done_converting:	

	# copy pointer to beginning of buffer
	# we will use this register to iterate through
	movq %rsi, %r8

	# save number of digits
	movq %rcx, %r9

build_string_loop:
	# pop each character 
	popq %rdx

	# append character to string
	movb %dl, (%r8)

	# increment pointer within buffer
	incq %r8

	# check to see if we're done
	decq %rcx
	cmpq $0, %rcx
	jne build_string_loop

	
done:
	# appendn null character
	movb $0, (%r8) 
	
	ret
	
