# Laboratorio Unidad 8 — Operaciones con Cadenas y Aritmética en NASM
Sara Jaimes Castañeda · Arquitectura de Computadores

Este repositorio contiene el desarrollo de las dos partes del laboratorio de operaciones con cadenas y aritmética en NASM sobre DOSBox. La Parte 1 usa las instrucciones de cadena REP MOVSB/MOVSW, REPNE SCASB y REPE CMPSB para copiar, buscar y comparar cadenas, revisando el papel de SI, DI, CX y el flag DF, y termina con una copia que pasa cada carácter a mayúscula con LODSB y STOSB. La Parte 2 trabaja la aritmética de 32 bits con ADC y SBB, el ajuste BCD con DAA, DAS, AAA y AAS, y una mini calculadora con MUL y DIV.

Entorno utilizado

DOSBox-X 2026.08.31 sobre Windows 11 y NASM 3.00 en su versión para DOS. Los programas se compilan con nasm -f bin dentro de DOSBox-X y la configuración usada está en dosbox.conf.

# PARTE 1 — Instrucciones de Cadena
## Checkpoint 1 — Copia con REP MOVSB
Captura: capturas/CP1_rep_movsb.png

En la primera prueba post1.com compiló, pero mostró "Copiado: HOLA, MUNDO! Copiado:" en lugar de solo la cadena copiada. Esto pasó porque AH=09h imprime hasta encontrar un $ y el origen terminaba en 0, así que destino quedó sin $ y la impresión siguió con el mensaje que seguia en memoria. Por lo tanto se ajustó origen para que terminara en "$" en lugar de 0, por lo que sigue midiendo 13 bytes y CX=13 no cambia. Hecho esto, el programa muestra "Copiado: HOLA, MUNDO!", lo que confirma que REP MOVSB llevó los 13 bytes de DS:SI a ES:DI con DF en 0 por el CLD, avanzando ambos punteros de la dirección baja a la alta.
