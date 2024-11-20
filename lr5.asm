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

mReadArr macro arr, n
local loop_start
    push cx
    push si

    xor cx, cx
    xor si, si
    mov cx, n       ; n - количество элементов

loop_start:
    mReadAX buffer, 3  ; Читаем число в ax
    mov arr[si], al    ; Сохраняем младший байт в массив
    inc si             ; Переходим к следующему элементу
    loop loop_start    ; Повторяем для всех элементов

    pop si
    pop cx
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

mTask macro arr, n
local loop_start, next_it, start_write, incDX
    push bx
    push cx
    push si
    push dx

    xor cx, cx
    xor bx, bx
    xor si, si
    xor dx, dx
    
    mov dx, 0

    mov cx, n      ; n - количество элементов
loop_start:
    mov al, arr[si]

    cmp dx, 3
    je start_write
    cmp al, 0
    jl incDX
    jmp next_it

incDX:
    inc dx
    jmp next_it

start_write:    
    cbw
    mWriteAX
    xor ax, ax 
    push bx
    mov bx, offset tab
    printstr bx 
    pop bx
next_it:
    inc si
    loop loop_start

    pop si
    pop cx
    pop bx
endm

.model small
.stack 100h
.data
    arr db 15 dup(?)    ; Массив для хранения чисел (максимум 15 байтов)
    ssize db 'Enter n: $'
    sarr db 'Arr: $'
    sres db 'Res: $'
    endl db 0Dh, 0Ah, '$'
    tab db '  $'
    buffer db ?

.code
start:
JUMPS
    mov ax, @data
    mov ds, ax

    wipescreen
    xor ax, ax
    ; Ввод размера массива
    mov bx, offset ssize
    printstr bx
    mReadAX buffer, 3
    mov di, ax
    cmp ax, 15
    jg end_prog  ; Проверка на корректность размера массива

    ; Ввод элементов массива
    mReadArr arr, di

    ; Вывод элементов массива
    mov bx, offset sarr
    printstr bx
    mWriteArr arr, di

    mov bx, offset endl
    printstr bx

    mov bx, offset sres
    printstr bx

    mTask arr, di

end_prog:
    mov ax, 4c00h
    int 21h
    NOJUMPS
end start