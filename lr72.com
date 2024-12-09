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
Task:
    lea si, String                    ; Указатель на начало исходной строки
    lea di, NewString                 ; Указатель на начало выходной строки

scanLoop:
    lodsb                            ; Загружаем слово из [SI] в AX
    cmp al, '$'                       ; Проверяем конец строки (символ '$')
    je endScan                       ; Если символ '$', заканчиваем обработку

    cmp al, 0                      ; Проверяем конец строки (символ '$')
    je endScan  

    cmp al, ','                       ; Проверка: AX = ','
    je replace1                   ; Если да, заменяем

    cmp al, '!'                       ; Проверка: AX = '!'
    je replace1                   ; Если да, заменяем

    cmp al, '.'                       ; Проверка: AX = '.'
    je replace1                   ; Если да, заменяем

    cmp al, '?'                       ; Проверка: AX = '.'
    je replace1                   ; Если да, заменяем

    cmp al, ':'                       ; Проверка: AX = '.'
    je replace1                   ; Если да, заменяем

    cmp al, ';'                       ; Проверка: AX = '.'
    je replace1                   ; Если да, заменяем

    stosb                            ; Если символ не знак препинания, записываем его
    jmp scanLoop                     ; Переход к следующему символу

replace1:
    mov ax, count
    inc ax
    mov count, ax
    mov ax, ' '                       ; Заменяем символ на пробел
    stosb                            ; Записываем пробел
    jmp scanLoop                     ; Переход к следующему символу

endScan:
    mov ax, '$'                       ; Конец строки
    stosb                             ; Записываем символ '$' в выходную строку

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
    lea si, NewString                 ; Возвращаем указатель SI на начало строки
    lea di, StringForFile                 ; Указатель DI тоже на начало строки
    rep movsb                         ; Копируем строку, кроме последнего элемента

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
FileName db "task2.txt0", "$"           ;имя файла в формате ASCIIZ строки 
FDescr dw ?                                ;ячейка для хранения дисриптора 
NewFile db "answer72.txt0", "$" 
FDescrNew dw ?                             ;для хранения дискриптора нового 
Buffer dw ?                                ;буфер для хранения символа строки 
String db 256 dup(0)                        ;буфер для хранения строки 
NewString db 256 dup(0)
StringForFile db 256 dup(0)
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

start endp
sc ends
end start