#############################
.section .data	# constants
#############################


.equ WSIZE, 4
.equ DSIZE, 8
.equ CHUNKSIZE, (1 << 12)	# 4096 bytes

	.equ ALLOCATED, 1
	.equ FREE, 0
