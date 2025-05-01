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
.stack
.data
    mas1 dw 124, -35, 0, 12, -53, 12, 53, 12, -6, -123
    len1 dw 10
    mas2 dw 10 dup(?)
    len2 dw 0
    tab db '    $'  ; просто для вывода

.code
start:
    mov ax, @data
    mov ds, ax

    xor si, si ; указатель для mas1
    xor di, di ; указатель для mas2
    mov cx, len1
    cycle:
        mov ax, mas1[si]
        cmp ax, 0
        jge skip ; если больше равно нуля то скип
        mov mas2[di], ax ; добавляем по индексу di элемент
        add di, 2 

        ;вывод для проверки
        mWriteAX
        mov ah, 09h
        lea dx, tab
        int 21h

        skip:
            add si, 2
            loop cycle

    
    mov ax, 4c00h
    int 21h

end start