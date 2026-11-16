# Laboratorio Unidad 8 — Operaciones con Cadenas y Aritmética en NASM
Sara Jaimes Castañeda · Arquitectura de Computadores

Este repositorio contiene el desarrollo de las dos partes del laboratorio de operaciones con cadenas y aritmética en NASM sobre DOSBox. La Parte 1 usa las instrucciones de cadena REP MOVSB/MOVSW, REPNE SCASB y REPE CMPSB para copiar, buscar y comparar cadenas, revisando el papel de SI, DI, CX y el flag DF, y termina con una copia que pasa cada carácter a mayúscula con LODSB y STOSB. La Parte 2 trabaja la aritmética de 32 bits con ADC y SBB, el ajuste BCD con DAA, DAS, AAA y AAS, y una mini calculadora con MUL y DIV.

Entorno utilizado

DOSBox-X 2026.08.31 sobre Windows 11 y NASM 3.00 en su versión para DOS. Los programas se compilan con nasm -f bin dentro de DOSBox-X y la configuración usada está en dosbox.conf.

# PARTE 1 — Instrucciones de Cadena
## Checkpoint 1 — Copia con REP MOVSB
Capturas: capturas/CP1_compilacion.png y capturas/CP1_ejecucion.png

En la primera prueba post1.com compiló, pero mostró "Copiado: HOLA, MUNDO! Copiado:" en lugar de solo la cadena copiada. Esto pasó porque AH=09h imprime hasta encontrar un $ y el origen terminaba en 0, así que destino quedó sin $ y la impresión siguió con el mensaje que seguia en memoria. Por lo tanto se ajustó origen para que terminara en "$" en lugar de 0, por lo que sigue midiendo 13 bytes y CX=13 no cambia. Hecho esto, el programa muestra "Copiado: HOLA, MUNDO!", lo que confirma que REP MOVSB llevó los 13 bytes de DS:SI a ES:DI con DF en 0 por el CLD, avanzando ambos punteros de la dirección baja a la alta.

## Checkpoint 2 — Copia optimizada con REP MOVSW
Capturas: capturas/CP2_compilacion.png y capturas/CP2_ejecucion.png

Se modifico post1.asm para usar REP MOVSW. CX se divide entre dos con SHR y REP MOVSW mueva 6 palabras, es decir 12 bytes, avanzando SI y DI de dos en dos. Como 13 AND 1 da 1, queda un byte impar que se copia aparte con un MOVSB final. El programa imprime "Copiado: HOLA, MUNDO!", igual que la versión con REP MOVSB, por lo tanto destino quedó con los mismos 13 bytes del origen.

## Checkpoint 3 — Búsqueda con REPNE SCASB
Capturas: capturas/CP3_compilacion.png, capturas/CP3_busqueda_d.png y capturas/CP3_busqueda_z.png

En la primera prueba post1c.com mostró "Hallado en posicion: =" porque la primera "d" de "Arquitectura de Computadores" está en el índice 13 y el programa solo imprimía un dígito sumando 30h, y 13 + 30h da 3Dh, que es el carácter "=". Por lo tanto se ajustó la impresión para dividir la posición entre 10 con DIV y mostrar la decena y la unidad por separado. Hecho esto, el programa muestra "Hallado en posicion: 13". REPNE SCASB compara AL con ES:DI y se detiene con ZF en 1 cuando lo encuentra, dejando DI un byte después de la letra, por eso se resta el inicio y luego 1. Al cambiar el carácter buscado por "z" la búsqueda deja CX en 0 con ZF en 0, por lo tanto el programa imprime "No encontrado.".

## Checkpoint 4 — Comparación con REPE CMPSB
Capturas: capturas/CP4_compilacion.png y capturas/CP4_ejecucion.png

En la primera prueba post1d.com mostró "Iguales." y "Diferentes.", pero no había forma de ver en qué carácter se detenía la segunda comparación. Esto pasaba porque el programa solo revisa ZF al final y no muestra dónde quedaron los punteros. Por lo tanto se agregó un mensaje que calcula la posición restando el inicio de cad1 a SI y luego 1, ya que al encontrar la diferencia SI queda un byte después del carácter distinto. Hecho esto, la salida muestra "Diferentes. Se detuvo en posicion: 5". Contando desde 0, las dos cadenas coinciden hasta el espacio de la posición 4 y en la posición 5 aparece la primera diferencia, la "x" de cad1 frente a la "A" de cad3.
