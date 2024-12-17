.model small
.STACK 100h

mRandomAX MACRO min, max

    MOV AH, 00h        ; Функция 00h: получить системное время
    INT 1Ah            ; После вызова CX:DX содержит количество тиков с полуночи

    XOR AX, AX         ; Обнуляем AX
    MOV AX, DX         ; Используем DX (младшая часть таймера) для генерации
    SUB AX, min        ; Сдвигаем диапазон на мин

    MOV BX, max
    SUB BX, min        ; BX = (max - min)
    INC BX             ; BX = (max - min + 1), чтобы включить max в диапазон

    XOR DX, DX         ; Обнуляем DX
    DIV BX             ; AX = AX / BX; остаток в DX

    MOV AX, DX         ; Переносим остаток в AX, это число в диапазоне [0, max-min]
    ADD AX, min        ; Смещаем диапазон обратно на min

ENDM



data segment 
    min dw 1
    max dw 8
    minSh dw 0
    minSw dw 0
    maxSh dw 25
    maxSw dw 80
    minEl dw 1
    maxEl dw 255
    DIRECT db 1  
    EXIT db 0   
    SYM db ? 
    ATRIBUT1 db 14  
    ATRIBUT2 db 10 
    Color db ? 
    POS dw 3840  
    OLD_CS dw ?  
    OLD_IP dw ?

data ends
code segment 
assume cs:code, ds:data 
NEW_1C proc far 
    push ax ; сохранить все регистры 
    push bx 
    push cx 
    push dx 
    push ds 
    push es 
    mov ax, DATA  
    mov ds, ax   
    mov ax, 40h   
    mov es, ax   
    mov ax, es:[1ch] 
    mov bx, es:[1ah] 
    cmp bx , ax 
    jne m5 
    jmp back 
m5: 
    mov al, es:[bx] 
    mov es:[1ch], bx 
    cmp al, 30h 
    jnz m1 
    mov EXIT, 1 
    jmp back 

m1: 
    cmp al, 35h 
    jne m6 
    mRandomAX minSw, maxSw
    mov dl, al 
    mRandomAX minSh, maxSh
    mov dh, ah
    mov ATRIBUT1, dh 
    mov ATRIBUT2, dl 
    jmp back 
m6: 
    cmp al, 38h   
    jz m2 
    cmp al, 32h    
    jz m3 
    cmp al, 34h    
    jz m4 
    cmp al, 36h    
    jnz back    
    mov DIRECT, 3 
    jmp back 
m2: 
    mov DIRECT, 1 
    jmp back 
m3: 
    mov DIRECT, 4 
    jmp back 
m4: 
    mov DIRECT, 2 
back: 
    pop es 
    pop ds 
    pop dx 
    pop cx 
    pop bx 
    pop ax 
    iret 
NEW_1C endp 

CLS proc near 
    push cx 
    push ax 
    push si 
    xor si, si 
    mov ah, 7 
    mov dl, ' ' 
    mov cx, 2000 
CL1: 
    mov es:[si], ax 
    inc si 
    inc si 
    loop CL1 
    pop si 
    pop ax 
    pop cx 
    ret 
CLS endp 

DELAY proc near 
    push cx 
    mov cx, 25 
    d12: 
    push cx 
    xor cx,cx 
    d11: 
    nop 
    loop d11 
    pop cx 
    loop d12 
    pop cx 
    ret 
DELAY endp 

OUT_SYMBOL proc near 
    push ax 
    push bx 
    mRandomAX minEl, maxEl
    mov SYM, al
    mRandomAX min, max
    mov Color, al
    mov al, SYM
    mov ah, Color
    push ax 
    mRandomAX minSw, maxSw
    mov bl, al 
    mRandomAX minSh, maxSh
    mov bh, ah
    call DELAY 
    pop ax
    mov es:[bx], ax 
    pop bx 
    pop ax 
    ret 
OUT_SYMBOL endp 

START: 
JUMPS
    mov ax, DATA 
    mov ds, ax 
    ; чтение вектора прерывания 
    mov ah, 35h 
    mov al, 1Ch 
    int 21h 
    mov OLD_IP, bx 
    mov OLD_CS, es 
    ; установка вектора прерывания 
    push ds 
    mov dx, offset NEW_1C 
    mov ax, seg NEW_1C 
    mov ds, ax 
    mov ah, 25h 
    mov al, 1Ch 
    int 21h 
    pop ds 
    mov ax, 0B800h 
    mov es, ax 
    call CLS 
    call DELAY 
p1: 
    cmp EXIT, 0 
    jne quit 
    cmp DIRECT, 1 
    jz p2 
    cmp DIRECT, 2 
    jz p3 
    cmp DIRECT, 3 
    jz p4 
    mRandomAX min, POS 
    add ax,160 
    cmp ax, 3999 
    jg p1 
    mov POS, ax 
    call OUT_SYMBOL 
    jmp p1 
p2: 
    mRandomAX min, POS 
    add ax,160 
    sub ax, 160 
    jl p1 
    mov POS, ax 
    call OUT_SYMBOL 
    jmp p1 
p3: 
    mRandomAX min, POS 
    add ax,160 
    sub ax, 2 
    jl p1 
    mov POS, ax 
    call OUT_SYMBOL 
    jmp p1 
p4: 
    mRandomAX min, POS 
    add ax,160 
    add ax, 2 
    jg p1 
    mov POS, ax 
    call OUT_SYMBOL 
    jmp p1 
quit: 
    call CLS 
    mov dx, OLD_IP 
    mov ax, OLD_CS 
    mov ds, ax 
    mov ah, 25h 
    mov al, 1Ch 
    int 21h
    mov ax, 4c00h 
    int 21h 
NOJUMPS
CODE ends 
end START 