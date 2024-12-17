mPrintStr macro msg
    push ax               ; Сохраняем регистры AX и DX
    push dx
    lea dx, msg           ; Загружаем адрес строки в DX
    mov ah, 09h           ; Функция DOS для вывода строки
    int 21h               ; Вызов DOS-прерывания
    pop dx                ; Восстанавливаем регистры DX и AX
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

mReadMatrix macro matrix, row, col    
local rowLoop, colLoop  
JUMPS             ; Директива, делающая возможным большие прыжки 
    push bx       ; Сохранение регистров, используемых в макросе, в стек 
    push cx 
    push si 
 
    xor bx, bx    ; Обнуляем смещение по строкам 
    mov cx, row 
rowLoop:          ; Внешний цикл, проходящий по строкам 
    push cx 
 
    xor si, si    ; Обнуляем смещение по столбцам 
    mov cx, col  
colLoop:              ; Внутренний цикл, проходящий по столбцам 
    mReadAX buffer, 5  ; Макрос ввода значения регистра AX с клавиатуры  
                      ; [Приложение 1] 
 
    mov matrix[bx][si], ax 
    add si, 2         ; Переходим к следующему элементу (размером в слово) 
    loop colLoop 

    add bx, col       ; Увеличиваем смещение по строкам  
    add bx, col       ; (дважды, так как размер каждого элемента - слово) 
 
    pop cx 
    loop rowLoop 
 
    pop si            ; Перенос сохранённых значений обратно в регистры  
    pop cx 
    pop bx 
NOJUMPS               ; Прекращение действия директивы JUMPS 
endm mReadMatrix 

mWriteMatrix macro matrix, row, col      
local rowLoop, colLoop  
    push ax       ; Сохранение регистров, используемых в макросе, в стек 
    push bx 
    push cx 
    push si 
 
    xor bx, bx    ; Обнуляем смещение по строкам 
    mov cx, row 
rowLoop:          ; Внешний цикл, проходящий по строкам 
    push cx  
 
    xor si, si    ; Обнуляем смещение по столбцам 
    mov cx, col 
colLoop:                    ; Внутренний цикл, проходящий по столбцам 
    mov ax, matrix[bx][si]  ; bx - смещение по строкам, si - по столбцам 
 
    mWriteAX      ; Макрос вывода значения регистра AX на экран [Приложение 2] 
                  ; Вывод текущего элемента матрицы 
    xor ax, ax 
    mPrintStr tab; Макрос вывода строки на экран Приложение 3

    add si, 2         ; Переходим к следующему элементу (размером в слово) 
    loop colLoop 
    
    mPrintStr endl   ; Макрос вывода строки на экран Приложение 3                ; Перенос курсора и каретки на следующую строку 
    
    add bx, col       ; Увеличиваем смещение по строкам  
    add bx, col       ; (дважды, так как размер каждого элемента - слово) 
    pop cx 
    loop rowLoop 
 
    pop si            ; Перенос сохранённых значений обратно в регистры  
    pop cx 
    pop bx 
    pop ax 
endm mWriteMatrix 

mPrintLine macro matrix, row, col, row_to_print			;вывести строку матрицы на экран
local colLoop
	push ax
	push bx
	push cx
	push si
	xor si, si
	mov cx, col
	mov ax, row_to_print
	;mov bx, col
	;mul bx
	;add ax, ax
	mov bx, row_to_print
	colLoop:
		mov ax, matrix[bx][si]
		mWriteAX
		mPrintStr tab
		add si, 2
		loop colLoop
	mPrintStr endl
	pop si
	pop cx
	pop bx
	pop ax
endm mPrintLine	

mTransposeMatrix macro matrix, row, col, resMatrix    
local rowLoop, colLoop  
    push ax         ; Сохранение регистров, используемых в макросе, в стек 
    push bx 
    push cx 
    push di 
    push si 
    push dx 
 
    xor di, di            ; Обнуляем смещение по строкам 
    mov cx, row 
