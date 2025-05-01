printstr MACRO msg
    PUSH AX               ; Сохраняем регистры AX и DX
    PUSH DX
    LEA DX, msg           ; Загружаем адрес строки в DX
    MOV AH, 09h           ; Функция DOS для вывода строки
    INT 21h               ; Вызов DOS-прерывания
    POP DX                ; Восстанавливаем регистры DX и AX
    POP AX
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

.MODEL SMALL
.STACK 100H
.DATA
 a DW ? ; переменная a
 b DW ? ; переменная b
 x DW ? ; переменная X (результат)
 inputA db 'Enter a: $'
 inputB db 'Enter b: $'
 resX db 'Result = $'
 buffer db ?

.CODE
MAIN PROC
 MOV AX, @DATA ; загрузка сегмента данных
 MOV DS, AX

 ; Ввод значений a и b (замените на реальные числа)
 ;MOV a, 7 ; Значение a
 ;MOV b, 3 ; Значение b
 ;ввод a
 printstr inputA
 mReadAX buffer, 5
 MOV a, AX
 ;ввод b
 printstr inputB
 mReadAX buffer, 5
 MOV b, AX
 ; Проверка условия a < b
 MOV AX, a
 CMP AX, b
 JL LESS_THAN ; Переход к вычислению (3*a - 5) / b, если a < b
 ; Проверка условия a = b
 JE EQUAL ; Переход к x = -4, если a = b

 ; Иначе (a > b) вычисляем (a^3 + b) / a
 JMP GREATER_THAN

LESS_THAN:
 ; X = (3 * a - 5) / b
 MOV AX, a
 MOV BX, 3
 MUL BX ; AX = 3 * a
 SUB AX, 5 ; AX = 3 * a - 5
 MOV BX, b
 DIV BX ; AX = (3 * a - 5) / b
 MOV x, AX
 JMP END_PROGRAM

EQUAL:
 ; X = -4
 MOV ax, -4
 MOV x, ax
 JMP END_PROGRAM

GREATER_THAN:
 ; X = (a^3 + b) / a
 MOV AX, a
 IMUL AX ; AX = a^2
 IMUL a ; AX = a^3
 ADD AX, b ; AX = a^3 + b
 MOV BX, a
 IDIV BX ; AX = (a^3 + b) / a
 MOV x, AX

END_PROGRAM:
 printstr resX
 mWriteAX
 ; Завершение программы
 MOV AX, 4C00H
 INT 21H
MAIN ENDP
END MAIN