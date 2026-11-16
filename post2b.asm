; post2b.asm - DAA y DAS: suma y resta BCD empaquetada
; Sumar 47 (BCD 47h) + 38 (BCD 38h) = 85 (BCD 85h)
; Restar 73 - 28 = 45 y 20 - 01 = 19 (BCD)
; Compilar: nasm -f bin post2b.asm -o post2b.com
ORG 100h

section .data
   bcd1      db 47h        ; BCD empaquetado: "47"
   bcd2      db 38h        ; BCD empaquetado: "38"
   resultado db 0
   msg       db "BCD suma: $"
   msgCF     db " CF=$"
   crlf      db 0Dh,0Ah,"$"
   msgDas1   db "DAS OK: 45",0Dh,0Ah,"$"
   msgDas2   db "DAS OK: 19",0Dh,0Ah,"$"
   msgErrD   db "Error en DAS.",0Dh,0Ah,"$"

section .text
start:
   mov al, [bcd1]
   add al, [bcd2]          ; AL = 47h + 38h = 7Fh (NO es BCD valido)
   daa                     ; ajustar: AL = 85h (resultado BCD correcto)
   mov [resultado], al
   mov cl, 0               ; MOV no altera las banderas
   adc cl, 0               ; CL = CF que dejo DAA (acarreo al siguiente byte)

   ; Imprimir los dos digitos del resultado (nibble alto y bajo)
   mov ah, 09h
   mov dx, msg
   int 21h

   mov al, [resultado]
   mov bl, al
   shr al, 4               ; nibble alto -> AL (decenas)
   add al, 30h             ; a ASCII
   mov dl, al
   mov ah, 02h
   int 21h

   mov al, bl              ; nibble bajo (unidades)
   and al, 0Fh
   add al, 30h
   mov dl, al
   int 21h

   ; Mostrar el acarreo CF guardado en CL
   mov ah, 09h
   mov dx, msgCF
   int 21h
   mov dl, cl
   add dl, 30h
   mov ah, 02h
   int 21h

   mov ah, 09h
   mov dx, crlf
   int 21h

   ; Restar 73 BCD - 28 BCD = 45 BCD
   mov al, 73h             ; BCD "73"
   sub al, 28h             ; AL = 73h - 28h = 4Bh (NO BCD valido)
   das                     ; ajustar: AL = 45h (correcto)
   cmp al, 45h             ; Verificar: AL debe ser 45h
   jne .error
   mov ah, 09h
   mov dx, msgDas1
   int 21h

   ; Caso con prestamo: 20 BCD - 01 BCD = 19 BCD
   mov al, 20h
   sub al, 01h             ; AL = 1Fh (NO BCD: nibble bajo = Fh > 9)
   das                     ; AL = 19h (correcto), CF=0
   cmp al, 19h             ; Verificar: AL debe ser 19h
   jne .error
   mov ah, 09h
   mov dx, msgDas2
   int 21h
   jmp .fin

.error:
   mov ah, 09h
   mov dx, msgErrD
   int 21h

.fin:
   mov ah, 4Ch
   xor al, al
   int 21h
