printstr macro msg
    push ax               ; Сохраняем регистры AX и DX
    push dx
    lea dx, msg           ; Загружаем адрес строки в DX
    mov ah, 09h           ; Функция DOS для вывода строки
    int 21h               ; Вызов DOS-прерывания
    pop dx                ; Восстанавливаем регистры DX и AX
    pop ax
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
	
	mov ah, var1 ; установка курсора
	mov dh, var2 ; строка
	mov dl, var3 ; столбец
	mov bh, var4 ; страница
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

;---------------------------------------------------------------
;-------------------MACROS SECTION END--------------------------
;---------------------------------------------------------------











.model small 
.stack 100h 
.data 

a db -10d 
b db -20d 
c db 15d 
d db 18d 

; a db ? 
; b db ? 
; c db ? 
; d db ?
buff db ?
inputA db "a = $"
inputB db "b = $"
inputC db "c = $"
inputD db "D = $"
res1 db "res1 = $"
res2 db "res2 = $"

result1 dw ? 
 
result2 dw ? 
 
.code 
start: 
 mov ax, @data 
 mov ds, ax 



    wipescreen


    ; setcursor 2, 11, 0, 0
    ; printstr inputA
    ; mReadAX10 buff, 4
    ; int 03h
    ; mov A, al

    ; setcursor 2, 12, 0, 0
    ; printstr inputB
    ; mReadAX10 buff, 4

    ; mov B, al

    ; setcursor 2, 13, 0, 0
    ; printstr inputC
    ; mReadAX10 buff, 4

    ; mov C, al

    ; setcursor 2, 14, 0, 0
    ; printstr inputD
    ; mReadAX10 buff, 4
    ; mov D, al

    ; xor ax, ax



 
 ; y = (a-b)*c + 10 
 ; a = 5, b = 10, c = 15, d = 8; y = -65d; ax= FFBFh 
 ; a = -5, b = -10, c = -15, d = -3; y = -65d; ax= FFBFh 
 ; a = -10, b = -20, c = 15, d = 18; y = 160d; ax= 00A0h 
 ; a = 10, b = -20, c = -15, d = 18; y = -440d; ax= FE48h 
    ; int 03h
    
    ; mov al, a 
    ; sub al, b 
    ; imul c 
    ; add ax, 10 
 
    ; mov result1, ax 

    ; xor al, al
    ; setcursor 2, 16, 0, 0
    ; printstr res1
    ; mWriteAX10
 


    ; mov ax, 0 


 ; y = (4*a + b + c)/d 
 ; a = 5, b = 10, c = 15, d = 8; y = 5; 5 ax = 05;05 
 ; a = -5, b = -10, c = -15, d = -3; y = 15; 0 ax = 00;0F 
 ; a = -10, b = -20, c = 15, d = 18; y = -2;-9 ax = F7;FE 
 ; a = 10, b = -20, c = -15, d = 18; y = 0; 5 ax = 05;00 
	int 03h
	mov al, a 
    mov bl, 4d 
    imul bl
    add al, b 
    add al, c 

    idiv d 

    setcursor 2, 17, 0, 0
    printstr res2
    mWriteAX10
 
    mov ax, 4c00h 
    int 21h 
    
end start 
end