rowLoop:                  ; Внешний цикл, проходящий по строкам 
    push cx 
    xor si, si            ; Обнуляем смещение по столбцам 
    mov cx, col 
colLoop:                  ; Внутренний цикл, проходящий по столбцам 
    mov ax, col 
    mul di                ; Устанавливаем смещение по строкам 
    add ax, si            ; Устанавливаем смешение по столбцам 
    mov bx, ax 
    mov ax, matrix[bx] 
    push ax               ; Заносим текущий элемент в стек 
 
    mov ax, row          
    mul si                ; Устанавливаем смещение по строкам 
    add ax, di            ; Устанавливаем смешение по столбцам 
                          ;  (смещения по строкам и столбцам меняются      
                          ;   местами по сравнению с оригинальной матрицей) 
    mov bx, ax 
    pop ax 
    mov resMatrix[bx], ax  ; Заносим в новую матрицу элемент,               
                          ; сохранённый в стеке 
    
    add si, 2             ; Переходим к следующему элементу             
                          ;  (размером в слово) 
    loop colLoop 
     
    add di, 2             ; Переходим к следующей строке 
    pop cx 
    loop rowLoop 
 
    pop dx                ; Перенос сохранённых значений обратно в регистры  
    pop si 
    pop di 
    pop cx 
    pop bx 
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


pause macro 
    mPrintStr endl
    mov ah, 08h
    int 21h
endm

mTask1 macro matrix, row, col, summa, multip, buff
local rowLoop, colLoop, convert, write, numberIsEven, odd, nextCol
JUMPS
    push ax
	push bx
	push cx
	push dx
	push di
	push si

    xor bx, bx    ; Обнуляем смещение по строкам
    xor dx, dx   ; произведение
    xor si, si    ; Счетчик столбцов
    mov cx, col   ; Устанавливаем количество столбцов
colLoop:
    xor bx, bx    ;сбрасываем смещение по строкам
    mov dx, 1d
    mov multip, dx
    push cx       ; Сохраняем текущий счетчик столбцов
    mov cx, row   ; Устанавливаем количество строк
rowLoop:
    mov ax, matr[bx][si]
    mov buff, ax
    push ax      ; Сохранение регистров, используемых в макросе, в стек 
    push bx 
    push cx 
    push dx 
    push di 
 
    mov cx, 10   ; cx - основание системы счисления 
    xor di, di   ; di - количество цифр в числе 
 
    or ax, ax    ; Проверяем, равно ли число в ax нулю и устанавливаем флаги 
    jns convert  ; Переход к конвертированию, если число в ax положительное     
    neg ax       ; Инвертируем отрицательное число 
     
convert:   
    xor dx, dx 
 
    div cx       ; После деления dl = остатку от деления ax на cx 
    add dl, '0'  ; Перевод в символьный формат 
    inc di       ; Увеличиваем количество цифр в числе на 1   
 
    push dx      ; Складываем в стек 
 
    or ax, ax    ; Проверяем, равно ли число в ax нулю и устанавливаем флаги 
    jnz convert  ; Переход к конвертированию, если число в ax не равно нулю  
    xor ax, ax
write:           ; Вывод значения из стека на экран 
    pop dx       ; dl = очередной символ 
    add ax, dx
    dec di       ; Повторяем, пока di <> 0 
    jnz write   
    
    xor dx, dx
    mov bx, 2d
    div bx
    cmp dx, 0
    je numberIsEven
    jmp odd

numberIsEven:
    mov ax, multip
    mov bx, buff
    imul bx
    mov multip, ax

odd:
    pop di       
    pop dx 
    pop cx 
    pop bx 
    pop ax


    add bx, col
    add bx, col
    loop rowLoop

    mov ax, multip
    mWriteAX
    mPrintStr tab

    jmp nextCol

nextCol:
    pop cx   
    add si, 2  
    loop colLoop 


    pop si
	pop di
	pop dx
	pop cx
	pop bx
	pop ax
    NOJUMPS
endm

