# Guía de estudio de TurnoLang

Esta guía presenta los conceptos necesarios para comprender, implementar y
defender TurnoLang. Conviene leerla en orden: cada parte agrega una etapa al
recorrido que va desde los caracteres de un archivo `.tl` hasta los resultados
del intérprete.

## Parte 1. Fundamentos

### 1. ¿Qué es un lenguaje de programación?

Un **lenguaje de programación** es un sistema de símbolos y reglas que permite
expresar instrucciones de forma precisa. Sirve para comunicar un procedimiento
a una computadora y para que una herramienta pueda decidir si ese procedimiento
está bien escrito y qué significa. En TurnoLang, por ejemplo,
`CANCELAR turno1;` expresa una operación sin depender de una interfaz gráfica.

Todo lenguaje necesita al menos:

- una forma de escritura, llamada sintaxis;
- un significado para las construcciones, llamado semántica; y
- un procesador que traduzca o ejecute esas construcciones.

### 2. ¿Qué es un DSL?

Un **DSL** (*Domain-Specific Language* o lenguaje específico de dominio) es un
lenguaje diseñado para un problema acotado. Sirve para expresar ese problema con
menos elementos que un lenguaje general como C. TurnoLang es un DSL porque solo
habla de una agenda diaria: reservar, cancelar, consultar y listar.

Esta limitación es intencional. TurnoLang no necesita ciclos, funciones,
aritmética general ni acceso a redes. Un vocabulario pequeño permite concentrar
el trabajo en las etapas de procesamiento del lenguaje.

### 3. Lenguaje fuente y resultado

El **lenguaje fuente** es el lenguaje en el que está escrito el programa que se
procesa. Sirve como entrada del frontend. En este proyecto es TurnoLang y sus
archivos terminan en `.tl`.

Un **lenguaje destino** es el lenguaje al que un compilador traduce el programa,
por ejemplo código máquina o ensamblador. TurnoLang no genera otro lenguaje: su
backend interpreta el programa y produce resultados de ejecución por consola.
La frase `Franja 09:30-10:00: DISPONIBLE` es una salida, no código TurnoLang.

### 4. ¿Qué es un compilador?

Un **compilador** es un programa que analiza un programa fuente y lo traduce a
otra representación ejecutable o a otro lenguaje. Sirve para hacer el análisis
antes de la ejecución y generar un resultado que puede ejecutarse después. Por
ejemplo, GCC transforma archivos C en archivos objeto y en un ejecutable.

La traducción suele incluir un frontend que reconoce el programa, una
representación intermedia y un backend que genera el destino. Que TurnoLang use
GCC para construir su herramienta no significa que TurnoLang sea compilado: GCC
compila la implementación C; la herramienta resultante interpreta `.tl`.

### 5. ¿Qué es un intérprete?

Un **intérprete** es un programa que analiza una entrada y ejecuta directamente
su significado, sin generar necesariamente un ejecutable separado para esa
entrada. Sirve cuando interesa aplicar las instrucciones y observar sus
resultados de inmediato. El intérprete TurnoLang recorre una reserva, comprueba
si es válida y modifica una agenda que vive en memoria.

### 6. Compilador e intérprete

| Aspecto | Compilador | Intérprete TurnoLang |
|---|---|---|
| Resultado principal | Código o representación destino. | Efectos y texto por consola. |
| Momento de ejecución | El producto generado se ejecuta después. | Las instrucciones se ejecutan durante el procesamiento. |
| Backend | Genera código. | Valida y ejecuta operaciones de agenda. |
| Ejemplo | GCC compila `main.c`. | TurnoLang ejecuta `LISTAR;`. |

Ambos pueden tener análisis léxico, sintáctico y semántico. Por eso elegir un
intérprete no elimina las etapas estudiadas en Compiladores.

### 7. Frontend y backend

El **frontend** es la parte que entiende la forma del lenguaje fuente. Sirve para
convertir caracteres en tokens, comprobar la gramática y construir una
representación interna. En TurnoLang comprende Flex, Bison y el AST mínimo.

El **backend** es la parte que da un resultado a esa representación. Sirve para
generar código o ejecutar el significado. En TurnoLang recorre el AST, valida
cada instrucción contra el estado y la ejecuta.

### 8. Etapas completas

```text
archivo .tl
  → análisis léxico (caracteres a tokens)
  → análisis sintáctico (tokens a estructura)
  → AST mínimo (programa representado en memoria)
  → análisis semántico (reglas del dominio y estado)
  → interpretación (cambios y consultas)
  → salida o diagnóstico
```

