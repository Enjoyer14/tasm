printstr macro msg
	mov ah, 09h
	mov dx, msg
	int 21h
endm

inputchr macro var
	mov ah, 01h
	int 21h
	mov var, al
endm

mReadAX10 macro buffer, size
	local input, startOfConvert, endOfConvert
	push bx
	push cx
	push dx

input:
	mov [buffer], size
	mov dx, offset [buffer]
	mov ah, 0Ah
	int 21h

	mov ah, 02h
	mov dl, 0Dh
	int 21h
	
	mov ah, 02h
	mov dl, 0Ah
	int 21h

	xor ah, ah
	cmp ah, [buffer][1]
	jz input

	xor cx, cx
	mov cl, [buffer][1]

	xor ax, ax
	xor bx, bx
	xor dx, dx
	mov bx, offset [buffer][2]

	cmp [buffer][2], '-'
	jne startOfConvert
	inc bx
	dec cl

startOfConvert:
	mov dx, 10
	mul dx
	cmp ax, 8000h
	jae input

	mov dl, [bx]
	sub dl, '0'

	add ax, dx
	cmp ax, 8000h
	jae input

	inc bx
	loop startOfConvert

	cmp [buffer][2], '-'
	jne endOfConvert
	neg ax

endOfConvert:
	pop dx
	pop cx
	pop bx
endm

mWriteAX10 macro
local convert, write
	push ax
	push bx
	push cx
	push dx
	push di

	mov cx, 10
	xor di, di

	or ax, ax
	jns convert
 	push ax
 
	mov dx, '-'
 	mov ah, 02h
 	int 21h
 
 	pop ax
 	neg ax
 
convert: 
	xor dx, dx
 
 	div cx
 	add dl, '0'
 	inc di
 	
	push dx

	or ax, ax
	jnz convert
 
write: 
	pop dx
 
	mov ah, 02h
	int 21h
	dec di
	jnz write  
 
	pop di 
	pop dx 
	pop cx 
	pop bx 
	pop ax 
endm

setcursor macro var1, var2, var3, var4
	push ax
	push dx
	push bx
	
	mov ah, var1 установка курсора
	mov dh, var2 строка
	mov dl, var3 ;столбец
	mov bh, var4   ; страница
	int 10h

	pop bx
	pop dx
	pop ax
endm

wipescreen macro
	push ax
	push bx
	push cx
	push dx
	mov ax, 0600h
	mov bh, 07
	mov cx, 0
	mov dx, 184Fh
	int 10h
	pop dx
	pop cx
	pop bx
	pop ax
endm

.model small
.stack 100h
.data
a1 dw ?
b1 dw ?
c1 dw ?
x1 dw ?
buff db ?
menumsg1 db "1. F = -a*x^3 - b ( x+c<0 , a!=0 )$"
menumsg2 db "2. F = (x-a)/(x-c) ( x+c>0, a=0 )$"
menumsg3 db "3. F = x/c + c/x ( else )$"
res db "Result = $"
result dw ?
inputA1 db "a1 = $"
inputB1 db "b1 = $"
inputC1 db "c1 = $"
inputX1 db "x1 = $"
.code

start:
	mov ax, @data
	mov ds, ax

	wipescreen

	; Отображение меню
	setcursor 2, 8, 24, 0
	mov bx, offset menumsg1
	printstr bx

	setcursor 2, 9, 24, 0
	mov bx, offset menumsg2
	printstr bx

	setcursor 2, 10, 24, 0
	mov bx, offset menumsg3
	printstr bx

	setcursor 2, 11, 0, 0

	;ввод значений для a1, b1, c1 и x1
	mov bx, offset inputA1
	printstr bx
	mReadAX10 buff, 4
	mov a1, ax

	mov bx, offset inputB1
	printstr bx
	mReadAX10 buff, 4
	mov b1, ax

	mov bx, offset inputC1
	printstr bx
	mReadAX10 buff, 4
	mov c1, ax

	mov bx, offset inputX1
	printstr bx
	mReadAX10 buff, 4
	mov x1, ax

	mov ax, x1
	add ax, c1
	cmp ax, 0
	jl isANonZero ; если x + c < 0 то в л1
	jmp isCase2

isANonZero:
	cmp a1, 0 ; если а != 0 то в кейс1
	jne case1
	jmp case3 ; иначе прыгаем в иначе

isCase2:
	xor ax, ax ; если x+c > 0 то прыгаем в кейс3
	mov ax, x1
	add ax, c1
	cmp ax, 0
	jg isAZero
	jmp case3

isAZero:
	cmp a1, 0
	je case2
	jmp case3

case1:
	;F = -a*x^3 - b
	mov ax, x1
	imul ax
	imul x1
	imul a1
	neg ax
	sub ax, b1
	mov result, ax
	jmp output

case2: 
	;F = (x - a) / (x - c)
	mov ax, x1
	sub ax, a1 ; ax = x - a
	mov bx, x1
	sub bx, c1 ; bx = x - c

	cwd ; Расширяем знак в dx
	idiv bx ; ax = (x - a) / (x - c)
	mov result, ax
	jmp output

case3: 
	;F = x/c + c/x
	mov ax, x1
	cwd ;Расширяем знак в dx
	idiv c1 ; ax = x / c
	mov bx, ax ;сохраняем результат x/c в bx

	mov ax, c1
	cwd ; расширяем знак в dx
	idiv x1 ; ax = c / x
	add ax, bx ; ax = x/c + c/x
	mov result, ax
	jmp output

output:
	mov bx, offset res
	printstr bx
	mov ax, result
	mWriteAX10
	
	mov ax, 4c00h
	int 21h
end start
