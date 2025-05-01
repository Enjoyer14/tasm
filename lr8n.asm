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
k3 dw 200
two dw 2  
medX dw 319
medY dw 174
first dd ?
buff1 dd ?
buff2 dd ?
buff3 dd ?
polovina dd 0.5
x2 dd 2.0
x1 dd 1.0
currX dd ?
EXIT db 0
OLD_CS dw ?  
OLD_IP dw ? 
chastota dw 5000
one_fifth dd 0.2
k30 dw 60
k10 dw 10
x3 dd 3.0
one dw 1
much dw 5500
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
    cmp ax, 1000       ; Проверяем границу (не ниже 300)
    ja freq_ok
    mov ax, 5000      ; Сбросить на максимальную частоту
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
    mov al, 10
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
 
    mov cx, 640

metka3:
	finit
    cmp EXIT, 0 
    jne endProg
	sub cx, medX
	mov x, cx
	add cx, medX
	mov ax, cx
	mul k1
	mov cx, ax
	cmp cx, 319
	jl v1
	jmp branch
	v1:;x<0
		fild x
		fimul x
        fiadd one
        fsqrt
        fstp first
        fild x
        fmul x3
        fadd first
		fchs
		frndint
		fistp y 
		mov al, 1
		jmp point
	branch:
		cmp cx, 335
		jl v2
		jmp v3
	v2:;[0,1]
		fild x
        fcos
        fmul x2
        fstp first

        fild x
        fmul x2
        fchs

        ; Вычисляем e^(-2x)
        fldl2e                  ; Загружаем log2(e)
        fmul                    ; Умножаем на -2x
        f2xm1                   ; Вычисляем 2^(-2x * log2(e)) - 1
        fld1                    ; Загружаем 1.0
        fadd                    ; Добавляем 1, чтобы получить e^(-2x)
        ; Умножаем 2cos(x) на e^(-2x)
        fmul first

        fild x
        fiadd k30
        fmul st(0), st(0)
        fisub much

        fidiv k30
		;fchs
		frndint
		fistp y 
		mov al, 0
		jmp point
	v3:;x>1
        fild x
        fmul x3
        fstp first
        fldpi
		fistp pi
		fld first
		fimul pi
		fidiv ang
        fsin
        fmul x2

		fimul k10
		fchs
		frndint
		fistp y 
		mov al, 3
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