Un error en una etapa impide avanzar de manera segura. Un símbolo desconocido
no llega al parser; una sentencia sin punto y coma no llega al intérprete; una
reserva superpuesta no modifica el estado.

## Parte 2. Análisis léxico

### 1. Scanner, lexer, token y lexema

Un **scanner** o **lexer** es el componente que lee caracteres y los agrupa en
unidades. Sirve para que el parser trabaje con categorías y no con cada carácter
por separado. En este proyecto, ambos términos se refieren al analizador generado
por Flex.

Un **token** es una categoría léxica. Sirve para indicar qué clase de elemento
se reconoció: `TOK_IDENT`, `TOK_HORA` o `TOK_RESERVAR`. Un **lexema** es el texto
concreto que originó ese token. En `turno1`, el token es `TOK_IDENT` y el lexema
es `turno1`.

Algunos tokens solo necesitan su tipo. El parser no necesita conservar el texto
de `RESERVAR` porque ya sabe qué palabra es. Otros necesitan un valor: debe
preservar `turno1` o `09:00` para construir la sentencia.

### 2. Expresiones regulares

Una **expresión regular** es una notación para describir patrones de texto.
Sirve para definir qué lexemas pertenecen a cada token. Ejemplos conceptuales:

```text
IDENT  [A-Za-z_][A-Za-z0-9_]*
HORA   [0-9]{2}:[0-9]{2}
```

La primera regla exige que el identificador empiece con letra o guion bajo. La
segunda exige exactamente dos dígitos, dos puntos y dos dígitos. La expresión
regular comprueba forma, no significado: `25:99` tiene forma de `HORA`, aunque
sus valores sean inválidos.

### 3. Flex

**Flex** es un generador de analizadores léxicos. Sirve para convertir reglas de
expresiones regulares y acciones C en una función `yylex`. Su entrada de proyecto
será `src/lexer.l`; su salida será un archivo C generado que no se edita a mano.

Un archivo `lexer.l` tiene, de manera simplificada, tres secciones separadas por
`%%`:

```text
declaraciones C y opciones
%%
patrón    acción C
patrón    acción C
%%
código auxiliar
```

Cuando encuentra `RESERVAR`, la acción devuelve `TOK_RESERVAR`. Cuando encuentra
un identificador, copia el lexema en el valor semántico y devuelve `TOK_IDENT`.
Los espacios se consumen sin devolver tokens. Una regla final debe capturar lo
no reconocido y emitir un error; ignorarlo haría que una entrada incorrecta
pareciera válida.

El orden de las reglas importa cuando varias coinciden. Flex elige primero la
coincidencia más larga y, ante igual longitud, la regla escrita antes. Por eso
las palabras reservadas se ubican antes de la regla general de identificador.

### 4. Ejemplo léxico aplicado

Entrada:

```text
RESERVAR turno1 DESDE 09:00 HASTA 09:30;
```

Salida conceptual:

| Orden | Lexema | Token | Valor conservado |
|---:|---|---|---|
| 1 | `RESERVAR` | `TOK_RESERVAR` | Ninguno. |
| 2 | `turno1` | `TOK_IDENT` | `"turno1"`. |
| 3 | `DESDE` | `TOK_DESDE` | Ninguno. |
| 4 | `09:00` | `TOK_HORA` | `"09:00"`. |
| 5 | `HASTA` | `TOK_HASTA` | Ninguno. |
| 6 | `09:30` | `TOK_HORA` | `"09:30"`. |
| 7 | `;` | `TOK_PUNTO_Y_COMA` | Ninguno. |

El scanner también actualiza el número de línea. Esa ubicación se copia al nodo
de sentencia para que un error semántico posterior pueda señalar su origen.

## Parte 3. Análisis sintáctico

### 1. Parser y gramática

Un **parser** o analizador sintáctico es el componente que recibe tokens y decide
si forman una estructura permitida. Sirve para detectar orden, elementos
obligatorios y anidamiento. Sabe que después de `RESERVAR` debe haber un
identificador; no sabe todavía si el intervalo se cruza con otro.

Una **gramática** es un conjunto de símbolos y reglas de producción. Sirve como
especificación formal de la estructura de un lenguaje. Una **gramática libre de
contexto** permite reemplazar un símbolo no terminal usando una producción sin
depender de los símbolos vecinos. Por ejemplo:

```text
listado → LISTAR ";"
```

