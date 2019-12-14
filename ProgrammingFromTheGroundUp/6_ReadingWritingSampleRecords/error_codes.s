
######################################
.section .data
######################################	

# err codes
read_err_code:
	.asciz "01"
write_err_code:
	.asciz "11"
open_err_code:
	.asciz "21"
close_err_code:
	.asciz "31"

	
# err messages
read_err_msg:
	.asciz "Read error"
write_err_msg:
	.asciz "Write error"
open_err_msg:
	.asciz "Open error"
close_err_msg:
	.asciz "Close error"
