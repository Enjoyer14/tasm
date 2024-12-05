.model small 
.386
.stack 200h

.DATA
					         db 'MEOW: $'
	M				         dw 0	
					         db 'MEOW: $'
	N				         dw 0
					         db 'MEOW: $'
	MATRIX			         dw 100*100 dup (0)
					         db 'MEOW: $'
	MATRIX_RES		         dw 100*100 dup ('1') 	
					         db 'MEOW: $'			
	mess1			         db "Enter N: ", '$'
	mess2			         db "Enter M: ", '$'
	mess3			         db "Enter your choice: ", '$'
					         
	mes_res			         db "Result: ", '$'
	mes_matr		         db "Matrix: ", '$'
	new_line		         db 13,10,'$'
					         
	buf                      db 200, 200 dup (?) 			;Буфер для ввода числа с клавиатуры
					         
	line			         db 49 dup(03),'$'
	men1_mes1                db 03,"   1. Fill the matrix with random numbers?     ", 03,'$'
	men1_mes2                db 03,"   2. Fill the matrix with your numbers?       ", 03,'$'
	mes_exit                 db 03,"   0. Exit                                     ", 03,'$'
					         													
					         													
	men2_mes1                db "|   1. Transposition                            |",'$'
	men2_mes2                db "|   2. Task A                                   |",'$'
	men2_mes3                db "|   3. Task B                                   |",'$'
	men2_mes4                db "|   4. Task C                                   |",'$'
	                         db 'MEOW: $'
	choice                   dw  100
	MIN                      dw -50
	MAX                      dw 50 
	counter                  db 0
	_enter                   db 'Enter $'
	arr_num                  db ' array number: $'
	tab                      db '    ', '$'
	mes_try                  db 'Incorrect input. Please, try again. $'
	mes_trans_mat            db 'Transposed matrix: $'
					         
	max_elements             db 100 dup(0)    ; для хранения минимальных элементов строк (Task A)

	flag_first_negative      db 0

	col2					 dw 0
	row2					 dw 0
							 
	sum						 dw 0

	col_res                  dw 0 

	max_el                   dw 0

						     db 'MEOW: $'
	matrix_sum_res           dw 100 dup(0)

	dva                      db 2

.CODE
start:   
mov ax, @data
mov ds, ax
sub ax, ax

MCUR MACRO CH1, CH2, CH3
		push ax
		push dx
		push bx

		mov ah, CH1
		mov dh, CH2
		mov dl, CH3
		mov bh, 0
		int 10h

		pop ax
		pop dx
		pop bx

	ENDM MCUR


PRINT_NUMBER macro number
    local ConvertLoop,OutputLoop
    mov cx, 0
    mov bx, 10
    mov ax, number
    push ax
    cmp ax, 0
    jge ConvertLoop
    mov ah, 02h
    mov dl, '-'
    int 21h
    pop ax
    neg ax
    ConvertLoop:
    xor dx, dx
    div bx
    add dl, '0'
    push dx
    inc cx
    cmp ax, 0
    jne ConvertLoop
    OutputLoop:
    pop dx
    mov ah, 02h
    int 21h
    loop OutputLoop
ENDM PRINT_NUMBER 

mWriteAx macro
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
endm mWriteAx

mReadAX10 macro number  
    Local EnterDigit, NextDigit, EndInput
    mov ah, 01h
    int 21h
    mov si, 1
    cmp al, '-'
    jne EnterDigit
    mov si, -1
    mov ah, 01h
    int 21h
    EnterDigit:
    mov cx, 0
    NextDigit:
    cmp al, 13              ; Проверка на Enter
    je EndInput			    
    mov ah, 0			    
    sub al, '0'             ; Преобразование ASCII в число
    xchg ax, cx			    
    mov bx, 10			    
    mul bx                  ; Умножение cx на 10
    add cx, ax              ; Добавление нового символа
    mov ah, 01h			    
    int 21h                 ; Чтение следующего символа
    jmp NextDigit		    
    EndInput:			    
    mov ax, cx			    
    imul si                 ; Умножение на знак (1 или -1)
    mov number, ax          ; Сохранение результата
ENDM READ_NUMBER 

