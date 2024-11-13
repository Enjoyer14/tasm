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
	jns convert   ;Переход, если число положительное 
 	push ax   ;Регистр ax в стек 
 
	mov dx, '-'   ;Поместить в регистр dx символ '-' 
 	mov ah, 02h   ;Вывод символа на экран 
 	int 21h   ;Прерывание DOS 
 
 	pop ax    ;Регистр ax из стека 
 	neg ax    ;Инвертирование отрицательного числа  
 
convert: 
	xor dx, dx   ;Очистка регистра dx 
 
 	div cx    ;После деления dl = остатку от деления ax на cx 
 	add dl, '0'   ;Перевод в символьный формат 
 	inc di    ;Увеличение количества цифр в числе на 1 
 	
	push dx   ;Регистр dx в стек 

	or ax, ax   ;Проверка числа на ноль 
	jnz convert   ;Переход, если число не равно нулю 
 
write: 
	pop dx    ;dl = очередной символ 
 
	mov ah, 02h   ;Вывод символа на экран 
	int 21h   ;Прерывание DOS 
	dec di    ;Повторение, пока di != 0 
	jnz write  
 
	pop di    ;Данные из стека 
	pop dx 
	pop cx 
	pop bx 
	pop ax 
endm  

printstr macro msg
	push ax
	push dx

	mov ah, 09h
	mov dx, msg
	int 21h

	pop dx
	pop ax
endm

newline macro
    mov ah, 02h
    mov dl, 0Dh
    int 21h
    mov dl, 0Ah 
    int 21h
endm


.model small
.stack 100h
.data
strA db "enter x1: $"
strB db "enter x2: $"
strC db "enter x3: $"
strRes db "res = $"
buff db ?
X1 db ?
X2 db ?
X3 db ?
A dw 44
B dw 29h
C dw 7
D dw 3

Sum dw 0
Raz dw 0
Pr dw 1
Ost db ?
Chas db ?

.code
start:
	mov ax, @data
	mov ds, ax
	
	;X1
	xor ax, ax
	mov bx, offset strA
	printstr bx

	mReadAX10 buff, 4

	sub ax, A ; al = al(X1) - A
	mov Raz, ax ; заносим ответ в Raz
	
	add ax, B ; al = al + B
	mov Sum, ax 

	mul C ; ax = ax*C
	mov Pr, ax
	
	div D ; ax = ax/D
	mov Chas, al ; результат деления в ax, в al - целая часть , в ah - остаток от деления
	mov Ost, ah 

	inc al ; al++
	dec ah ; ah--

	mov bx, offset strRes
	printstr bx

	mWriteAX10

	newline

	;X2
	xor ax, ax
	mov bx, offset strB
	printstr bx
	mReadAX10 buff, 2

	sub ax, A ; al = al(X1) - A
	mov Raz, ax ; заносим ответ в Raz
	
	add ax, B ; al = al + B
	mov Sum, ax 

	mul C ; ax = ax*C
	mov Pr, ax
	
	div D ; ax = ax/D
	mov Chas, al ; результат деления в ax, в al - целая часть , в ah - остаток от деления
	mov Ost, ah 

	inc al ; al++
	dec ah ; ah--

	mov bx, offset strRes
	printstr bx

	mWriteAX10

	newline

	;X3
	xor ax, ax
	mov bx, offset strC
	printstr bx
	mReadAX10 buff, 2

	sub ax, A ; al = al(X1) - A
	mov Raz, ax ; заносим ответ в Raz
	
	add ax, B ; al = al + B
	mov Sum, ax 

	mul C ; ax = ax*C
	mov Pr, ax
	
	div D ; ax = ax/D
	mov Chas, al ; результат деления в ax, в al - целая часть , в ah - остаток от деления
	mov Ost, ah 

	inc al ; al++
	dec ah ; ah--

	mov bx, offset strRes
	printstr bx

	mWriteAX10

	newline

	mov ax, 4c00h
	int 21h
end start
end