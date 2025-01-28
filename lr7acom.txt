sc  segment 'code'
    assume  cs:sc, ds:sc, es:sc 
    org 256  
 
start proc 
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

 ;открытие файла 
    mov ah, 3Dh 
    xor al, al                          ;открыть файл для чтения 
    mov dx, offset FileName             ;адрес имени файла 
    xor cx, cx                          ;открыть файл без указания атрибутов 
    int 21h                             ;выполнить прерывание 
    mov FDescr, ax                      ;получить дескриптор файла 
    jnc CreateNewFile                      ;eсли ошибок нет, выполнить программу дальше    
    jmp Er1                             ;файл не был открыт 
  
CreateNewFile:  
    ;создание нового файла 
    mov ah, 3ch           ;создать новый файл   
    xor cx, cx                           
    mov dx, offset NewFile                 ;адрес имени файла 
    int 21h                                ;выпонить 
    mov FDescrNew, ax                      ;дискриптор файла 
    jnc ReadFile                       ;если ошибок нет, выполнить программу дальше     
    jmp Er3                                ;файл не был создан 
 
ReadFile: 
;чтение файла 
    mov ah, 3fh                            ;чтение из файла 
    mov bx, FDescr                         ;дескриптор нужного файла    
    mov cx, 1                              ;количество считываемых символов  
    mov dx, offset Buffer                  ;адрес буфера для приема 
    int 21h                                ;выполнить    
    jnc M3        ;если нет ошибки -> продолжить чтение 
    jmp Er2                      ;если ошибка -> выход         
    M3: 
        cmp ax, 0 ;если ax=0(число считанных байтов) -> файл кончился -> выход 
        je WriteToFile                         ;если ax=0 -> sf=1 
        mov ax, Buffer 
        mov bx, index 
        mov String[bx], al 
        inc bx 
        mov index, bx 
    jmp ReadFile 
 
WriteToFile:
    mov ax, '$'
    mov bx, index 
    mov String[bx], al
    inc bx 
    mov index, bx   ; добавдяем знак $ в конец строчки для вывода на экран

    push ax               ; Сохраняем регистры AX и DX
    push dx
    lea dx, mStrInput           ; Загружаем адрес строки в DX
    mov ah, 09h           ; Функция DOS для вывода строки
    int 21h               ; Вызов DOS-прерывания
    pop dx                ; Восстанавливаем регистры DX и AX
    pop ax 
    push ax               ; Сохраняем регистры AX и DX
    push dx
    lea dx, endl           ; Загружаем адрес строки в DX
    mov ah, 09h           ; Функция DOS для вывода строки
    int 21h               ; Вызов DOS-прерывания
    pop dx                ; Восстанавливаем регистры DX и AX
    pop ax 
    push ax               ; Сохраняем регистры AX и DX
    push dx
    lea dx, String           ; Загружаем адрес строки в DX
    mov ah, 09h           ; Функция DOS для вывода строки
    int 21h               ; Вызов DOS-прерывания
    pop dx                ; Восстанавливаем регистры DX и AX
    pop ax 
    push ax               ; Сохраняем регистры AX и DX
    push dx
    lea dx, endl           ; Загружаем адрес строки в DX
    mov ah, 09h           ; Функция DOS для вывода строки
    int 21h               ; Вызов DOS-прерывания
    pop dx                ; Восстанавливаем регистры DX и AX
    pop ax 
    push ax               ; Сохраняем регистры AX и DX
    push dx
    lea dx, endl           ; Загружаем адрес строки в DX
    mov ah, 09h           ; Функция DOS для вывода строки
    int 21h               ; Вызов DOS-прерывания
    pop dx                ; Восстанавливаем регистры DX и AX
    pop ax 

    push ax               ; Сохраняем регистры AX и DX
    push dx
    lea dx, sInputChar           ; Загружаем адрес строки в DX
    mov ah, 09h           ; Функция DOS для вывода строки
    int 21h               ; Вызов DOS-прерывания
    pop dx                ; Восстанавливаем регистры DX и AX
    pop ax 

    mov ah, 01h
	int 21h
	mov chr, al
Task:
    lea si, String          ;указатель на начало исходной строки
    lea di, NewString        ;указатель на начало выходной строки

