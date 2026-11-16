; post1.asm - REP MOVSW + MOVSB: copia optimizada de cadena
; Compilar: nasm -f bin post1.asm -o post1.com
ORG 100h

section .data
   origen  db "HOLA, MUNDO!","$"   ; 13 bytes, termina en $ para AH=09h
   destino db 13 dup(0)
   msgCop  db "Copiado: $"
   crlf    db 0Dh,0Ah,"$"

section .text
start:
   ; Preparar ES = DS
   mov ax, ds
   mov es, ax

   ; Copia optimizada: MOVSW para el grueso + MOVSB para byte impar
   mov si, origen
   mov di, destino
   mov cx, 13           ; longitud total
   cld                  ; DF=0: de baja a alta direccion
   mov ax, cx
   shr cx, 1            ; CX = 13 / 2 = 6 words
   rep movsw            ; copiar 6 words (12 bytes)
   and ax, 1            ; habia byte impar? (13 AND 1 = 1)
   jz .fin
   movsb                ; copiar el byte sobrante (posicion 13)
.fin:

   ; Mostrar el resultado
   mov ah, 09h
   mov dx, msgCop
   int 21h
   mov dx, destino
   int 21h
   mov dx, crlf
   int 21h

   mov ah, 4Ch
   xor al, al
   int 21h
