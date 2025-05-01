mAbs macro
local exit
    cmp ax, 0
    jge exit
    neg ax
    exit:
endm

.model small
.stack
.data
    mas1 dw 13, 64, 2, -5, 1, 12, 6, 5, -6, 10, 16, 9, 125
    len1 dw 13
    mas2 dw 14 dup(?)
    min dw ?

.code
start:
    mov ax, @data
    mov ds, ax

    

    xor si, si
    xor di, di
    add di, 2
    mov ax, mas1[si]
    mAbs
    mov min, ax
    mov cx, len1

cycle:
    mov ax, mas1[si]
    cmp ax, -5d
    jle skip
    cmp ax, 15
    jg skip

    mov mas2[di], ax
    add di, 2
    mAbs
    cmp ax, min
    jge skip
    mov min, ax

skip:
    add si, 2
    loop cycle

    xor di, di
    mov ax, min
    mov mas2[di], ax

    mov ax, 4c00h
    int 21h

end start