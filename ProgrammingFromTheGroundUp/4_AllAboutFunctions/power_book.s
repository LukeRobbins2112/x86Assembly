

    .section .data

    # nothing

    .section .text

    .globl _start

_start:
    pushq $3                # push second arg
    pushq $2                # push first arg
    call power              # call power function

    addq $16, %rsp           # move the stack pointer back

    pushq %rax              # save the first answer before second call

    pushq $2                # push second arg
    pushq $5                # push first arg
    call power              # call power function

    addq $16, %rsp           # move the stack pointer back

    popq %rbx               # Retrieve first answer from stack

    addq %rax, %rbx         # add answers together

    movq $1, %rax           # prepare for exit system call
    int $0x80               # call kernel trap


    .type power, @function
power:
    pushq %rbp              # save old base pointer
    movq  %rsp, %rbp         # make stack pointer the base pointer
    subq  $8, %rsp           # get room for local storage

    movq 16(%rbp), %rbx      # put first atg in %eax
    movq 24(%rbp), %rcx     # put second arv in %ecx

    movq %rbx, -8(%rbp)     # store current result

power_loop_start:
    cmpq $1, %rcx           # If power is at 1
    je end_power            # end loop

    movq -8(%rbp), %rax     # move current result into %eax
    imulq %rbx, %rax        # multiple current result by base number
    movq %rax, -8(%rbp)     # store the current result

    decq %rcx               # decrement the power
    jmp power_loop_start    # next loop iteration

end_power:
    movq -8(%rbp), %rax     # return value goes in %eax
    movq %rbp, %rsp         # restore the stack pointer
    popq %rbp               # restore the base pointer
    ret