Set_cursor MACRO row, col 	; Макрос установки курсора
	push ax					  
	push bx					  
	push cx					  
	push dx					  
							  
	mov bh, 3fh 		    ; атрибут нормальный ч/б
	mov cx, 0000 		    ; координаты от 00,00
	mov dx, 184fh 		    ; до 24,79 (весь экран)
	int 10h 			      
						      
	mov ah, 02 			    ; Установка курсора
	mov bh, 00  		    ; страница
	mov dh, row 		    ; номер строки в DH
	mov dl, col 		    ; номер столбца в DL
	int 10h 

	pop dx
	pop cx
	pop bx
	pop ax
ENDM 

mWriteStr macro string		 ;Макрос вывода
	push ax
	push dx

	mov ah, 09h 
	mov dx, offset string
	int 21h 

	pop dx
	pop ax
ENDM


Clear macro color  			;Макрос очистки экрана
	push ax
	push bx
	push cx
	push dx

	mov ah, 6h
	mov al, 0h
	mov bh, color            ;3fh        ; цвет :)
	mov cx, 0000h
	mov dx, 184fh
	int 10h

	pop dx
	pop cx
	pop bx
	pop ax
ENDM

mReadAX10_ macro buffer, sizee              ;Макрос ввода 10-чного числа в регистр АХ
local input, startOfConvert, endOfConvert
	push bx			;Данные в стек
	push cx
	push dx

	xor ax, ax
	xor dx, dx
	xor bx, bx

input:
	mov [buffer], sizee 	    ; Задаём размер буфера
	mov dx, offset [buffer]     ; Поместить в регистр dx строку по адресу buffer
	mov ah, 0Ah 		        ; Чтение строки из консоли
	int 21h 			        ; Прерывание DOS
							      
	mov ah, 02h 		        ; Вывод символа на экран
	mov dl, 0Dh 		        ; Перевод каретки на новую строку
	int 21h 			        ; Прерывание DOS
						          
	mov ah, 02h 		        ; Вывод символа на экран
	mov dl, 0Ah 		        ; Чтение строки из консоли
	int 21h 			        ; Прерывание DOS
								  
	xor ah, ah 			        ; Очистка регистра ah
	cmp al, [buffer][1] 	    ; Проверка на пустую строку
	jz input 			        ; Переход, если строка пустая
								  
	xor cx, cx 			        ; Очистка регистра cx
	mov cl, [buffer][1] 	    ; инициализация переменной-счётчика
								  
	xor ax, ax 			        ; Очистка регистра ax
	xor bx, bx 			        ; Очистка регистра bx
	xor dx, dx 			        ; Очистка регистра dx
	mov bx, offset [buffer][2] 	; Поместить начало строки в регистр bx
	cmp [buffer][2], '-' 	    ; Проверка на знак числа
	jne startOfConvert 	        ; Переход, если число неотрицательное
	inc bx 			            ; Инкремент регистра bx
	dec cl 			            ; Декремент регистра-счетчика cl

startOfConvert:					  
	mov dx, 10 			        ; Поместить в регистр ax число 10
	mul dx 			            ; Умножение на 10 перед сложением с младшим разрядом
	cmp ax, 8000h 		        ; Проверка числа на выход за границы
	jae input 			        ; Переход, если число выходит за границы
						          
	mov dl, [bx] 		        ; Поместить в регистр dl следующий символ
	sub dl, '0' 		        ; Перевод его в числовой формат
						          
	add ax, dx 			        ; Прибавляем его к конечному результату
	cmp ax, 8000h 		        ; Проверка числа на выход за границы
	jae input 			        ; Переход, если число выходит за границы
							      
	inc bx 			            ; Переход к следующему символу
	loop startOfConvert  	    ; Цикл
							      
	cmp [buffer][2], '-' 	    ; Проверка на знак числа
	jne endOfConvert 		    ; Переход, если число неотрицательное
	neg ax 			            ; Инвертирование числа 
							      
endOfConvert:				    
	pop dx			            ; Данные из стека
	pop cx
	pop bx
endm

