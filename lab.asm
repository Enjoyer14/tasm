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
message1 db 'x<0 $'
message2 db 'x>0 $'
message3 db 'x==0 $'
x db 44d, '$'
.code
start:
    mov ax, @data
    mov ds, ax
    printstr x
    
ends1:
    mov ax,4c00h
    int 21h

end start