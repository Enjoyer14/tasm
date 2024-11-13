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

printnum macro num
	mov ax, num

	; Проверка на отрицательное число
	cmp ax, 0
	jge print_positive
	neg ax
	mov dl, '-' ;печать минус
	mov ah, 02h
	int 21h

print_positive:
	mov bx, 10
	mov cx, 0

convert_loop:
	xor dx, dx ; Обнуляем DX
	div bx ; Делим AX на 10, результат в AX, остаток в DX
	push dx ; Остаток (цифра) сохраняется в стеке
	inc cx ; Увеличиваем счетчик цифр
	cmp ax, 0
	jne convert_loop ; Продолжаем, пока AX не станет 0

print_digits:
	pop dx ; Извлекаем цифры из стека
	add dl, '0' ; Преобразуем цифру в ASCII
	mov ah, 02h
	int 21h ; Печать цифры
	loop print_digits ; Повторяем, пока CX не станет 0
endm

.model small
.stack 100h
.data
a1 dw -5d
b1 dw 1d
c1 dw 8d
x1 dw 6d
a2 dw 0d
b2 dw 5d
c2 dw 1d
x2 dw 2d
a3 dw 6d
b3 dw 9d
c3 dw 8d
x3 dw 8d
menumsg1 db "1. F = -a*x^3 - b $"
menumsg2 db "2. F = (x-a)/(x-c) $"
menumsg3 db "3. F = x/c + c/x $"
inputmsg db "Choice: $"
res db "Result = $"
result dw ?
inputch db ?
.code
start:
	mov ax, @data
	mov ds, ax
    
	mov ah, 2   ; установка курсора
	mov dh, 8   ; строка
	mov dl, 24  ; столбец
	mov bh, 0   ; страница
	int 10h

	printstr offset menumsg1

	mov ah, 2
	mov dh, 9
	mov dl, 24
	mov bh, 0
	int 10h

	printstr offset menumsg2

	mov ah, 2
	mov dh, 10
	mov dl, 24
	mov bh, 0
	int 10h

	printstr offset menumsg3

	mov ah, 2
	mov dh, 11
	mov dl, 24
	mov bh, 0
	int 10h

	printstr offset inputmsg

	; Ввод символа
	inputchr inputch

	mov ah, 2
	mov dh, 12
	mov dl, 0
	mov bh, 0
	int 10h

	cmp inputch, '1'
	je case1
	cmp inputch, '2'
	je case2
	cmp inputch, '3'
	je case3
	jmp output

case1:
	; Вычисление F = -a*x^3 - b
	mov ax, x1
	imul ax
	imul x1
	imul a1
	neg ax
	sub ax, b1
	mov result, ax
	jmp output

case2: 
	; Вычисление F = (x - a) / (x - c)
	mov ax, x2
	sub ax, a2        ; ax = x - a
	mov bx, x2
	sub bx, c2        ; bx = x - c

	cmp bx, 0 ; Проверяем деление на ноль
	je division_error ; Переход на обработку ошибки деления на ноль

	cwd ; Расширяем знак в DX перед делением
	idiv bx ; ax = (x - a) / (x - c)
	mov result, ax
	jmp output

division_error:
	mov result, 0 ; Можно установить 0 или специальное значение для обозначения ошибки
	jmp output

case3: 
	; Вычисление F = x/c + c/x
	mov ax, x3
	cmp ax, 0 ; Проверяем деление на ноль
	je division_error ; Переход на обработку ошибки деления на ноль

	cwd ; Расширяем знак в DX перед делением
	idiv c3 ; ax = x / c
	mov bx, ax ; Сохраняем результат x/c в BX

	mov ax, c3
	cmp ax, 0 ; Проверяем деление на ноль
	je division_error ; Переход на обработку ошибки деления на ноль

	cwd ; Расширяем знак в DX перед делением
	idiv x3 ; ax = c / x
	add ax, bx ; Складываем результаты
	mov result, ax
	jmp output

output:
	printstr offset res
	printnum result
	
	mov ax, 4c00h
	int 21h
end start