`listado` es no terminal; `LISTAR` y `;` son terminales porque corresponden a
tokens de entrada.

### 2. BNF y EBNF

**BNF** (*Backus-Naur Form*) es una notación para escribir producciones. Sirve
para describir alternativas y secuencias. **EBNF** (*Extended BNF*) agrega
abreviaturas como `*` para repetición y `?` para opcionalidad. Sirve para que una
especificación humana sea más compacta.

En EBNF, TurnoLang usa:

```ebnf
programa ::= cabecera sentencia* EOF ;
```

En Bison, la repetición se expresa con recursión:

```text
lista_sentencias
    : /* vacía */
    | lista_sentencias sentencia
    ;
```

Ambas formas representan cero o más sentencias.

### 3. Bison y `parser.y`

**Bison** es un generador de analizadores sintácticos. Sirve para convertir una
gramática y sus acciones en código C. Su entrada será `src/parser.y`; generará el
parser C y un encabezado con tokens que `lexer.l` incluirá.

El archivo contiene declaraciones de tokens y tipos, reglas entre `%%`, y código
auxiliar. Una producción conceptual podría ser:

```text
reserva:
    TOK_RESERVAR TOK_IDENT TOK_DESDE TOK_HORA TOK_HASTA TOK_HORA ';'
    { crear_reserva($2, $4, $6, linea); }
```

Los símbolos `$2`, `$4` y `$6` representan los valores de los elementos de esa
producción. El código definitivo deberá gestionar sus tipos, propiedad de
memoria y errores. La acción construye datos; no busca superposiciones.

Flex y Bison cooperan mediante un contrato: Bison define números y valores de
tokens; Flex incluye ese encabezado, carga el valor correspondiente y devuelve
el token. Bison llama repetidamente a `yylex` hasta aceptar el programa o
detectar un error.

### 4. Derivaciones y árboles

Una **derivación** es la aplicación paso a paso de producciones para obtener una
secuencia de terminales. Sirve para justificar que una entrada pertenece al
lenguaje. Para `LISTAR;`:

```text
sentencia ⇒ listado ⇒ LISTAR ";"
```

Un **árbol sintáctico** representa esa derivación completa. Su raíz puede ser
`sentencia`, con un hijo `listado` y hojas `LISTAR` y `;`. Es útil para entender
la gramática, pero conservar todos esos nodos durante la ejecución sería
innecesario para este proyecto.

### 5. Errores sintácticos

Un **error sintáctico** ocurre cuando todos los fragmentos pueden ser tokens,
pero su secuencia no coincide con la gramática. Sirve para informar que falta,
sobra o está fuera de lugar una pieza estructural.

```text
RESERVAR turno1 DESDE 09:00 HASTA 09:30
```

Aquí los lexemas son reconocibles, pero falta `;`. Bison encuentra fin de archivo
cuando esperaba el terminador. El diagnóstico debe indicar etapa sintáctica,
línea y una explicación legible; no debe presentar únicamente estados internos
del parser.

## Parte 4. Análisis semántico

### 1. Qué valida

El **análisis semántico** comprueba condiciones de significado que la gramática
no expresa de manera conveniente. Sirve para impedir programas bien formados
pero incoherentes con la agenda. Por ejemplo, la gramática acepta dos tokens
`HORA`; una función C decide si el primero es anterior al segundo.

La diferencia central es:

- sintaxis: «¿tiene la forma de una reserva?»;
- semántica: «¿esta reserva se puede realizar en el estado actual?».

### 2. Acciones semánticas de Bison y funciones C

Una **acción semántica de Bison** es código asociado a una producción. Sirve para
calcular o construir el valor de la regla reconocida. El nombre puede causar
confusión: no significa que toda validación semántica deba escribirse dentro de
`parser.y`.

En TurnoLang, las acciones de Bison:

1. reciben cadenas y horas de Flex;
2. crean nodos tipados del AST;
3. conservan la línea de origen; y
4. enlazan las sentencias en orden.

Después, funciones C del módulo semántico validan intervalos, identificadores y
superposiciones. Así la gramática queda legible y una misma función de
intersección sirve para reserva y disponibilidad.

### 3. Identificadores y tabla de símbolos

Un **identificador** es un nombre elegido en el programa para referirse a una
entidad. Sirve para poder cancelar una reserva posterior mediante `turno1`. En
TurnoLang coincide con `[A-Za-z_][A-Za-z0-9_]*` y no puede ser una palabra
reservada.

