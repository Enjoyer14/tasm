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


printstr macro msg
    push ax               ; Сохраняем регистры AX и DX
    push dx
    lea dx, msg           ; Загружаем адрес строки в DX
    mov ah, 09h           ; Функция DOS для вывода строки
    int 21h               ; Вызов DOS-прерывания
    pop dx                ; Восстанавливаем регистры DX и AX
    pop ax
endm

inputchr macro var
    push ax
	mov ah, 01h
	int 21h
	mov var, al
    pop ax
endm

.model small 
.stack 100h 
.data 
;=========================== 
CR = 0Dh 
LF = 0Ah 
count dw 0
FileName db "task1.txt0", "$"           ;имя файла в формате ASCIIZ строки 
FDescr dw ?                                ;ячейка для хранения дисриптора 
NewFile db "Otvet.txt0", "$" 
FDescrNew dw ?                             ;для хранения дискриптора нового 
Buffer dw ?                                ;буфер для хранения символа строки 
String db 1024 dup(0)                        ;буфер для хранения строки 
NewString db 1024 dup(0)
StringFFile db 1024 dup(0)
index dw 0                                 ;впомогательная переменная  
endl db 0Dh, 0Ah, '$'  
MessageError1 db CR, LF, "File was not opened !", "$"         
MessageError2 db CR, LF, "File was not read !", "$" 
MessageError3 db CR, LF, "File was not founded!", "$" 
MessageError4 db CR, LF, "File was not created!", "$" 
MessageError5 db CR, LF, "Error in writing in the file!", "$" 
MessageEnd db CR, LF, "Program was successfully finished!", "$" 
mStrInput db 'Input file: $'
mStrOutput db 'Output file: $'
rowCount dw 0
chrbuff db ?

;=========================== 
.code 
print_string macro 
    mov ah, 09h 
    int 21h 
endm          
                                                                                                               
start: 
JUMPS
    mov ax, @data 
    mov ds, ax 
    mov es, ax
    wipescreen

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
        je WriteToFile
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
    mov index, bx

    printstr mStrInput
    printstr endl
    printstr String
    printstr endl
    printstr endl
    
Task:
    lea si, String
    lea di, NewString

loop1:
    lodsb 
    cmp al, 0
    je endProcess
    
    cmp al, 0Dh
    je incCount
    
    cmp al, 0Ah
    je nextIt

    push ax
    mov ax, rowCount
    mov bx, 2d
    xor dx, dx
    div bx
    pop ax

    cmp dx, 1
    je nextIt

    ;cld - > \  std <-

    mov chrbuff, al
    mov count, 0
innerLoop:
    lodsb
    cmp al, 0Dh
    je reverse
    cmp al, 0
    je  reverse

    push ax
    mov ax, count
    inc ax
    mov count, ax
    pop ax

    jmp innerLoop

reverse:
    mov cx, count
    add cx, 2
reverseLoop:
    std
    lodsb
    cmp al, 0dh
    je skip1
    cmp al, 0Ah
    je skip1
    cld
    stosb
skip1:
    loop reverseLoop
    
    mov al, chrbuff
    stosb
    mov cx, count
    add cx, 1
inNstate:
    lodsb
    loop inNstate

    jmp nextItmk1
    

incCount:
    push ax
    mov ax, rowCount
    inc ax
    mov rowCount, ax
    pop ax
    
nextIt:
    stosb
nextItmk1:
    jmp loop1

endProcess:
    

    printstr endl
    printstr mStrOutput
    printstr endl
    printstr NewString
    printstr endl

    mov ah, 40h 
    mov bx, FDescrNew 
    mov cx, index
    ; sub cx, count
    dec cx
    mov dx, offset NewString
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
    mov dx, offset MessageEnd
    print_string 
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
NOJUMPS
end start 