scanLoop:
    lodsb     ; Загрузка символа из si в ах
    cmp al, '$'     ; Проверяем конец строки (символ $)
    je endScan        ; Если символ '$' то конец

    cmp al, 0      ; Проверяем конец строки - 0
    je endScan  

    cmp al, chr
    je replace1

    stosb    ;записываем ах в di 
    jmp scanLoop     ; переходим к следующему символу

replace1:
    mov ax, count
    inc ax
    mov count, ax    ;инкремент для счетчика замен
    mov ax, ' '   ; заменяем символ на пробел
    stosb    ; сохраняем пробел в строчке
    jmp scanLoop       ; Переходим к следующему символу

endScan:
    mov ax, '$'     ; Добавляем конец строки для вывода на экран
    stosb          ; Записываем символ '$' в выходную строку

    push ax               ; Сохраняем регистры AX и DX
    push dx
    lea dx, endl           ; Загружаем адрес строки в DX
    mov ah, 09h           ; Функция DOS для вывода строки
    int 21h               ; Вызов DOS-прерывания
    pop dx                ; Восстанавливаем регистры DX и AX
    pop ax 
    push ax               ; Сохраняем регистры AX и DX
    push dx
    lea dx, endl           ; Загружаем адрес строки в DX
    mov ah, 09h           ; Функция DOS для вывода строки
    int 21h               ; Вызов DOS-прерывания
    pop dx                ; Восстанавливаем регистры DX и AX
    pop ax 

    push ax               ; Сохраняем регистры AX и DX
    push dx
    lea dx, mStrOutput           ; Загружаем адрес строки в DX
    mov ah, 09h           ; Функция DOS для вывода строки
    int 21h               ; Вызов DOS-прерывания
    pop dx                ; Восстанавливаем регистры DX и AX
    pop ax 
    push ax               ; Сохраняем регистры AX и DX
    push dx
    lea dx, endl           ; Загружаем адрес строки в DX
    mov ah, 09h           ; Функция DOS для вывода строки
    int 21h               ; Вызов DOS-прерывания
    pop dx                ; Восстанавливаем регистры DX и AX
    pop ax 
    push ax               ; Сохраняем регистры AX и DX
    push dx
    lea dx, NewString           ; Загружаем адрес строки в DX
    mov ah, 09h           ; Функция DOS для вывода строки
    int 21h               ; Вызов DOS-прерывания
    pop dx                ; Восстанавливаем регистры DX и AX
    pop ax 

    int 03h

    xor cx, cx
    mov cx, index
    dec cx
    lea si, NewString      ; получаем указатель SI на начало строки
    lea di, StringForFile       ; Указатель DI тоже на начало строки
    rep movsb       ; копируем строку кроме последнего элемента

    mov ax, 32d
    stosb

    mov ah, 40h 
    mov bx, FDescrNew 
    mov cx, index 
    mov dx, offset StringForFile 
    int 21h 
    jnc CloseFiles 
    jmp Er4 
        
CloseFiles:      
    ;закрытие исходного файла  
    mov ah, 3eh                           ;функция закрытия файла 
    mov bx, FDescr  
    int 21h  
       
    ;закрытие нового файла   
    mov ah, 3eh                           ;функция закрытия файла 
    mov bx, FDescrNew  
    int 21h 

    push ax               ; Сохраняем регистры AX и DX
    push dx
    lea dx, endl           ; Загружаем адрес строки в DX
    mov ah, 09h           ; Функция DOS для вывода строки
    int 21h               ; Вызов DOS-прерывания
    pop dx                ; Восстанавливаем регистры DX и AX
    pop ax 
    push ax               ; Сохраняем регистры AX и DX
    push dx
    lea dx, endl           ; Загружаем адрес строки в DX
    mov ah, 09h           ; Функция DOS для вывода строки
    int 21h               ; Вызов DOS-прерывания
    pop dx                ; Восстанавливаем регистры DX и AX
    pop ax 
    push ax               ; Сохраняем регистры AX и DX
    push dx
    lea dx, MessageCount           ; Загружаем адрес строки в DX
    mov ah, 09h           ; Функция DOS для вывода строки
    int 21h               ; Вызов DOS-прерывания
    pop dx                ; Восстанавливаем регистры DX и AX
    pop ax 

    mov ax, count
    ;вывод количества замен
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

    push ax               ; Сохраняем регистры AX и DX
    push dx
    lea dx, endl           ; Загружаем адрес строки в DX
    mov ah, 09h           ; Функция DOS для вывода строки
    int 21h               ; Вызов DOS-прерывания
    pop dx                ; Восстанавливаем регистры DX и AX
    pop ax 


       
    ;вывод сообщения об успешном выполнении программы 
    push ax               ; Сохраняем регистры AX и DX
    push dx
    lea dx, MessageEnd           ; Загружаем адрес строки в DX
    mov ah, 09h           ; Функция DOS для вывода строки
    int 21h               ; Вызов DOS-прерывания
    pop dx                ; Восстанавливаем регистры DX и AX
    pop ax 
    jmp Exit  
       
