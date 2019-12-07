    # Purpose: find the max number of a set of data items

    # Variables: The registers have the uses:
    #
    # %edi - holds the index of the data item examined
    # %ebx - holds the largest data item found
    # %eax - holds the current data item
    #
    # The memory location data_items holds the list of nums

    .section .data

data_items:
    .long 3, 67, 34, 222, 45, 75, 54, 34, 44, 33, 22, 11, 66, 0

    .section .text

    .globl _start

_start:
    movl $0, %edi                      # initialize index register to 0
    movl data_items(, %edi, 4), %eax   # load the first item
    movl %eax, %ebx                    # init max value to first item


maxnum_loop:
    cmpl $0, %eax       # check to see if we're done
    je loop_exit

    incl %edi                       # increment index
    movl data_items(, %edi, 4), %eax      # load next item
    cmpl %ebx, %eax                 # compare curr val to max val
    jle maxnum_loop                 # if <=, don't update

    movl %eax, %ebx                 # otherwise, update
    jmp maxnum_loop                 # continue loop

loop_exit:
    # %ebx is the status code for the exit system call
    # it already has the max number
    # we'll use this to check the result
    movl $1, %eax
    int $0x80
