.model small
.stack 100h
.data
mass dw 1,4,0,1,2,0,0,5,6,8
fio db 'Sahabiev S.0.', '$'
birthdm dw 1401h
birthyear dw 2005h
const1 DW 1401h
nam1 db 'Stasik', 0
.code
start:
    mov ax, @data
    mov ds, ax

    mov ax, mass

    mov bx, mass + 2

    mov cx, mass + 4

    mov dx, mass + 6

    mov si, mass + 8

    mov di, mass + 10

    mov bp, mass + 12

    mov sp, mass + 14

    mov al, fio + 6

    mov ax, birthyear
    mov [birthdm], ax

    mov cx, const1

    mov ax, 4C00h
    int 21h

end start
end