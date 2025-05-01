.model small
.stack
.data
    mas1 dw 13, 64, 2, -5, 1, 12, 6, 5
    len1 dw 8
    mas2 dw 10 dup(?)
    sum dw 0
    proiz dw 1

.code
start:
    mov ax, @data
    mov ds, ax


    xor si, si
    xor di, di
    add di, 4
    mov cx, len1

cycle:
    mov ax, mas1[si]
    mov mas2[di], ax
    mov bx, 2d
    xor dx, dx
    idiv bx
    cmp dx, 1
    je Odd
    jmp nextCheck
Odd:
    mov ax, mas1[si]
    mov bx, proiz
    imul bx
    mov proiz, ax

nextCheck:
    mov ax, si
    mov bx, 4d
    xor dx, dx
    idiv bx
    cmp dx, 2
    je skip
    mov ax, mas1[si]
    add ax, sum
    mov sum, ax

skip:
    add di, 2
    add si, 2
    loop cycle

    xor di, di
    mov ax, sum
    mov mas2[di], ax
    add di, 2
    mov ax, proiz
    mov mas2[di], ax

    mov ax, 4c00h
    int 21h

end start