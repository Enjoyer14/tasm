.model small
.stack
.data
    mas1 dw 53, -12, 6, 3, -6, 12, 17, -7, 142, 13, 100, -34, -12, 26, -153
    len1 dw 15
    masN dw 15 dup(?)
    lenN dw 0 
    masP dw 15 dup(?)
    lenP dw 0
    ans dw 16 dup(?)
    count dw 0

.code
start:
    mov ax, @data
    mov ds, ax


    xor si, si
    xor di, di
    mov cx, len1

    ;цикл для нахождения отрицательных чисел
cycleN:
    mov ax, mas1[si]
    cmp ax, 0
    jge skipN
    mov masN[di], ax
    add di, 2
    mov ax, lenN
    inc ax
    mov lenN, ax
skipN:
    add si, 2
    loop cycleN

    xor si, si
    xor di, di
    mov cx, len1

    ;цикл для нахождения положительных чисел
cycleP:
    mov ax, mas1[si]
    cmp ax, 0
    jl skipP
    mov masP[di], ax
    add di, 2
    mov ax, lenP
    inc ax
    mov lenP, ax
skipP:
    add si, 2
    loop cycleP

    ;сортировка отрицательных
    xor si, si
    mov cx, lenN
    sub cx, 1
sotrN:
    push cx
    xor si, si
sortNInner:
    mov ax, masN[si]
    mov bx, masN[si+2]

    cmp ax, bx
    jle noSwapN

    mov masN[si], bx
    mov masN[si+2], ax
    mov ax, count
    inc ax
    mov count, ax
noSwapN:
    add si, 2
    loop sortNInner
    pop cx
    loop sotrN


;сортировка отрицательных
    xor si, si
    mov cx, lenP
    sub cx, 1
sortP:
    push cx
    xor si, si
sortPInner:
    mov ax, masP[si]
    mov bx, masP[si+2]

    cmp ax, bx
    jge noSwapP

    mov masP[si], bx
    mov masP[si+2], ax
    mov ax, count
    inc ax
    mov count, ax
noSwapP:
    add si, 2
    loop sortPInner
    pop cx
    loop sortP

;добвляем в массив ans сначала сортированные отрицательные потом сортированные положительные
    xor si, si
    add si, 2
    xor di, di
    mov cx, lenN
addNeg:
    mov ax, masN[di]
    mov ans[si], ax
    add di, 2
    add si, 2
    loop addNeg

    xor di, di
    mov cx, lenP
addPos:
    mov ax, masP[di]
    mov ans[si], ax
    add di, 2
    add si, 2
    loop addPos


    mov ax, 4c00h
    int 21h
end start