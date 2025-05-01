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
k10 dw 25
medX dw 319
medY dw 174
three_fifths dd 0.6
x2 dd 2.0
x1 dd 1.0
currX dd ?
EXIT db 0
OLD_CS dw ?  
OLD_IP dw ? 
chastota dw 5000
x7 dd 7.0
x07 dd 0.7
x174 dd 174.0
x4 dd 4.0
d07 dd -0.7
x5 dd 5.0
x13 dd 0.33
buff1 dd ?
buff2 dd ?

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
    cmp al, '0' 
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

    mov cx, 400

metka3:
    finit
    cmp EXIT, 0 
    jne endProg
    push cx
    sub cx, medX
    mov x, cx
    pop cx

    cmp cx, 220
    jl endProg

    cmp cx, medX
    jg func1
    jmp moreThanZero

moreThanZero:

    fild x
    fsin
    fld st(0)
    fmul
    fstp buff1

    fild x
    fld st(0)
    fmul
    fld x5
    fmul
    fld1
    fadd
    fld buff1
    fsub
    fsqrt

    frndint
    fchs
    fistp y
    
	mov al, 4
	jmp point

func1:

    fild x
	fld x7
	fadd
	fld st(0)
	fmul
	fstp buff1
	fild x
	fld x07
	fmul
    fchs

	fldl2e; log2e
	fmul; (x-a)*log2e
	fld st(0)

	frndint; st(0) - целое, st(1) - дробное
	fsub st(1),st(0)
	;fld1
	fscale
	fstp buff2
	
	fxch st(1)
	
	f2xm1
	fld1
	fadd
	fld buff2
	fmul
	fld1
	fadd
	fstp buff2; buff3 = e^(x-a)


	fld x4
	fadd

	fld x13
	fld st(1)
	fyl2x
	fld st(0)

	frndint; st(0) - целое, st(1) - дробное
	fsub st(1),st(0)
	fld1
	fscale
	fstp buff2
	
	fxch st(1)
	
	f2xm1
	fld1
	fadd
	fld buff2
	fmul
	fld1
	fadd
	fstp buff2; buff3 = e^(x-a)
	fld buff1
	fdivr


    fidiv k10
	frndint
    fchs
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