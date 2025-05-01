sc  segment 'code'
    assume  cs:sc, ds:sc, es:sc
    org 256  
 
start proc 
    JUMPS
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

    push ax               ; Сохраняем регистры AX и DX
    push dx
    lea dx, endl           ; Загружаем адрес строки в DX
    mov ah, 09h           ; Функция DOS для вывода строки
    int 21h               ; Вызов DOS-прерывания
    pop dx                ; Восстанавливаем регистры DX и AX
    pop ax 

    push ax               ; Сохраняем регистры AX и DX
    push dx
    lea dx, sInpNum           ; Загружаем адрес строки в DX
    mov ah, 09h           ; Функция DOS для вывода строки
    int 21h               ; Вызов DOS-прерывания
    pop dx                ; Восстанавливаем регистры DX и AX
    pop ax 

    push bx
	push cx
	push dx

input:
	mov [buffer1], 4
	mov dx, offset [buffer1]
	mov ah, 0Ah
	int 21h

	mov ah, 02h
	mov dl, 0Dh
	int 21h
	
	mov ah, 02h
	mov dl, 0Ah
	int 21h

	xor ah, ah
	cmp ah, [buffer1][1]
	jz input

	xor cx, cx
	mov cl, [buffer1][1]

	xor ax, ax
	xor bx, bx
	xor dx, dx
	mov bx, offset [buffer1][2]

	cmp [buffer1][2], '-'
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

	cmp [buffer1][2], '-'
	jne endOfConvert
	neg ax

endOfConvert:
	pop dx
	pop cx
	pop bx

    cmp ax, 0
    jl CloseFiles
    mov num1, ax

    push ax               ; Сохраняем регистры AX и DX
    push dx
    lea dx, endl           ; Загружаем адрес строки в DX
    mov ah, 09h           ; Функция DOS для вывода строки
    int 21h               ; Вызов DOS-прерывания
    pop dx                ; Восстанавливаем регистры DX и AX
    pop ax

    push ax               ; Сохраняем регистры AX и DX
    push dx
    lea dx, sInpChar           ; Загружаем адрес строки в DX
    mov ah, 09h           ; Функция DOS для вывода строки
    int 21h               ; Вызов DOS-прерывания
    pop dx                ; Восстанавливаем регистры DX и AX
    pop ax 

    push ax
	mov ah, 01h
	int 21h
	mov chr, al
    pop ax

    push ax               ; Сохраняем регистры AX и DX
    push dx
    lea dx, endl           ; Загружаем адрес строки в DX
    mov ah, 09h           ; Функция DOS для вывода строки
    int 21h               ; Вызов DOS-прерывания
    pop dx                ; Восстанавливаем регистры DX и AX
    pop ax

    lea si, String
    lea di, NewString
    cld
    xor cx, cx
loop1:   ; считаем количество элементов в первойс строке 
    lodsb
    inc cx
    cmp al, 0Dh
    je prepareToloop
    cmp cx, num1
    je prepareToloop
    jmp loop1

prepareToloop:
    push cx
    xor cx, cx
    mov cx, num1
    mov al, chr
loop2:
    stosb
    loop loop2

endLoop1:
    pop cx
    mov countChr, cx
    mov cx, index
    sub cx, countChr
    rep movsb
    
output1:
    mov al, '$'
    stosb

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


    mov cx, countChr
    cmp cx, num1
    jl isGreater1

    mov ah, 40h 
    mov bx, FDescrNew 
    mov cx, index
    sub cx, 1
    mov dx, offset NewString
    int 21h 
    jnc CloseFiles 
    jmp Er4 

isGreater1:
    mov bx, num1
    sub bx, countChr
    mov countChr, bx
    mov ah, 40h 
    mov bx, FDescrNew 
    mov cx, index
    add cx, countChr
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
NOJUMPS
    mov ah, 07h  ;задержка  экрана 
    int 21h    
       
    ;завершение программы 
    mov ax, 4c00h 
    int 21h 

;data

CR = 0Dh 
LF = 0Ah 
count dw 0
FileName db "t1.txt0", "$"           ;имя файла в формате ASCIIZ строки 
FDescr dw ?                                ;ячейка для хранения дисриптора 
NewFile db "ans1.txt0", "$" 
FDescrNew dw ?                             ;для хранения дискриптора нового 
Buffer dw ?                                ;буфер для хранения символа строки 
String db 1024 dup(0)                        ;буфер для хранения строки 
NewString db 1024 dup(0)
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
sInpChar db 'Enter Char: $'
sInpNum db 'Enter Number: $'
num1 dw ?
chr db ?
buffer1 db ?
countChr dw ?

start endp
sc ends
end start