mWriteAX10 macro  		        ;Макрос вывода 10-чного числа из регистра AX
local convert, write 
	push ax 			        ; Данные в стек
	push bx				  
	push cx				  
	push dx				  
	push di				  
						  
	mov cx, 10 			; cx - основание системы счисления
	xor di, di 			; di - количество цифр в числе
	or  ax, ax 			; Проверка числа на ноль
	jns convert 		; Переход, если число положительное
	push ax 			; Регистр ax в стек
						  
	mov dx, '-' 		; Поместить в регистр dx символ '-'
	mov ah, 02h 		; Вывод символа на экран
	int 21h 			; Прерывание DOS
						  
	pop ax  			; Регистр ax из стека
	neg ax 			    ; Инвертирование отрицательного числа 
						  
convert:				  
	xor dx, dx 			; Очистка регистра dx
						  
	div cx 			    ; После деления dl = остатку от деления ax на cx
	add dl, '0' 		; Перевод в символьный формат
	inc di 			    ; Увеличение количества цифр в числе на 1
	push dx 			; Регистр dx в стек
						  
	or ax, ax 			; Проверка числа на ноль
	jnz convert 		; Переход, если число не равно нулю
						  
write:					  
	pop dx 			    ; dl = очередной символ

	mov ah, 02h 		;Вывод символа на экран
	int 21h 			;Прерывание DOS
	dec di 			    ;Повторение, пока di != 0
	jnz write 

	pop di 			    ;Данные из стека
	pop dx 
	pop cx
	pop bx
	pop ax
endm

mReadMatrix macro matrix, row, col            ; макрос ввода матрицы с клавиатуры
	local rowLoop, colLoop
	JUMPS                                         ; позволяет делать большие прыжки
	
		push bx
		push cx									  
		push si									  
												  
		xor bx, bx								  
		mov cx, row								  
	
	rowLoop:                                       ; внешний цикл, проходящий по строкам
		push cx 
		xor si, si                                 ; обнуляем смещение по столбцам
		mov cx, col
	colLoop:

		mReadAX10_ buf, 4
		mov matrix[bx][si], ax
		add si, 2
		loop colLoop
	
		mWriteStr new_line
	
		add bx, col
		add bx, col
		pop cx
		loop rowLoop
	
		pop si
		pop cx
		pop bx
	NOJUMPS
endm mReadMatrix

mRandomAX macro              ; Генерация псевдослучайного числа в регистре AX
	push bx
	push dx
	
	;mov ax, [0040h]            ; псевдослучайное число BIOS

	mov ax, [46Ch]              ; счетчиков тиков таймера
	
	xor bx, bx
	mov bx, max
	sub bx, min
	inc bx
	mov ax, dx
	add ax, min

	pop dx
	pop bx
endm mRandomAX

mRandMatrix macro matrix, row, col            ; макрос для генерации матрицы, 
										      ; заполненой рандомными числами 
local rowLoop, colLoop
JUMPS                                         ; позволяет делать большие прыжки

	push bx
	push cx									  
	push si									  
											  
	xor bx, bx								  
	mov cx, row							  

rowLoop:                                       ; внешний цикл, проходящий по строкам
	push cx 
	xor si, si                                  ; обнуляем смещение по столбцам
	mov cx, col
colLoop:
	xor ax, ax
	mRandomAX
	mov matrix[bx][si], ax
	add si, 2
	loop colLoop

	mWriteStr new_line

	add bx, col
	add bx, col
	pop cx
	loop rowLoop
	pop si
	pop cx
	pop bx

NOJUMPS
endm mRandMatrix

mTransposeMatrix macro matrix, row, col, resMatrix       ; Макрос для 
	local rowLoop, colLoop                               ; транспонирования матрицы
	push ax
	push bx
	push cx
	push di
	push si
	push dx

	xor di, di
	mov cx, row
	rowLoop:
		push cx
		xor si, si
		mov cx, col
	colLoop:
		mov ax, col
		mul di
		add ax, si
		mov bx, ax
		mov ax, matrix[bx]
		push ax

		mov ax, row
		mul si
		add ax, di

		mov bx, ax
		pop ax
		mov resMatrix[bx], ax

		add si, 2

	loop colLoop

		add di, 2
		pop cx
	loop rowLoop

	pop dx
	pop si
	pop di
	pop cx
	pop bx
	pop ax
endm mTransposeMatrix

