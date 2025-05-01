.486
model use16 small 
.stack 100h 

.data 

b dw 175   
k1 dw 1 
x dw ?   
ang dw 180
pi dw ?  
y dw ?   
axis dw ?   
k2 dw 2
k3 dw 6
two dw 2  
medX dw 319
medY dw 174
buff1 dd ?
buff2 dd ?
buff3 dd ?
three_fifths dd 0.6
one_third dd 0.33333 ; Число 1/3
x2 dd 2.0
x1 dd 1.0
currX dd ?
EXIT db 0
OLD_CS dw ?  
OLD_IP dw ? 
chastota dw 7000

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
    ;Генерация звука
    ;Устанавливаем частоту через таймер 8253
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
    cmp al, 30h 
    jnz back 
    mov EXIT, 1     
    jmp back 
back: 
    mov ax, [chastota]
    sub ax, 200       ; Уменьшаем частоту на 100
    cmp ax, 300       ; Проверяем границу (не ниже 300)
    ja freq_ok
    mov ax, 7000      ; Сбросить на максимальную частоту
freq_ok:
    mov [chastota], ax      ; Сохраняем новую частоту
    
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
    mov cx, 639  

metka3:
    finit
    cmp EXIT, 0 
    jne endProg
    push cx
    sub cx, medX
    mov x, cx
    pop cx

    cmp cx, medX
    jge func1
    jmp lessThanZero

func1:
    finit
    fild x
    fadd x1

    fld1
    fxch st(1) ;st0 = x, st1 = 1
    fyl2x

    fldln2
    fmul
    
    fld three_fifths
    fmul

    fldl2e
    fmul
    f2xm1
    fld1
    fadd

    fimul k3
	fchs
	frndint
    fistp y 

	mov al, 4
	jmp point
lessThanZero:
    cmp cx, 270
    jg func2
    jmp func3
func2:
    fild x
    fstp currX
    fld1

    fld currX
    fmul currX
    fadd x1

    fyl2x   

    fldln2
    fmul     ; st0 = ln(x)

    fmul x2
    fst buff1

    fldpi
	fistp pi
	fld currX
	fimul pi
	fidiv ang

    fcos
    fstp buff2
    fld buff2
    fmul buff2
    fmul buff2
    fmul buff2
    fadd x1
    fstp buff2

    fld currX
    fadd x2
    fstp buff3
    fld buff2
    fdiv buff3
    fadd buff1

    fimul k1
	fchs
	frndint
    fistp y 

	mov al, 1
	jmp point

func3:
    finit
    fild x
    fabs
    fadd x1
    fstp buff1

    fild x
    fimul x
    fiadd x
    fiadd x1

    fld1
    fxch st(1) ;st0 = x, st1 = 1
    fyl2x

    fldln2
    fmul

    fld one_third
    fmul

    fldl2e
    fmul
    f2xm1
    fld1
    fadd

    fstp buff2

    fld buff1
    fdiv buff2

    fimul k1
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