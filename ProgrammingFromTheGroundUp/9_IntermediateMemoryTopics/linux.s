
	#
	# This file contains useful constants 
	# which will be used across several programs
	#

	#
	# System Calls
	#

	# File management
	.equ SYS_READ,	0
	.equ SYS_WRITE,	1
	.equ SYS_OPEN,	2
	.equ SYS_CLOSE,	3

	# memory allocation
	.equ SYS_BRK,	12

	# exit process
	.equ SYS_EXIT,	60

	# System interrupt
	.equ LINUX_SYSCALL, 0x80


	#
	# Additional File constants
	#

	.equ STDIN,	0
	.equ STDOUT,	1
	.equ STDERR,	2

	# end of file
	.equ EOF,	0
