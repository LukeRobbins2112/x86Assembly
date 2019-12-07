
    .section .data

data_items:
    .long 1, 2, 3, 4, 0

    .section .text
    .globl _start

_start:
    movl $0, %edi             # init index to 0
    movl data_items, %ebx    # get first element as max

_max_num:
    movl data_items(, %edi, 4), %eax
    testl %eax, %eax
    je _done

    # increment index
    addl $1, %edi

    # compare current element to max
    cmpl %ebx, %eax

    # if current element > max, update max
    jg _update_max

    # otherwise, just continue
    jmp _max_num

_update_max:
    movl %eax, %ebx
    jmp _max_num

_done:
    movl $1, %eax
    int $0x80
