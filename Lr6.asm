.model large
.code
public perform_operation

; Функция принимает два аргумента (a и b) на стеке
; и возвращает их сумму в регистре AX

perform_operation proc
    ; Загрузка аргументов со стека
    push bp
    mov bp, sp

    mov ax, [bp+4] ; Первый аргумент a
    add ax, [bp+6] ; Второй аргумент b

    pop bp
    ret 4 ; Очистка двух аргументов со стека
perform_operation endp

end