Una **tabla de símbolos** relaciona identificadores con información conocida.
Sirve, en lenguajes generales, para registrar variables, tipos o ámbitos. En
TurnoLang su aplicación es más simple: una lista de reservas relaciona ID,
inicio, fin y estado activo. Una lista es suficiente y más fácil de defender que
una tabla hash para el volumen previsto.

Un ID activo no puede reservarse otra vez. Al cancelarlo deja de estar activo y
puede reutilizarse posteriormente. Cancelar un ID que nunca existió o que ya fue
cancelado produce el mismo tipo de error: no hay una reserva activa con ese ID.

### 4. Horarios e intervalos

Una hora con formato `HH:MM` se convierte a minutos:

```text
minutos = HH * 60 + MM
```

Antes de convertir se valida `00 ≤ HH ≤ 23` y `00 ≤ MM ≤ 59`. Luego se exige
`inicio < fin`. TurnoLang no representa intervalos que crucen medianoche.

Un **intervalo semiabierto** `[inicio, fin)` incluye el inicio y excluye el fin.
Sirve para permitir turnos consecutivos. Las reservas `[09:00,09:30)` y
`[09:30,10:00)` comparten un valor de frontera, pero ningún minuto ocupado.

Dos intervalos se superponen si:

```text
inicioA < finB && finA > inicioB
```

No alcanza con comparar solo las horas de inicio: un turno puede comenzar antes
y cubrir por completo al nuevo.

### 5. Validar antes de ejecutar

Para cada nodo, el intérprete primero llama a una función que consulta el estado
sin modificarlo. Si la validación tiene éxito, otra función aplica el cambio o
muestra la consulta. Esto evita una reserva parcialmente agregada antes de
descubrir una superposición. También permite explicar por separado «por qué la
instrucción es válida» y «qué efecto produce».

`LIBRE` usa la misma validación de rango y la misma función de superposición que
`RESERVAR`, pero encontrar una intersección no es error: su resultado normal es
`OCUPADO`.

## Parte 5. AST

### 1. Definición y función

AST significa **Abstract Syntax Tree** o árbol de sintaxis abstracta. Es una
representación interna que conserva el significado estructural y omite detalles
puramente sintácticos. Sirve como frontera entre el parser y el intérprete.

El árbol sintáctico completo conservaría nodos para `DESDE`, `HASTA` y `;`. El
AST de una reserva solo necesita tipo, ID, inicio, fin y línea. Por eso es
«abstracto».

### 2. Representación mínima en C

Una forma conceptual, no todavía implementada, es:

```c
typedef enum {
    SENT_RESERVAR,
    SENT_CANCELAR,
    SENT_LIBRE,
    SENT_LISTAR
} TipoSentencia;

typedef struct Sentencia {
    TipoSentencia tipo;
    int linea;
    /* unión con los datos propios de cada tipo */
    struct Sentencia *siguiente;
} Sentencia;
```

El programa contiene el nombre de agenda y el primer nodo. Una unión permite
guardar ID y horas solo en las sentencias que los usan. El diseño final debe
incluir constructores y funciones de liberación para evitar fugas de memoria.

### 3. Construcción y uso

Bison crea un nodo cuando reduce una producción de sentencia y lo agrega a la
lista manteniendo el orden fuente. Tras aceptar todo el archivo, `main` entrega
el programa al intérprete. Este recorre los nodos una sola vez.

El AST no es una exigencia de la cátedra. Se usa porque hace visible el pasaje
frontend–backend y evita ejecutar operaciones mientras todavía se desconoce si
el resto del archivo tiene un error sintáctico. Debe permanecer mínimo: una
infraestructura genérica de árboles agregaría trabajo sin mejorar la
demostración.

## Parte 6. Herramientas

### Flex

Flex genera un scanner C. Recibe `lexer.l`, donde se escriben expresiones
regulares y acciones, y produce un archivo C generado. Resuelve la clasificación
repetitiva de caracteres en tokens. En TurnoLang reconoce `AGENDA`, IDs, cadenas,
horas y `;`, actualiza líneas y reporta lexemas inválidos.

### Bison

Bison genera un parser C. Recibe `parser.y`, donde se declaran tokens, tipos y
producciones, y produce código del parser y un encabezado. Resuelve el
reconocimiento de estructuras gramaticales. Flex incluye el encabezado generado
y Bison llama a la función de Flex; por eso ambos deben compilarse con una
dependencia correcta en Make.

### GNU Make

