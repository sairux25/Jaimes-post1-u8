; post2d.asm - AAA/AAS: ajuste ASCII de BCD desempaquetado
; Suma desempaquetada: 7 + 8 = 15 (AH=1 decena, AL=5 unidades)
; Resta desempaquetada: 13 - 8 = 5
; Compilar: nasm -f bin post2d.asm -o post2d.com
ORG 100h

section .data
   msgSuma  db "AAA: 7 + 8 = $"
   msgResta db 0Dh,0Ah,"AAS: 13 - 8 = $"
   crlf     db 0Dh,0Ah,"$"

section .text
start:
   ; --- Suma desempaquetada con AAA ---
   mov ah, 09h
   mov dx, msgSuma
   int 21h

   xor ah, ah              ; AH = 0: decena inicial del numero desempaquetado
   mov al, 07h             ; digito desempaquetado "7" (nibble alto en 0)
   add al, 08h             ; AL = 07h + 08h = 0Fh (NO es BCD desempaquetado valido)
   aaa                     ; ajusta: AL = 05h (unidades), AH += 1 (decenas), CF=1

   ; Resultado desempaquetado: AH=01 (decenas), AL=05 (unidades) -> "15"
   push ax
   mov dl, ah
   add dl, 30h
   mov ah, 02h
   int 21h                 ; imprime la decena
   pop ax
   mov dl, al
   add dl, 30h
   mov ah, 02h
   int 21h                 ; imprime la unidad

   mov ah, 09h
   mov dx, msgResta
   int 21h

   ; --- Resta desempaquetada con AAS: 13 - 8 = 5 ---
   ; "13" desempaquetado ya trae AH=01 (decena); se opera sobre AL=03 (unidad)
   mov al, 03h             ; digito de unidades de "13"
   sub al, 08h             ; AL = 03h - 08h = FBh (negativo, requiere ajuste)
   aas                     ; ajusta: AL = 05h, CF=1 (hubo prestamo de la decena)

   mov dl, al              ; imprime la unidad del resultado (la decena queda en 0)
   add dl, 30h
   mov ah, 02h
   int 21h

   mov ah, 09h
   mov dx, crlf
   int 21h
   mov ah, 4Ch
   xor al, al
   int 21h
