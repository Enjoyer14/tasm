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
    mov ax, arr[si] ; Получаем байт из массива
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





mAbs macro
local exit
    cmp ax, 0
    jge exit
    neg ax
    exit:
endm

.model small
.stack
.data
    mas1 dw 13, 64, 2, 1, 56, 24, 67, 12, 74, 12, 2, 6, 90
    len1 dw 13
    mas2 dw 13 dup(?)
    len2 dw 1
    min dw 0
    tab db "    $"

.code
start:
    mov ax, @data
    mov ds, ax


    xor si, si
    xor di, di
    add di, 2
    mov ax, mas1[si]
    mAbs
    mov min, ax
    mov cx, len1
    cycle:
        mov ax, mas1[si]
        mAbs
        cmp ax, min
        jge skipSwap
        mov min, ax

    skipSwap:
        mov ax, mas1[si]
        mov bx, 2d
        xor dx, dx
        idiv bx
        cmp dx, 0
        je addToArr

        mov ax, mas1[si]
        mov bx, 3d
        xor dx, dx
        idiv bx
        cmp dx, 0
        je addToArr

        jmp skip

    addToArr:
        mov ax, mas1[si]
        mov mas2[di], ax
        add di, 2
        mov ax, len2
        inc ax
        mov len2, ax

    skip:
        add si, 2
        loop cycle

    xor di, di
    mov ax, min
    mov mas2[di], ax

    mov ax, 4c00h
    int 21h

end start