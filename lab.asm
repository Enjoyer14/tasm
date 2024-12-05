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



.model small
.stack 100h
.data

x db -100d
message1 db 'x<0 $'
message2 db 'x>0 $'
message3 db 'x==0 $'
.code
start:
    mov ax, @data
    mov ds, ax

    wipescreen

    cmp x, 0
    jl case1
    jg case2
    je case3

    

case1:
    printstr message1
    jmp ends1

case2:
    printstr message2
    jmp ends1

case3:
    printstr message3
    jmp ends1

ends1:
    mov ax,4c00h
    int 21h

end start