**GNU Make** es una herramienta de automatización basada en dependencias. Sirve
para ejecutar solo los pasos necesarios y ofrecer comandos reproducibles. Un
**Makefile** declara objetivos (*targets*), prerrequisitos y recetas.

En el proyecto:

- `make` generará scanner y parser, compilará C y enlazará el ejecutable;
- `make test` dependerá del ejecutable y ejecutará todos los escenarios; y
- `make clean` eliminará solamente archivos generados y productos de compilación.

Si cambia `parser.y`, deben regenerarse parser y encabezado antes de recompilar
el scanner que incluye ese encabezado. Esa relación es una dependencia, no solo
un orden escrito por costumbre.

### GCC

**GCC** es una colección de compiladores; aquí se usa como compilador de C. Sirve
para transformar los módulos escritos y generados en objetos y enlazarlos en el
ejecutable TurnoLang. Las advertencias deben habilitarse y revisarse; una
compilación exitosa con advertencias de tipos o memoria no constituye un cierre
de tarea.

### Git

**Git** es un sistema de control de versiones distribuido. Sirve para conservar
la historia, comparar cambios y recuperar estados. Un **commit** es un registro
identificado de un conjunto coherente de cambios. Una **rama** es una línea de
desarrollo que apunta a una secuencia de commits.

En TurnoLang, Git proporciona evidencia de cuándo se cerró el diseño, se agregó
una regla o se incorporó una prueba. No reemplaza las pruebas: que un archivo
esté versionado no demuestra que funcione.

## Parte 7. Ejemplo completo

Se sigue esta instrucción:

```text
RESERVAR turno1 DESDE 09:00 HASTA 09:30;
```

### Paso 1. Lectura

`main` abre el archivo `.tl` y configura su flujo como entrada del scanner. Flex
lee caracteres desde la posición actual. La cabecera `AGENDA` ya debió aparecer
porque la gramática la exige antes de cualquier sentencia.

### Paso 2. Flex identifica tokens

Flex encuentra la palabra literal `RESERVAR`, luego el identificador `turno1`,
las palabras `DESDE` y `HASTA`, las dos horas y el terminador. Devuelve los siete
tokens indicados en la tabla de la Parte 2. Copia ID y horas como valores y
registra la línea.

### Paso 3. Bison reconoce la estructura

El parser compara la secuencia con:

```ebnf
reserva ::= RESERVAR IDENT DESDE HORA HASTA HORA ";" ;
```

Como coincide, reduce esos terminales a una `reserva` y luego a una `sentencia`.
Si `HASTA` faltara, la reducción no sería posible y aparecería un error
sintáctico.

### Paso 4. Representación interna

La acción de Bison crea conceptualmente:

```text
tipo = SENT_RESERVAR
id = "turno1"
inicio = "09:00"
fin = "09:30"
linea = línea de RESERVAR
```

El nodo se agrega al final de la lista del programa. `DESDE`, `HASTA` y `;` no se
guardan porque ya cumplieron su función estructural.

### Paso 5. Validación semántica

Al interpretar el nodo:

1. se comprueba que `09` y `00`, `09` y `30` estén en rango;
2. se convierten a 540 y 570 minutos;
3. se comprueba `540 < 570`;
4. se busca si `turno1` ya está activo; y
5. se compara `[540,570)` con cada reserva activa mediante la fórmula de
   superposición.

Ninguna comprobación modifica todavía el estado.

### Paso 6. Ejecución

Si todas las validaciones tienen éxito, el backend agrega la reserva activa al
estado en memoria. Si una falla, informa el error semántico y no agrega nada.

### Paso 7. Resultado

La operación puede producir una confirmación según el contrato de salida que se
estabilice. En cualquier caso, un `LISTAR;` posterior debe mostrar `turno1` en
`09:00-09:30`, y una consulta que interseque ese intervalo debe responder
`OCUPADO`.

## Parte 8. Errores

### Error léxico

```text
RESERVAR turno1 DESDE 9:00 HASTA 09:30;
```

`9:00` no cumple la forma exacta de dos dígitos antes de `:`. El scanner no puede
producir un `TOK_HORA` correcto y reporta error léxico. El diagnóstico debe
capturar la unidad problemática completa cuando sea posible.

Otro error léxico es un símbolo sin regla:

```text
LISTAR@;
```

### Error sintáctico

```text
RESERVAR turno1 DESDE 09:00 HASTA 09:30
```

Cada lexema es reconocible, pero la producción exige `;`. Bison reporta error
sintáctico al encontrar el siguiente token o el fin de archivo.

