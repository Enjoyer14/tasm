.486
model use16 small 
.stack 100h 

.data 

DIRECT db 1  
EXIT db 0   
SYM db "#"  
POS dw 3840  
OLD_CS dw ?  
OLD_IP dw ? 
speed db 1

.code

NEW_1C proc far 
    push ax ; сохранить все регистры 
    push bx 
    push cx 
    push dx 
    push ds 
    push es 
    mov ax, @data 
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
    mov SYM, al

m6: 
    
    cmp al, 38h   
    je m2 
    cmp al, 32h    
    je m3 
    cmp al, 34h    
    je m4 
    cmp al, 36h    
    je m8    
    push ax
    sub al, 30h
    mov speed, al
    pop ax
    jmp back
m2: 
    mov DIRECT, 1
    jmp back 
m3: 
    mov DIRECT, 4 
    jmp back 
m4: 
    mov DIRECT, 2 
    jmp back
m8:
    mov DIRECT, 3 
    jmp back 
    
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
; Подпрограмма задержки 
DELAY proc near
    push ax
    push bx
    push cx 
    xor ah, ah
    mov al, speed
    mov bl, 10d
    mul bl
    mov cx, ax
d12: 
    push cx 
    xor cx,cx 
d11: 
    nop 
    loop d11 
    pop cx 
    loop d12 
    pop cx 
    pop bx
    pop ax
    ret 
DELAY endp 
; Подпрограмма вывода символа с заданным атрибутом 
OUT_SYMBOL proc near 
    push ax 
    push bx 
    mov al, SYM 
    mov ah, 4 
    mov bx, POS 
    call DELAY 
    mov es:[bx], ax 
    pop bx 
    pop ax 
    ret 
OUT_SYMBOL endp 
; Основная программа 
START: 
    mov ax, @data
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
    mov ax, POS 
    add ax,160 
    cmp ax, 3999 
    jg p1 
    mov POS, ax 
    call OUT_SYMBOL 
    jmp p1 
p2: 
    mov ax, POS 
    sub ax, 160 
    jl p1 
    mov POS, ax 
    call OUT_SYMBOL 
    jmp p1 
p3: 
    mov ax, POS 
    sub ax, 2 
    jl p1 
    mov POS, ax 
    call OUT_SYMBOL 
    jmp p1 
p4: 
    mov ax, POS 
    add ax, 2 
    jl p1 
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
end start
end