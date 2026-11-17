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

## Checkpoint 3 — Suma BCD con DAA
Capturas: capturas/P2_CP3_compilacion.png, capturas/P2_CP3_ejecucion.png, capturas/P2_CP3_sin_daa.png y capturas/P2_CP3_99_mas_01.png

En la primera prueba post2b.com mostró "BCD suma: 85", pero no dejaba ver el acarreo que pide revisar la suma 99h + 01h. Por lo tanto se agregó una línea que guarda CF en CL justo después de DAA y se imprime al final como "CF=". Hecho esto, la suma 47h + 38h muestra "BCD suma: 85 CF=0". ADD deja AL en 7Fh y como el nibble bajo F es mayor que 9, DAA le suma 6 y lo corrige a 85h. Al quitar DAA de forma temporal la salida fue "7? CF=0", donde el "?" es la F sin ajustar, ya que la impresión le suma 30h y 0Fh + 30h da 3Fh. Además, al cambiar los operandos por 99h y 01h la salida fue "00 CF=1", porque DAA ajusta los dos nibbles de 9Ah y el acarreo pasa al siguiente byte BCD.

## Checkpoint 4 — Resta BCD con DAS
Capturas: capturas/P2_CP4_compilacion.png y capturas/P2_CP4_ejecucion.png

Las dos restas se agregaron a post2b.asm, con sus mensajes y un mensaje de error. En 73h - 28h, SUB deja AL en 4Bh y como el nibble bajo B es mayor que 9, DAS le resta 6 y lo corrige a 45h. En 20h - 01h, SUB deja 1Fh y DAS corrige el nibble bajo F a 19h, sin préstamo hacia el siguiente byte. Cada caso compara AL con el valor esperado antes de imprimir, y la salida muestra "DAS OK: 45" y "DAS OK: 19" debajo de la suma del checkpoint anterior.

## Checkpoint 5 — Calculadora con MUL/DIV
Capturas: capturas/P2_CP5_compilacion.png y capturas/P2_CP5_ejecucion.png

En la primera prueba post2c.asm no compiló y NASM marcó un error en la línea del mensaje del operador. Esto pasó porque la variable se llamaba pOp y NASM no distingue mayúsculas en las instrucciones, así que la leyó como POP. Por lo tanto se renombró la variable a pOper. Hecho esto, la calculadora compiló y dio "Resultado: 56" para 7×8, "Resultado: 3" para 9/3 y "Division por cero." al dividir 5 entre 0. Cada dígito se lee con INT 21h/AH=01h y se le resta 30h para pasarlo de ASCII a binario, MUL CL deja el producto en AX y DIV CL deja el cociente en AL y el resto en AH. Luego imprimirAX divide AX entre 10 varias veces, guarda cada resto en la pila y los saca en orden inverso sumándoles 30h para imprimir el número en decimal.

## Checkpoint 6 — Suma y resta BCD desempaquetada con AAA/AAS
Capturas: capturas/P2_CP6_compilacion.png, capturas/P2_CP6_ejecucion.png y capturas/P2_CP6_sin_ajuste.png

En la primera prueba post2d.com mostró "AAA: 7 + 8 = :5" aunque la resta sí salió bien. Esto pasó porque AH seguía en 09h por la impresión del mensaje y AAA le sumó 1, quedando en 0Ah, que al sumarle 30h se imprime como ":". Por lo tanto se agregó XOR AH, AH antes de cargar el 7 para que la decena empiece en 0. Hecho esto, la salida muestra "AAA: 7 + 8 = 15" y "AAS: 13 - 8 = 5". AAA ve que el nibble bajo de 0Fh es mayor que 9, deja en AL solo el 5 con el nibble alto en 0 y suma 1 a AH, que es la decena. AAS hace lo contrario con FBh, deja AL en 05h y marca el préstamo de la decena con CF. Al quitar las dos instrucciones de forma temporal la salida fue "0?" y "+", lo que confirma que sin ajuste 0Fh y FBh no son dígitos desempaquetados válidos.

## Decisión Técnica — DAA/DAS frente a AAA/AAS según el formato del dato
Usar AAA en lugar de DAA sobre un byte empaquetado como 47h daría un resultado incorrecto porque AAA solo ajusta el nibble bajo de AL y pone el nibble alto en cero, así que el 4 de las decenas se perdería. En cambio DAA ajusta los dos nibbles, como se vio en post2b.com, donde 47h + 38h dio 7Fh y DAA lo corrigió a 85.

Para la calculadora la instrucción correcta sería AAA, porque al leer un dígito con INT 21h/AH=01h y restarle 30h queda un solo dígito por byte con el nibble alto en 0. AAA deja las unidades en AL y lleva la decena a AH, y así post2d.com mostró 15 para 7 + 8.

Aplicar DAA sobre 0Fh sería un error porque DAA toma el nibble alto en 0 como si ya fuera un dígito decimal válido y deja 15h dentro de AL, con la decena en el nibble alto en lugar de AH. Por lo tanto, al imprimir AL como un dígito desempaquetado el resultado saldría mal, y la decena nunca llegaría a AH.

Capturas: capturas/P2_CP3_ejecucion.png y capturas/P2_CP6_ejecucion.png

## Decisión Técnica — ADC de precisión fija frente a una cadena de ADC en bucle
Para generalizar la suma de post2.asm a N palabras se guardan los dos números en memoria desde la palabra de menor peso, se apunta a cada uno con SI y DI y se carga N en CX. En cada vuelta se suma una palabra con ADC a la del otro número, se guarda el resultado, se avanzan los punteros con INC, que no cambia CF, y LOOP repite.

La primera palabra se suma con ADD porque antes de ella no hay ningún acarreo que propagar. Por eso en el bucle se usa CLC antes de entrar, que deja CF en 0 y equivale a empezar con ADD. Las siguientes necesitan ADC para sumar el acarreo de la anterior, como en post2.com, donde FFFFh + 0001h dejó CF en 1 y ADC lo llevó a la parte alta para dar 0003:0000.

El bucle es más mantenible porque sirve para 48, 64 o más bits con solo cambiar CX, como un tipo bignum. Sin embargo es más lento, porque cada palabra paga la carga, el guardado, los incrementos y el LOOP, frente a las dos instrucciones fijas de post2.asm, igual que el bucle LODSB/STOSB frente a REP MOVSB en la Parte 1.

Captura: capturas/P2_CP2_ejecucion.png