### Error semántico

```text
RESERVAR turno1 DESDE 11:00 HASTA 10:00;
```

La forma coincide con la gramática, pero el inicio no es anterior al fin. La
función de intervalos reporta error semántico.

Es importante diferenciar:

```text
9:00   → mal formado → error léxico
25:00  → forma HH:MM correcta, valor imposible → error semántico
```

Una superposición o un ID activo duplicado también son semánticos porque solo
pueden decidirse consultando el estado creado por instrucciones anteriores.

## Parte 9. Preparación para la defensa

### ¿Por qué desarrollaron un intérprete?

Porque el resultado natural del DSL es ejecutar operaciones de una agenda y
mostrar consultas. Un intérprete ofrece un backend verificable sin agregar la
complejidad innecesaria de generar otro lenguaje.

### ¿Qué función cumple Flex?

Genera el scanner que transforma caracteres en tokens mediante expresiones
regulares. También detecta lexemas no reconocidos y registra su ubicación.

### ¿Qué hace Bison?

Genera el parser que valida el orden de los tokens según la gramática. Sus
acciones construyen la representación interna que luego usa el intérprete.

### ¿Qué es un token?

Es una categoría léxica, como `TOK_HORA`. El texto concreto `09:30` es su
lexema y puede viajar como valor asociado.

### ¿Qué es el AST?

Es una representación interna simplificada del programa. En TurnoLang guarda el
nombre de la agenda y una lista tipada de sentencias, sin palabras de enlace ni
puntos y coma.

### ¿El AST era obligatorio?

No. Se eligió un AST mínimo porque hace clara la separación entre frontend y
backend y permite analizar el archivo antes de ejecutar, sin construir una
infraestructura innecesaria.

### ¿Qué es el análisis semántico?

Es la etapa que valida el significado: rangos horarios, orden del intervalo,
IDs activos, cancelaciones y superposiciones. Se realiza con funciones C sobre
cada sentencia y el estado actual.

### ¿Cuál es la diferencia entre error sintáctico y semántico?

Un error sintáctico viola la forma de la gramática, como omitir `;`. Uno
semántico tiene forma válida pero contradice el dominio, como reservar de
`11:00` a `10:00`.

### ¿Cómo se detecta una superposición?

Se convierten las horas a minutos y, para intervalos semiabiertos, se evalúa
`inicioNuevo < finExistente && finNuevo > inicioExistente`. La igualdad en un
borde permite reservas consecutivas.

### ¿Qué ocurre con un identificador cancelado?

Deja de estar activo y puede reutilizarse después. Intentar cancelarlo otra vez
falla porque ya no existe una reserva activa con ese identificador.

### ¿Cómo se separan validación y ejecución?

Para cada nodo, una función valida consultando el estado sin cambiarlo. Solo con
resultado válido otra función aplica el efecto o genera la consulta. Las reglas
compartidas, como la intersección, se implementan una sola vez.

### ¿Para qué sirve el Makefile?

Declara las dependencias y automatiza generación con Flex/Bison, compilación con
GCC, enlace, pruebas y limpieza. Permite repetir el proceso con comandos
conocidos.

### ¿Cómo se ejecutan las pruebas?

`make test` construirá primero el ejecutable y luego invocará un script que corre
cada `.tl`, captura salidas y código de retorno y los compara con resultados
esperados. Una prueba solo se considera aprobada después de esa comparación.

### ¿Por qué `LIBRE` ocupado no es un error?

Porque la instrucción es una consulta. Encontrar una reserva que interseca es un
resultado normal (`OCUPADO`), mientras que consultar un intervalo mal formado o
invertido sí es un error.

### ¿Cómo cumple el backend el requisito académico?

Consume la representación aceptada por el frontend, aplica su semántica en
orden, mantiene un estado y produce resultados observables. El requisito admite
evaluar instrucciones en lugar de generar código.

### Guion mental para una demostración

1. Mostrar una entrada breve y distinguir fuente de salida.
2. Seguir una reserva desde lexemas hasta AST.
3. Explicar una validación de intervalo y una de estado.
4. Ejecutar un caso válido.
5. Ejecutar un error léxico, uno sintáctico y uno semántico.
6. Mostrar `make test` y relacionar la evidencia con los requisitos.

No debe afirmarse que una característica está probada solo porque figura en esta
guía. La documentación describe el diseño; el repositorio, las ejecuciones y los
resultados comparados aportarán la evidencia técnica.
