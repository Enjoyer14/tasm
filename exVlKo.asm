printstr macro msg
    push ax
    push dx
    mov ah, 09h
    mov dx, msg
    int 21h
    pop dx
    pop ax
endm

mWriteAX macro               
local convert, write 
    push ax      ; Сохранение регистров, используемых в макросе, в стек 
    push bx 
    push cx 
    push dx 
    push di 
 
    mov cx, 10   ; cx - основание системы счисления 
    xor di, di   ; di - количество цифр в числе 
 
    or ax, ax    ; Проверяем, равно ли число в ax нулю и устанавливаем флаги 
    jns convert  ; Переход к конвертированию, если число в ax положительное 
          
    push ax 
 
    mov dx, '-' 
    mov ah, 02h  ; 02h - функция вывода символа на экран 
    int 21h      ; Вывод символа "-" 
 
    pop ax      
    neg ax       ; Инвертируем отрицательное число 
     
convert:   
    xor dx, dx 
 
    div cx       ; После деления dl = остатку от деления ax на cx 
    add dl, '0'  ; Перевод в символьный формат 
    inc di       ; Увеличиваем количество цифр в числе на 1   
 
    push dx      ; Складываем в стек 
 
    or ax, ax    ; Проверяем, равно ли число в ax нулю и устанавливаем флаги 
    jnz convert  ; Переход к конвертированию, если число в ax не равно нулю  
 
write:           ; Вывод значения из стека на экран 
    pop dx       ; dl = очередной символ 
 
    mov ah, 02h 
    int 21h      ; Вывод очередного символа 
    dec di       ; Повторяем, пока di <> 0 
    jnz write   
 
; Перенос сохранённых значений обратно в регистры  
pop di       
pop dx 
pop cx 
pop bx 
pop ax 
endm mWriteAX 

mReadAX macro buffer, size
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


mWriteArr macro arr, n
local loop_start
    push cx
    push si

    xor cx, cx
    xor si, si
    mov cx, n      ; n - количество элементов

loop_start:
    mov al, arr[si] ; Получаем байт из массива
    cbw             ; Расширяем байт в слово для корректной работы
    mWriteAX        ; Выводим число
    push bx
    mov bx, offset tab
    printstr bx 
    pop bx
    inc si          ; Переходим к следующему элементу
    loop loop_start ; Повторяем для всех элементов

    pop si
    pop cx
endm

.model small
.stack
.data
    mas1 db 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 1, 1
    len1 dw 12
    mas2 db 13 dup(?)
    len2 dw 1
    tab db '	$'
    endl db 0Dh, 0Ah, '$'
    count dw 1
    flag db 0

.code
start:
    mov ax, @data
    mov ds, ax

    xor si, si
    xor di, di
    mov al, mas1[si]
    mov flag, al
    mov cx, len1
    cycle1:
        mov al, mas1[si]
        cmp al, flag ; показывает прошлое значение(то есть одинаковое или нет)
        jne change

        mov ax, count ; прибавляем количество текущего значения
        inc ax
        mov count, ax
        
        jmp skip

        change:
            mov flag, al
            mov ax, count
            mov mas2[di], al
            add di, 1
            mov ax, 1
            mov count, ax
            mov ax, len2
            inc ax
            mov len2, ax

        skip:
            add si, 1
            loop cycle1

    mov ax, count
    mov mas2[di], al
    add di, 1

    mov ax, 4c00h
    int 21h

end start