mWriteMatrix macro matrix, row, col                          	; Макрос для
		local rowLoop, colLoop									; вывода матрицы на экран 
		JUMPS
		push ax
		push bx
		push cx
		push si

		;MCUR 2, 7, 16
		;MCUR 2, 16, 8
		mWriteStr tab
		mWriteStr tab
		mWriteStr tab
		mWriteStr tab
		xor bx, bx
		mov cx, row
		
		rowLoop:
		push cx

		xor si, si
		mov cx, col
		colLoop:
		mov ax, matrix[bx][si]

		mWriteAX
		xor ax, ax
		mWriteStr tab

		add si, 2
		loop colLoop

		mWriteStr new_line
		mWriteStr tab
		mWriteStr tab
		mWriteStr tab
		mWriteStr tab
		add bx, col
		add bx, col
		pop cx
		loop rowLoop

		pop si
		pop cx
		pop bx
		pop ax
NOJUMPS
endm mWriteMatrix

mPrintMenue1 macro

	Clear 03fh
	MCUR 2, 9, 15		
	mWriteStr line  							
	mWriteStr new_line   						
	MCUR 2, 10, 15  							 
	mWriteStr men1_mes1 						; +-------------------------------------------+
		                                        ; | 1. Fill the matrix with random numbers?   |
		                                        ; | 2. Fill the matrix with your numbers?     |
		                                        ; | 0. Exit                                   |
	mWriteStr new_line  						; +-------------------------------------------+
	MCUR 2, 11, 15		    ;;;;;;;;;;;;;;;;	
	mWriteStr men1_mes2     ;  Меню 1      ;	
	mWriteStr new_line      ;;;;;;;;;;;;;;;;	
	MCUR 2, 12, 15  							
	mWriteStr mes_exit 	    					
	mWriteStr new_line  
	MCUR 2, 13, 15  	
	mWriteStr line  	
	mWriteStr new_line   
	mWriteStr new_line 
endm mPrintMenue1					
														;;;;;;;;;;;;;;;;;;
														;  Меню 2      ;;;
														;;;;;;;;;;;;;;;;;;
mPrintMenue2 macro                                        
	Clear 06fh                      ;   +-----------------------------------------------+
	MCUR 2, 9, 15				    ;   |   1. Transposition                            |
	mWriteStr line  	       	    ;   |   2. Task A                                   |
	mWriteStr new_line   		    ;   |   3. Task B                                   |
	MCUR 2, 10, 15  			    ;   |   4. Task C                                   |
	mWriteStr men2_mes1 		    ;   |   0. Exit                                     |
	mWriteStr new_line  		    ;   +-----------------------------------------------+
	MCUR 2, 11, 15		         
	mWriteStr men2_mes2          
	mWriteStr new_line 		     
	MCUR 2, 12, 15		            
	mWriteStr men2_mes3
	mWriteStr new_line 
	MCUR 2, 13, 15					   
	mWriteStr men2_mes4			
	mWriteStr new_line 			
	MCUR 2, 14, 15  			
	mWriteStr mes_exit 			
	mWriteStr new_line  		
	MCUR 2, 15, 15  			
	mWriteStr line  			
	mWriteStr new_line   			   
endm mPrintMenue2

mCopyMatrix macro matrix1, matrix2, row, col
local rowLoop, colLoop
    push ax       ; Сохранение регистров, используемых в макросе, в стек
    push bx
    push cx
    push si
    push di

    xor bx, bx    ; Обнуляем смещение по строкам
    mov cx, row   ; Устанавливаем количество строк
rowLoop:
    push cx

    xor si, si    ; Обнуляем смещение по столбцам
    mov cx, col   ; Устанавливаем количество столбцов
colLoop:
    mov ax, matrix1[bx][si] ; Загружаем элемент из исходной матрицы
    mov matrix2[bx][si], ax ; Копируем элемент в целевую матрицу
    add si, 2                 ; Переходим к следующему элементу (размером в слово)
    loop colLoop

    add bx, col       ; Увеличиваем смещение по строкам исходной матрицы
    add bx, col
    pop cx
    loop rowLoop

    pop di            ; Восстанавливаем регистры
    pop si
    pop cx
    pop bx
    pop ax
endm

