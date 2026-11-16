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

## Checkpoint 5 — Copia con transformación LODSB/STOSB
Capturas: capturas/CP5_compilacion.png y capturas/CP5_ejecucion.png

En la primera prueba post1e.com transformó bien la cadena, pero mostró "Transformado: HOLA, MUNDO! Transformado:" por el mismo motivo del checkpoint 1, ya que el origen terminaba en 0 y destino quedaba sin $. Por lo tanto se cambió ese 0 por "$", y como el $ no está entre "a" y "z" el bucle lo copia sin tocarlo. Hecho esto, el programa muestra "Transformado: HOLA, MUNDO!" a partir de "hola, mundo!". En cada vuelta LODSB carga el carácter en AL y avanza SI, luego dos comparaciones revisan si está entre "a" y "z" y en ese caso se le resta 20h, y al final STOSB lo guarda en destino y avanza DI, algo que REP MOVSB no puede hacer porque copia los bytes sin revisarlos.

## Decisión Técnica — REP MOVSB frente a un bucle manual con LODSB/STOSB
REP MOVSB es más rápido en una copia sin transformación porque el procesador repite la instrucción por dentro con su microcódigo, bajando CX y avanzando SI y DI sin volver a decodificar nada. En cambio el bucle de post1e.asm, por cada byte, decodifica LODSB, dos CMP con sus saltos, la posible SUB, STOSB y LOOP, y en cada vuelta evalúa si debe saltar. Además el programa queda más corto, post1.com ocupa 79 bytes frente a los 96 de post1e.com.

Se tuvo que dejar REP MOVSB en post1e.asm porque mueve los bytes sin pasarlos por un registro, así que no hay un momento para revisar o cambiar el carácter. Al probar post1e.asm con REP MOVSB en lugar del bucle, el programa mostró "Transformado: hola, mundo!", con la cadena copiada pero en minúsculas. Con LODSB el carácter queda en AL y ahí se compara y se le resta 20h antes de guardarlo con STOSB.

Para copiar una cadena larga sin ninguna transformación seguiría siendo preferible REP MOVSB, porque entre más bytes haya más se acumula el costo de las instrucciones extra de cada vuelta del bucle. El bucle manual solo se justifica cuando cada carácter necesita una lógica propia.

Captura: capturas/CP6_movsb_sin_transformar.png

## Decisión Técnica — CX fijo en REPE CMPSB/REPNE SCASB frente a revisar el terminador
Al comparar con CX=8 una cadena de 5 caracteres y otra de 8, la instrucción sigue después del 0 de la cadena corta y lee los bytes de la variable que está a continuación en memoria, que ya no le pertenecen. Para comprobarlo se cambiaron temporalmente cad1 y cad2 de post1d.asm por "HOLA!", la misma cadena de 5 caracteres, y con CX=8 el programa respondió "Diferentes." porque después del 0 cada una tiene una variable distinta.

Para cadenas de longitud desconocida se adaptaría el bucle de post1e.asm cargando con LODSB el carácter de la primera cadena y guardándolo en BL, luego se intercambian SI y DI para cargar con otro LODSB el de la segunda, y en lugar de STOSB se comparan los dos con CMP. Si son distintos las cadenas son diferentes, si son iguales y valen 0 las dos terminaron y son iguales, y si no se repite sin depender de CX.

REPE CMPSB con CX fijo es apropiado en post1d.asm porque cad1, cad2 y cad3 son literales de 8 caracteres conocidos al ensamblar, así que CX=8 nunca pasa del terminador. Sin embargo no sirve en general, porque una cadena leída del teclado no tiene una longitud conocida de antemano.

Captura: capturas/CP6_cx_fijo_cadena_corta.png


# PARTE 2 — Aritmética de Precisión Múltiple y BCD
## Checkpoint 1 — Suma de 32 bits con ADC
Capturas: capturas/P2_CP1_compilacion.png y capturas/P2_CP1_ejecucion.png

post2.asm suma A = 0001FFFFh y B = 00010001h guardando cada número en dos palabras de 16 bits. ADD suma primero las partes bajas, FFFFh + 0001h, que da 0000h con CF en 1, y luego ADC suma las partes altas más ese acarreo, 0001h + 0001h + 1 = 0003h. El programa compara AX con 0000h y DX con 0003h antes de imprimir, y al mostrar "Suma OK: 0003:0000" se confirma que el acarreo de la parte baja pasó a la parte alta.

## Checkpoint 2 — Resta de 32 bits con SBB
Capturas: capturas/P2_CP2_compilacion.png y capturas/P2_CP2_ejecucion.png

Se extendió post2.asm con la resta 00030000h menos 00010001h, que se hace con SUB en las partes bajas y SBB en las altas. Como 0000h menos 0001h necesita un préstamo, SUB deja AX en FFFFh con CF en 1, y luego SBB resta ese préstamo junto con la parte alta, 0003h - 0001h - 1 = 0001h. Para la nueva salida se agregaron el mensaje de resta, su mensaje de error y el salto de línea. El programa ahora imprime "Suma OK: 0003:0000" y debajo "Resta OK: 0001:FFFF", que solo aparece si DX quedó en 0001h y AX en FFFFh.