mTask2 macro matrix, row, col, max, min, minId, maxId, temp, line, line2
local colLoop, rowLoop, changeMax, changeMin, swap, checkCond, newColLoop, needed, notNeed, endOutIter, end_iter
JUMPS
	push ax
	push bx
	push cx
	push dx
	push di
	push si
	mov cx, row
	xor si, si
	xor ax, ax
	xor bx, bx

	rowLoop:
		
		push cx
		xor si, si
		mov maxId, 0
		mov minId, 0
		mov ax, matrix[bx][si]		
		mov max, ax
		mov min, ax
		mov cx, col
		colLoop:				;проходим постолбцам, находим мин и макс
			mov ax, matrix[bx][si]
			cmp ax, max
			jg changeMax
			cmp ax, min
			jl changeMin
			jmp end_iter
			changeMax:
				mov max, ax
				mov maxId, si
				jmp end_iter
			changeMin:
				mov min, ax
				mov minId, si
				jmp end_iter
			end_iter:
				add si, 2
				loop colLoop
		mov ax, minId
		cmp ax, maxId
		je endOutIter
		jg swap				;если максимальное до минимального, то свапнуть позиции, чтобы идти от меньшего к большему индексу
		jmp checkCond
		swap:
			mov ax, minId
			mov dx, maxId
			mov minId, dx
			mov maxId, ax
			jmp checkCond
		checkCond:
			mov ax, maxId
			dec ax
			cmp ax, minId
			je endOutIter
			xor cx, cx
			mov ax, maxId
			sub ax, minId
			cwd
			mov cl, 2
			div cl
			mov cx, ax
			dec cx
            cmp cx, 1d
            jle notNeed
			mov si, minId
			add si, 2
			mov ax, matrix[bx][si]
			
			newColLoop:				;ну а тут по строке проходим и ищем убывание между макс и мин
				mov min, ax
				add si, 2
				mov ax, matrix[bx][si]
				cmp min, ax
				jg notNeed
				loop newColLoop
			jmp needed
			needed:
				mov ax, bx
				cwd
				mov cx, col
				div cx
				mov cl, 2			;если не нашли убывания - значит, все как надо
				div cl
				inc ax
				mPrintStr endl
				mPrintStr line
				mWriteAx
				mPrintStr line2
				mPrintStr tab
				;dec ax
				mov temp, bx
				mPrintLine matrix, row, col, temp
				mPrintStr endl
				jmp endOutIter
			notNeed:
				jmp endOutIter
			endOutIter:
				add bx, col
				add bx, col
				pop cx
				loop rowLoop

	pop si
	pop di
	pop dx
	pop cx
	pop bx
	pop ax
			
	NOJUMPS
endm task2


mTask3 macro matrix, row, col, sortedLine, rowNum, tempRow, min
local copyLoop, inLoop, rowLoop, swap, nextIter
	push ax
	push bx
	push cx
	push si
	push di
	mov ax, rowNum
	dec ax
	mov bx, col
	mul bl
	add ax, ax
	mov bx, ax
	mov cx, col
	xor si, si
	xor di, di
copyLoop:
	mov ax, matrix[bx][si]
	mov tempRow[si], ax
	add si, 2
	loop copyLoop

	xor si, si
	mov cx, col
outLoop:
	push cx
	mov cx, col
	xor si, si
	mov min, 7FFFh

inLoop:
	mov ax, tempRow[si]
	cmp ax, min
	jl swap
	jmp nextIter

swap:
	mov ax, min
	xchg ax, tempRow[si]
	mov min, ax
	jmp nextIter

nextIter:
	add si, 2
	loop inLoop
	mov ax, min
	mov sortedLine[di], ax
	add di, 2
	pop cx
	loop outLoop

	mWriteMatrix sortedLine, 1, col
	pop di
	pop si
	pop cx
	pop bx
	pop ax

endm task3