; третий пункт : удаление первого отрицательного элемента
mDeleteFirstNegative macro matrix, row, col, flagNegative, matrixRes, col2
local rowLoop, colLoop, nextCol, nextRow, push_back
    push ax                 ; Сохранение регистров, используемых в макросе, в стек 
    push bx 
    push cx 
    push si 

	xor ax, ax
	mov ax, col
	sub ax, 1
	mov [col2], ax
	xor ax, ax

    xor di, di
    xor bx, bx              ; Обнуляем смещение по строкам 
    mov cx, row 
rowLoop:
    push cx  
    mov flagNegative, 0
    xor si, si              ; Обнуляем смещение по столбцам 
    mov cx, col 
colLoop:                    ; Внутренний цикл, проходящий по столбцам 
    mov ax, matrix[bx][si]  ; bx - смещение по строкам, si - по столбцам 
    
    cmp ax, 0
    jge push_back

    cmp flagNegative, 1
    je push_back

    mov flagNegative, 1
    jmp nextCol

push_back:
    mov [matrixRes + di], ax
    xor ax, ax
    add di, 2
    jmp nextCol
nextCol:
    add si, 2         ; Переходим к следующему элементу (размером в слово) 
    loop colLoop 
nextRow: 
    add bx, col       ; Увеличиваем смещение по строкам  
    add bx, col       ; (дважды, так как размер каждого элемента - слово) 
    pop cx 
    loop rowLoop 
    
    pop si            ; Перенос сохранённых значений обратно в регистры  
    pop cx 
    pop bx 
    pop ax 
endm mDeleteFirstNegative

mPrintMatrix macro
    push ax                 ; Сохранение регистров, используемых в макросе, в стек 
    push bx 
    push cx 
    push si 
	mWriteStr new_line
	MCUR 2, 6, 8					   ; вывод матрицы
	mWriteStr tab					   ; 
	mWriteStr tab
	mWriteStr mes_matr 
	mWriteStr new_line
	mWriteMatrix MATRIX, M, N
	mov ah,1							; чтобы была
	int 21h			                    ; задержка экрана

    pop si            ; Перенос сохранённых значений обратно в регистры  
    pop cx 
    pop bx 
    pop ax 
endm mPrintMatrix

; task A
mMaxValues macro matrix, row, col, max
local colLoop, rowLoop, nextCol, nextRow
	push cx
	push si
	push bx
	push ax
	push dx
	push di

	xor si, si
	xor bx, bx
	mov ax, col
	mov bx, 2d
	xor dx, dx
	div bx
	cmp dx, 0
	je even1
	add ax, 1
even1:
	xor bx, bx
	mov cx, ax
colLoop:
	push cx
	xor bx, bx
	xor ax, ax
	mov ax, matrix[bx][si]
	mov max, ax
	mov cx, row
rowLoop:
	mov ax, matrix[bx][si]
	cmp ax, max
	jl nextRow
	mov max, ax

nextRow:
	add bx, col
	add bx, col
	loop rowLoop
nextCol:
	mov ax, max
	mWriteAx 
	mWriteStr tab
	mWriteStr tab
	add si, 4
	pop cx
	loop colLoop

	pop di
	pop dx
	pop ax
	pop bx
	pop si
	pop cx
endm mMaxValues

; Task C
mSumEven macro matr1, row, col, sum
local rowLoop, colLoop, nextCol, nextRow, add1
push cx
push si
push bx
push ax

    xor bx, bx              ; Обнуляем смещение по строкам 
    mov cx, row 
rowLoop:
    push cx  
    mov sum, 0
    xor si, si              ; Обнуляем смещение по столбцам 
    mov cx, col 
colLoop:                    ; Внутренний цикл, проходящий по столбцам 
    mov ax, matr1[bx][si]  ; bx - смещение по строкам, si - по столбцам 
	push bx
	mov bx, 2
	xor dx, dx
	idiv bx
	pop bx

	cmp dx, 0
	jne nextCol
	mov ax, matr1[bx][si]
	add sum, ax

nextCol:
    add si, 2         ; Переходим к следующему элементу (размером в слово) 
    loop colLoop 
nextRow: 
	xor si, si
	mov ax, sum
	mov matr1[bx][si], ax

    add bx, col       ; Увеличиваем смещение по строкам  
    add bx, col       ; (дважды, так как размер каждого элемента - слово) 
    pop cx 
    loop rowLoop 

pop ax
pop bx
pop si
pop cx
endm mSumEven


