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

.model small 
.stack 100h 
.data 
;=========================== 
CR = 0Dh 
LF = 0Ah 
FileName db "task1.txt0", "$"           ;имя файла в формате ASCIIZ строки 
FDescr dw ?                                ;ячейка для хранения дискриптора 
NewFile db "answer.txt0", "$" 
FDescrNew dw ?                             ;для хранения дискриптора нового 
файла 
Buffer dw ?                                ;буфер для хранения символа строки 
Tochka dw 46d
String dw 40 dup(0)                        ;буфер для хранения строки 
index dw 0                                 ;впомогательная переменная    
MessageError1 db CR, LF, "File was not opened !", "$"         
MessageError2 db CR, LF, "File was not read !", "$" 
MessageError3 db CR, LF, "File was not founded!", "$" 
MessageError4 db CR, LF, "File was not created!", "$" 
MessageError5 db CR, LF, "Error in writing in the file!", "$" 
MessageEnd db CR, LF, "Program was successfully finished!", "$" 
;=========================== 
.code 
print_string macro 
    mov ah, 09h 
    int 21h 
endm        

start: 
    mov ax, @data 
    mov ds, ax 
    xor di, di
    ;открытие файла 
    mov ah, 3Dh 
    xor al, al                          ;открыть файл для чтения 
    mov dx, offset FileName             ;адрес имени файла 
    xor cx, cx                          ;открыть файл без указания атрибутов 
    int 21h                             ;выполнить прерывание 
    mov FDescr, ax                      ;получить дескриптор файла 
    jnc M1                      ;eсли ошибок нет, выполнить программу дальше    
    jmp Er1                             ;файл не был открыт 
  
M1:  
    ;создание нового файла 
    mov ah, 3ch           ;создать новый файл   
    xor cx, cx                           
    mov dx, offset NewFile                 ;адрес имени файла 
    int 21h                                ;выпонить 
    mov FDescrNew, ax                      ;дискриптор файла 
    jnc M2                       ;если ошибок нет, выполнить программу дальше     
    jmp Er3                                ;файл не был создан 
 
M2: 
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
        je M4                         ;если ax=0 -> sf=1 
        mov ax, [Buffer] 
        mov bx, index
        cmp ax, 64d
        jg Remember

        cmp ax, 33d
        jl Remember

        inc di
        mov ax, ' '

    Remember:
        mov String[bx], ax 
        inc bx 
        mov index, bx 
    jmp M2 
 
M4:    
    ;запись в файл  
    mov ah, 40h 
    mov bx, FDescrNew 
    mov cx, index 
    mov dx, offset String 
    int 21h 
    jnc M5 
    jmp Er4 
         
M5:      
    ;закрытие исходного файла  
    mov ah, 3eh                           ;функция закрытия файла 
    mov bx, FDescr  
    int 21h  
       
    ;закрытие нового файла   
    mov ah, 3eh                           ;функция закрытия файла 
    mov bx, FDescrNew  
    int 21h 
       
    ;вывод сообщения об успешном выполнении программы 
    mov dx, offset MessageEnd 
    print_string
    mov ax, di
    mWriteAX
    jmp Exit  
       
Er1:     
    ;файл не был найден 
    cmp ax, 02h 
    jne M6 
    lea dx, MessageError3 
    print_string 
    jmp Exit 
M6: 
    ;файл не был открыт 
    lea dx, MessageError1 
    print_string 
    jmp Exit 
 
Er2:  
    ;файл не был прочтен 
    lea dx, MessageError2 
    print_string 
    jmp Exit 
       
Er3:  
    ;файл не был создан 
    lea dx, MessageError4 
    print_string 
    jmp Exit 
      
Er4: 
 ;ошибка при записи в файл 
    lea dx, MessageError5 
    print_string 
    jmp Exit   
      
Exit: 
    mov ah, 07h  ;задержка  экрана 
    int 21h    
       
    ;завершение программы 
    mov ax, 4c00h 
    int 21h 
end start 