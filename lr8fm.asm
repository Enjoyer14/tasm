.486
model use16 small 
.stack 100h 

.data 

b dw 175   
x dw ?   
ang dw 180
pi dw ?  
y dw ?   
axis dw ?   
k2 dw 2
k10 dw 100
medX dw 319
medY dw 174
three_fifths dd 0.6
x2 dd 2.0
x1 dd 1.0
currX dd ?
EXIT db 0
OLD_CS dw ?  
OLD_IP dw ? 
chastota dw 6000
buff dw ?

.code

DELAY proc near 
    push cx 
    mov cx, 1 
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

NEW_1C proc far 
    push ax ; сохранить все регистры 
    push bx 
    push cx 
    push dx 
    push ds 
    push es 

    mov al, 10110110b ;управляющее слово: канал 2, режим 3
    out 43h, al

    mov ax, [chastota]
    out 42h, al
    mov al, ah        
    out 42h, al 
    ;включаем динамик
    in al, 61h ; читаем порт управления
    or al, 00000011b ;устанавливаем биты для включения канала 2
    out 61h, al   

    mov ax, @DATA  
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
    cmp al, 13d 
    jnz back 
    mov EXIT, 1     
back: 

    pop es 
    pop ds 
    pop dx 
    pop cx 
    pop bx 
    pop ax 
    iret 
NEW_1C endp

start: 
JUMPS
    mov ax, @DATA 
    mov ds, ax 


    xor ax, ax
	mov al, 10h
	int 10h

    mov ax, 0600h
	mov bh, 15
	mov cx, 0000b
	mov dx, 184Fh
	int 10h
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

    mov ah, 0Ch   ;установка графической точки 
    mov al, 10  ;загружаем зелѐный цвет для вертикальной линии
    mov bh, 0h   ;установка номера видеостраницы 
    mov cx, 400     ;количество итераций сверху вниз

metka1:    
    push cx  
    mov axis, cx  
    mov dx, axis  
    mov cx, medX 
    int 10h  
    pop cx 
    loop metka1 

    mov ah, 0ch   ;установка графической точки 
    mov al, 30   ;зелѐный цвет
    mov cx, 639  ;639 итераций, ставит в 639 колонку, и идѐт до 0
    mov bh, 0h   ; установка номера видеостраницы
    mov dx, medY   ;ставит в 174 строку

metka2:    
    int 10h   
    loop metka2 

    mov al, 10
    mov cx, 639  ;639 итераций, ставит в 639 колонку, и идѐт до 0

metkaUP:    
    push cx
    sub cx, medX
    mov x, cx
    pop cx

    cmp cx, 308
    jle nextUp
    cmp cx, 330
    jg nextUp

    finit
    fild x
    fabs

	frndint
    fistp y

    mov ah, 0ch
	mov bh, 0h
	mov dx, y
	int 10h
nextUp:
    loop metkaUP

    mov al, 30
    mov cx, 12     ;количество итераций сверху вниз
metkaRight:
    push cx 
    sub cx, 638
    neg cx
    mov x, cx
    pop cx
    mov dx, 174
    sub dx, cx
    push cx
    mov cx, x
    mov ah, 0ch
	mov bh, 0h
	int 10h
    pop cx
    loop metkaRight


    mov al, 30
    mov cx, 12     ;количество итераций сверху вниз
metkaRight2:
    push cx 
    sub cx, 638
    neg cx
    mov x, cx
    pop cx
    mov dx, 174
    add dx, cx
    push cx
    mov cx, x
    mov ah, 0ch
	mov bh, 0h
	int 10h
    pop cx
    loop metkaRight2

    mov cx, 500

metka3:
    finit
    cmp EXIT, 0 
    jne endProg
    push cx
    sub cx, medX
    mov x, cx
    pop cx

    cmp cx, 330
    jg func1
    jmp lessThanZero

func1:
    finit
    
    fild x                 ; ST(0) = x
    fimul x
    fistp buff
    fldl2e             ; ST(0) = log2(e), ST(1) = x
    fmul                       ; ST(0) = x * log2(e)

    ; Вычисление 2^(x * log2(e)) - 1
    f2xm1                     ; ST(0) = 2^(x * log2(e)) - 1
    fld1                      ; ST(0) = 1, ST(1) = 2^(x * log2(e)) - 1
    fadd                      ; ST(0) = 2^(x * log2(e)) = e^x
    
    fild buff
    fidiv k10
	fchs
	frndint
    fistp y 

	mov al, 4
	jmp point
lessThanZero:
    cmp cx, 290
    jge func2
    jmp func3 ;
func2:
    
    fild x
    fmul x2

    fidiv k2
	fchs
	frndint
    fistp y 

	mov al, 1
	jmp point

func3:
    finit

    fild x
    fimul x
    fadd x1
    fidiv x

    fidiv k2
	fchs
	frndint
    fistp y 

	mov al, 2
	jmp point

point:
	mov ah, 0ch
	mov bh, 0h
	mov dx, y
	add dx, medY
	int 10h

	pusha

    mov  si, 1
    mov  ah, 0
    int  1ah
    mov  bx, dx
    add  bx, si
    call DELAY

	popa

	jmp fnsh_iter

fnsh_iter:
	loop metka3

endProg:
	mov dx, OLD_IP 
    mov ax, OLD_CS 
    mov ds, ax 
    mov ah, 25h 
    mov al, 1Ch 
    int 21h 

    mov ah, 2
	mov dh, 0
	mov dl, 0
	mov bh, 0
	int 10h
    
    in al, 61h    
    and al, 0FCh
    out 61h, al

    mov ax, 4c00h 
    int 21h
    NOJUMPS
end start
end