Er1:     
    ;файл не был найден 
    cmp ax, 02h 
    jne M6 
    push ax               ; Сохраняем регистры AX и DX
    push dx
    lea dx, MessageError3           ; Загружаем адрес строки в DX
    mov ah, 09h           ; Функция DOS для вывода строки
    int 21h               ; Вызов DOS-прерывания
    pop dx                ; Восстанавливаем регистры DX и AX
    pop ax 
    jmp Exit 
M6: 
    ;файл не был открыт 
    push ax               ; Сохраняем регистры AX и DX
    push dx
    lea dx, MessageError1           ; Загружаем адрес строки в DX
    mov ah, 09h           ; Функция DOS для вывода строки
    int 21h               ; Вызов DOS-прерывания
    pop dx                ; Восстанавливаем регистры DX и AX
    pop ax 
    jmp Exit 
 
Er2:  
    ;файл не был прочтен 
    push ax               ; Сохраняем регистры AX и DX
    push dx
    lea dx, MessageError2           ; Загружаем адрес строки в DX
    mov ah, 09h           ; Функция DOS для вывода строки
    int 21h               ; Вызов DOS-прерывания
    pop dx                ; Восстанавливаем регистры DX и AX
    pop ax 
    jmp Exit 
       
Er3:  
    ;файл не был создан 
    push ax               ; Сохраняем регистры AX и DX
    push dx
    lea dx, MessageError4           ; Загружаем адрес строки в DX
    mov ah, 09h           ; Функция DOS для вывода строки
    int 21h               ; Вызов DOS-прерывания
    pop dx                ; Восстанавливаем регистры DX и AX
    pop ax 
    jmp Exit 
      
Er4: 
 ;ошибка при записи в файл 
    push ax               ; Сохраняем регистры AX и DX
    push dx
    lea dx, MessageError5           ; Загружаем адрес строки в DX
    mov ah, 09h           ; Функция DOS для вывода строки
    int 21h               ; Вызов DOS-прерывания
    pop dx                ; Восстанавливаем регистры DX и AX
    pop ax 
    jmp Exit   
      
Exit: 
    mov ah, 07h  ;задержка  экрана 
    int 21h    
       
    ;завершение программы 
    mov ax, 4c00h 
    int 21h 

;data

CR = 0Dh 
LF = 0Ah 
count dw 0
FileName db "task1.txt0", "$"           ;имя файла в формате ASCIIZ строки 
FDescr dw ?                                ;ячейка для хранения дисриптора 
NewFile db "answer.txt0", "$" 
FDescrNew dw ?                             ;для хранения дискриптора нового 
Buffer dw ?                                ;буфер для хранения символа строки 
String db 1024 dup(0)                        ;буфер для хранения строки 
NewString db 1024 dup(0)
StringForFile db 1024 dup(0)
index dw 0                                 ;впомогательная переменная  
endl db 0Dh, 0Ah, '$'  
MessageError1 db CR, LF, "File was not opened !", "$"         
MessageError2 db CR, LF, "File was not read !", "$" 
MessageError3 db CR, LF, "File was not founded!", "$" 
MessageError4 db CR, LF, "File was not created!", "$" 
MessageError5 db CR, LF, "Error in writing in the file!", "$" 
MessageEnd db CR, LF, "Program was successfully finished!", "$" 
MessageCount db 'Number of zamen = $'
mStrInput db 'Input file: $'
mStrOutput db 'Output file: $'
sInputChar db 'Enter char: $'
chr db ?

start endp
sc ends
end start
