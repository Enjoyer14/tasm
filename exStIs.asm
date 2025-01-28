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
    mas1 dw 13, 5, 5, 16, 15, 12, 20, 19, 2, 17
    len dw 10
    mas2 dw 11 dup(?)
    tab db "    $" ; для вывода
    count dw ?

.code
start:
    mov ax, @data
    mov ds, ax

    xor si, si
    xor di, di
    add di, 2
    mov cx, len
    cycle:
        mov ax, mas1[si]
        cmp ax, 15
        jl skipWithAdd ; меньше 15 = скип
        mov mas2[di], ax ; сохраняем в другом массиве
        add di, 2
        jmp skip

        skipWithAdd:
            mov ax, count
            inc ax
            mov count, ax
    
        skip:
            add si, 2
            loop cycle
    
    xor di, di
    mov ax, count
    mov mas2[di], ax


    mov ax, 4c00h
    int 21h

end start