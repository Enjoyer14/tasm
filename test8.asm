.486 
model use16 small 
.stack 100h 
.data 
b dw 175   
k1 dw 1 
x dw ?   
pi dw 180   
y dw ?   
axis dw ?   
k2 dw 70 
two dw 2  
medX dw 319
medY dw 174
.code 
Start: 
    mov ax, @data 
    mov ds, ax 
    xor ax, ax  
    mov al, 10h              
    int 10h  

    mov ax, 0600h ; ah = 06 - прокрутка вверх 
    mov bh, 15 ;белый 
    mov cx, 0000b ; ah = 00 - строка верхнуго левого угла 
    mov dx, 184Fh  
    int 10h               

    mov ah, 0Ch   ;установка графической точки 
    mov al, 10  ;загружаем зелѐный цвет для вертикальной линии
    mov bh, 0h   ;установка номера видеостраницы 
    
    mov cx, 400     ;количество итераций сверху вниз

metka1:    
    push cx  
    mov axis, cx  
    mov dx, axis  
    mov cx, medX 
    int 10h  
    pop cx 
    loop metka1 

    mov ah, 0ch   ;установка графической точки 
    mov al, 30   ;зелѐный цвет
    mov cx, 639  ;639 итераций, ставит в 639 колонку, и идѐт до 0
    mov bh, 0h   ; установка номера видеостраницы
    mov dx, medY   ;ставит в 174 строку

metka2:    
    int 10h   
    loop metka2 

    mov cx, 640  
    
@metka3:    
mov x, cx  
fild x   
fldpi  
fmul   
fild pi   
fdiv   
fild k1   
fdiv  
fcos  
fimul k2  
fchs   
fiadd b   
frndint 
fistp y  
mov ah, 0Ch 
mov bh, 0h 
mov dx, y  
mov al, 0  
int 10h  
loop @metka3  
mov ah, 8h  
int 21h 
mov ax, 4c00h 
int 21h 
end Start 
end