;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;
;     Начало           ;;
;;;;;;;;;;;;;;;;;;;;;;;;;
xor ax, ax			    
mov ax, 0600h		    
mov bh, 01fh		    ; экран
mov cx, 0000		   
mov dx, 184FH		   
int 10H				   
xor ax, ax
xor bx, bx
MCUR 2, 12, 15
mWriteStr mess2         ; Ввод M
mReadAX10_ buf, 3 
mov bx, ax
mov M, bx 	
MCUR 2, 13, 15
mWriteStr new_line 
MCUR 2, 14, 15
xor ax, ax
xor bx, bx
mWriteStr mess1  	    ; Ввод N
mReadAX10_ buf, 3 	            
mov bx, ax 
mov N, bx 

CH1:
    mov ah,1		  ; задержка
    int 21h			  ; экрана
	mPrintMenue1
	mov choice, 0					
	MCUR 2, 16, 15  	   
	mWriteStr mess3  
	       				   ;;;;;;;;;;;;;;;;;;;;
	mReadAX10_ buf, 3 	   ; Ввод пункта меню ;                               
	mov bx, ax 			   ;;;;;;;;;;;;;;;;;;;;
	mov choice, bx 		    
    cmp choice, 0
    JE ENDPR
	cmp choice, 1
	JE RandM
	cmp choice, 2
	JE ReadM
mWriteStr tab
mWriteStr mes_try
JMP CH1

ReadM:
	mReadMatrix MATRIX, M, N
	Clear 03fh						  
	mPrintMatrix
	Clear 03fh
JMP C2

RandM:
	;	mRandMatrix MATRIX, M, N             ; !!! тут ошибка

C2:
	mov ah,1		       ; чтобы была
    int 21h			       ; задержка экрана
	mPrintMenue2
	mov choice, 0					
	MCUR 2, 17, 15  	   
	mWriteStr mess3  
			       			;;;;;;;;;;;;;;;;;;;;
	mReadAX10_ buf, 3 	    ; Ввод пункта меню ;     
							;;;;;;;;;;;;;;;;;;;;
	mov bx, ax 			    
	mov choice, bx 	
	cmp choice, 0
	JE ENDPR
	cmp choice, 1
	JE TRANS
	cmp choice, 2
	JE TASK_A
	cmp choice, 3
	JE TASK_B
	cmp choice, 4
	JE TASK_C
mWriteStr tab
mWriteStr mes_try
JMP C2

TRANS:
	mTransposeMatrix MATRIX, M, N, MATRIX_RES
		Clear 03fh	
		mPrintMatrix
		mWriteStr new_line
		mWriteStr mes_res
		MCUR 2, 10, 8					  
		mWriteStr tab					  
		mWriteStr tab
		mWriteStr mes_trans_mat 
		mWriteStr new_line
		mWriteMatrix MATRIX_RES, N, M
		mov ah,1		                   ; чтобы была
		int 21h			                   ; задержка экрана
		Clear 03fh 
		JMP C2

TASK_A: 
	mWriteMatrix MATRIX, M, N
	mWriteStr new_line
	mWriteStr tab
	mWriteStr tab
	mWriteStr tab
	mWriteStr tab
	mMaxValues MATRIX, M, N, max_el

	JMP C2

TASK_B:
	mDeleteFirstNegative MATRIX, M, N, flag_first_negative, MATRIX_RES, col_res
		Clear 03fh					; вывод
		mPrintMatrix				; певрой матрциы
	    mWriteStr new_line

		MCUR 2, 15, 8						  ; вывод
		mWriteStr mes_res					  ; результата 
		mWriteStr new_line					  ; на
		mWriteMatrix MATRIX_RES, M, col_res	  ; экран

		mov ah,1	; чтобы была
		int 21h		; задержка экрана
		Clear 03fh 
JMP C2

TASK_C:
Clear 07fh
	mWriteMatrix MATRIX, M, N
	mWriteStr new_line
	mCopyMatrix MATRIX, matrix_sum_res, M, N
	mSumEven matrix_sum_res , M, N, sum
	mWriteMatrix matrix_sum_res, M, N
	JMP C2

ENDPR:
	mov ax, 4C00h   ; завершение программы
    int 21h
;mov ax, 4C00h   ; завершение программы
;int 21h
end start
END