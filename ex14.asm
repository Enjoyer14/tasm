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
    mas1 dw 13, 23, 13, 46, 52, 15, 512, 50, 1, 6, 3, 56, 39, 46, 105, 61
    len1 dw 16
    mas2 dw 16 dup(?)
    len2 dw ?
    tab db '	$'
    endl db 0Dh, 0Ah, '$'

.code
start:
    mov ax, @data
    mov ds, ax

    xor si, si
    xor di, di
    mov cx, len1
    cycle1:
        mov ax, mas1[si]
        cmp ax, 46
        jne skip

        push si
        
        ;увеличиваем длину массива-ответа
        mov ax, len2
        inc ax
        mov len2, ax

        ;нахожу индекс(смещение/2(dw))
        mov ax, si
        mov bx, 2
        xor dx, dx
        div bx

        ;cохраняем индекс в другом массиве
        mov mas2[di], ax
        add di, 2
        
        ;вывод числа
        mWriteAX
        ; вывод табуляции
        mov ah, 09h
        lea dx, tab
        int 21h

        pop si
        skip:
            add si, 2
            loop cycle1

    mov ax, 4c00h
    int 21h

end start