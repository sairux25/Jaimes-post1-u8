; post1e.asm - LODSB + STOSB: copia con transformacion a mayusculas
; Compilar: nasm -f bin post1e.asm -o post1e.com
ORG 100h

section .data
   origen  db "hola, mundo!","$"   ; 13 bytes, termina en $ para AH=09h
   destino db 13 dup(0)
   msgCop  db "Transformado: $"
   crlf    db 0Dh,0Ah,"$"

section .text
start:
   mov ax, ds
   mov es, ax

   mov si, origen
   mov di, destino
   mov cx, 13
   cld

.bucle:
   lodsb                ; AL = [DS:SI], SI avanza automaticamente
   cmp al, 'a'          ; AL < 'a': no es minuscula, no se transforma
   jb .escribir
   cmp al, 'z'          ; AL > 'z': no es minuscula, no se transforma
   ja .escribir
   sub al, 20h          ; 'a'-'z' -> 'A'-'Z' (resta 20h)

.escribir:
   stosb                ; [ES:DI] = AL, DI avanza automaticamente
   loop .bucle

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
