; post2.asm - ADC y SBB: suma y resta de 32 bits
; Compilar: nasm -f bin post2.asm -o post2.com
ORG 100h

section .data
   ; A = 0x0001FFFF = 131071 decimal
   ; B = 0x00010001 = 65537 decimal
   ; Esperado: A + B = 0x00030000 = 196608 decimal
   aLo    dw 0FFFFh        ; parte baja de A
   aHi    dw 0001h         ; parte alta de A
   bLo    dw 0001h         ; parte baja de B
   bHi    dw 0001h         ; parte alta de B
   resLo  dw 0             ; resultado parte baja
   resHi  dw 0             ; resultado parte alta
   msg    db "Suma OK: 0003:0000$"
   msgErr db "Error en suma.$"
   msgRes db "Resta OK: 0001:FFFF$"
   msgErrR db "Error en resta.$"
   crlf   db 0Dh,0Ah,"$"

section .text
start:
   mov ax, [aLo]
   mov dx, [aHi]
   mov bx, [bLo]
   mov cx, [bHi]

   add ax, bx              ; sumar partes bajas: CF puede activarse
   adc dx, cx              ; sumar partes altas + CF

   mov [resLo], ax
   mov [resHi], dx

   ; Verificar resultado esperado
   cmp ax, 0000h
   jne .error
   cmp dx, 0003h
   jne .error

   mov ah, 09h
   mov dx, msg
   int 21h
   jmp .resta

.error:
   mov ah, 09h
   mov dx, msgErr
   int 21h

.resta:
   mov ah, 09h
   mov dx, crlf
   int 21h

   ; Restar B de A usando SBB
   ; A = 0x00030000, B = 0x00010001
   ; Esperado: A - B = 0x0001FFFF
   mov ax, 0000h           ; parte baja de A
   mov dx, 0003h           ; parte alta de A
   mov bx, 0001h           ; parte baja de B
   mov cx, 0001h           ; parte alta de B

   sub ax, bx              ; 0000h - 0001h = FFFFh, CF=1 (prestamo)
   sbb dx, cx              ; 0003h - 0001h - CF(1) = 0001h

   ; Resultado: DX:AX = 0001:FFFFh = 0x0001FFFF
   cmp ax, 0FFFFh
   jne .errorResta
   cmp dx, 0001h
   jne .errorResta

   mov ah, 09h
   mov dx, msgRes
   int 21h
   jmp .fin

.errorResta:
   mov ah, 09h
   mov dx, msgErrR
   int 21h

.fin:
   mov ah, 09h
   mov dx, crlf
   int 21h
   mov ah, 4Ch
   xor al, al
   int 21h