.model small
.stack 100h
.data
matr dw 15 dup(15 dup (?))
tMatr dw 15 dup(15 dup(?))
row dw ?
col dw ?
trow dw ?
tcol dw ?
tab db '	$'
endl db 0Dh, 0Ah, '$'
buffer db ?
sTask1 db '      Transpose matrix: $'
sMatr db 'Matrix: $'
sMenu db '1. Input matrix', 0Dh, 0Ah, '2. Print matrix', 0Dh, 0Ah, '3. Transpose matrix', 0Dh, 0Ah, '4. Task #1', 0Dh, 0Ah, '5. Task #2', 0Dh, 0Ah, '6. Task #3', 0Dh, 0Ah,'0. Exit', 0Dh, 0Ah, '$'
sChoose db 'Your choice: $'
sError db 'Incorrect value, try again $'
sInputMatr db 'Enter Matr: $'
sInputR db 'Enter number of rows: $'
sInputC db 'Enter number of cols: $'
line db 'Row # $'
line2 db ': $' 
max dw (?)
min dw (?)
minId dw (?)
maxId dw (?)
temp dw (?)

buff dw ?
multip dw 1
summa dw 0

sorted_line db 'Sorted line: $'

sChooseLine db 'Enter # of row : $'
sortedLine dw 20 dup (?)
rowNum dw (?)
tempLine dw 20 dup (?)

.code
start:
    mov ax, @data
    mov ds, ax

    wipescreen
    xor ax, ax
    mPrintStr sInputR
    mReadAX buffer, 3
    mov row, ax
    mov tcol, ax
    xor ax, ax
    mPrintStr sInputC
    mReadAX buffer, 3
    mov col, ax
    mov trow, ax
    xor ax, ax
    mPrintStr sInputMatr
    mPrintStr endl
    mReadMatrix matr, row, col

menuLoop:
    wipescreen
    mPrintStr sMenu
    mPrintStr endl
    mPrintStr sChoose

    mReadAX buffer, 2

    JUMPS
    cmp ax, 1
    je enterMatr
    cmp ax, 2
    je printMatr
    cmp ax, 3
    je taskTranspose
    cmp ax, 4
    je task1
    cmp ax, 5
    je task2
    cmp ax, 6
    je task3
    cmp ax, 0
    je exitProgram
    jmp menuLoop
enterMatr:
    xor ax, ax
    mPrintStr sInputR
    mReadAX buffer, 3
    mov row, ax
    mov tcol, ax
    xor ax, ax
    mPrintStr sInputC
    mReadAX buffer, 3
    mov col, ax
    mov trow, ax
    xor ax, ax
    mPrintStr sInputMatr
    mPrintStr endl
    mReadMatrix matr, row, col
    jmp menuLoop

printMatr:
    mPrintStr endl
    mPrintStr sMatr
    mPrintStr endl
    mWriteMatrix matr, row, col
    mPrintStr endl
    pause
    jmp menuLoop

taskTranspose:
    mPrintStr endl
    mWriteMatrix matr, row, col
    mPrintStr endl

    mPrintStr sTask1
    mPrintStr endl
    mTransposeMatrix matr, row, col, tMatr
    mWriteMatrix tMatr, trow, tcol
    pause
    jmp menuLoop

task1:
    mPrintStr endl
    mWriteMatrix matr, row, col
    mPrintStr endl
    mTask1 matr, row, col, summa, multip, buff
    mPrintStr endl
    pause
    jmp menuLoop

task2:
JUMPS
    mPrintStr endl
	mWriteMatrix matr, row, col
    mPrintStr endl

	mTask2 matr, row, col, max, min, minId, maxId, temp, line, line2
	mPrintStr endl

    pause
    jmp menuLoop

task3:
    JUMPS

    mPrintStr endl
    mWriteMatrix matr, row, col
    mPrintStr endl

    mPrintStr sChooseLine
	mReadAX buffer, 3
	cmp ax, row
	jg menuLoop
	cmp ax, 0
	jle menuLoop
	
    mov rowNum, ax

	mPrintStr sorted_line
	mPrintStr endl
	mTask3 matr, row, col, sortedLine, rowNum, tempLine, min
    pause
    jmp menuLoop
exitProgram:
NOJUMPS
    mov ax, 4c00h
    int 21h
end start
