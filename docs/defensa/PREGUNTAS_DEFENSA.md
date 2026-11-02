# Preguntas probables de defensa

## Conceptos fundamentales

### ¿Qué es un compilador y qué es un intérprete?

Un compilador traduce un programa a otra representación antes de ejecutarlo;
un intérprete recorre una representación del programa y produce sus efectos.
TurnoLang genera y compila su procesador en C, pero el backend interpreta el AST
de cada archivo `.tl`.

### ¿Qué es el frontend y qué es el backend?

El frontend reconoce el texto, valida su gramática y construye el AST. El
backend comprueba reglas contextuales y ejecuta las instrucciones sobre la
agenda.

### ¿Qué es Flex?

Es un generador de analizadores léxicos. A partir de patrones y acciones de
`src/lexer.l`, genera el scanner que devuelve tokens a Bison.

### ¿Qué diferencia hay entre token y lexema?

El lexema es el texto concreto, por ejemplo `RESERVAR` o `09:30`. El token es su
categoría, por ejemplo `TOK_RESERVAR` o `TOK_HORA`.

### ¿Qué es Bison?

Es un generador de parsers. Lee las producciones de `src/parser.y`, comprueba la
secuencia de tokens y ejecuta acciones C que construyen nodos del AST.

### ¿Qué es una gramática y qué es una producción?

La gramática define las formas válidas del lenguaje. Una producción es una
regla concreta, como `listado ::= LISTAR ";"`, que indica cómo puede formarse
una construcción.

### ¿Qué es un AST?

Es una representación estructurada que conserva el significado útil y omite
puntuación innecesaria. En TurnoLang es una lista tipada de instrucciones con
datos, línea y orden fuente.

### ¿Qué es el análisis semántico?

Es la fase que valida reglas que la gramática no decide por sí sola, como rango
de horas, orden del intervalo, identificadores activos y superposiciones.

### ¿Cómo se distinguen errores léxicos, sintácticos y semánticos?

El léxico contiene un lexema no reconocido o mal formado; el sintáctico usa
tokens reconocibles en un orden inválido; el semántico tiene forma correcta,
pero viola una regla contextual del dominio.

## Diseño del lenguaje

### ¿Por qué un DSL y no una aplicación convencional?

Porque el objetivo académico es hacer explícitas las fases de procesamiento de
un lenguaje. El dominio de turnos ofrece reglas contextuales pequeñas —rango,
orden, superposición y cancelación— que permiten distinguir sintaxis de
semántica sin introducir infraestructura ajena al curso.

### ¿Por qué `25:70` puede ser sintácticamente válido?

El scanner comprueba la forma `HH:MM`; la semántica comprueba los valores. Esa
separación evita mezclar reconocimiento de lexemas con reglas del dominio y
permite demostrar responsabilidades diferentes.

### ¿Qué significa que los intervalos sean semiabiertos?

Una reserva ocupa `[inicio, fin)`: incluye el comienzo y excluye el final. Por
eso 09:00–09:30 y 09:30–10:00 son consecutivas, no superpuestas.

## Arquitectura e implementación

### ¿Por qué construir un AST si el lenguaje es pequeño?

Desacopla el frontend del backend, evita ejecutar acciones durante el parseo y
conserva una representación tipada con línea de origen. También permite que los
modos de sintaxis, semántica e interpretación compartan el mismo frontend.

### ¿Cómo evitan validar dos veces?

`semantica_procesar_programa` realiza un único recorrido. Para cada nodo valida,
aplica el cambio y llama a un observador opcional. El modo semántico no instala
observador; el intérprete sí, para imprimir `LIBRE` y `LISTAR`.

### ¿Por qué `LISTAR` usa un arreglo temporal?

La agenda conserva una lista privada adecuada para altas y cancelaciones. Para
mostrar orden cronológico crea vistas de reservas activas, las ordena y las
libera. El intérprete no accede a la representación interna.

### ¿Qué ocurre ante un error tardío del frontend?

No se ejecuta ninguna instrucción. El AST se interpreta solo después de que el
archivo completo fue aceptado. Así no hay efectos parciales causados por un
programa léxica o sintácticamente inválido.

### ¿Cómo manejan la memoria?

Flex crea los textos y el AST toma su propiedad. La agenda copia
identificadores. Los destructores de Bison liberan símbolos descartados y las
rutas normales o de error liberan agenda, AST, scanner y archivo. La revisión
estática fue satisfactoria, pero falta una ejecución dinámica en Linux.

## Pruebas y alcance

### ¿Qué significa 68/68?

Son 68 comprobaciones automatizadas distribuidas en 5 de proceso, 23 de
frontend, 21 semánticas, 15 funcionales y 4 de calidad. Es evidencia concreta
del comportamiento cubierto, no una prueba formal ni cobertura total del
espacio de entradas.

### ¿Cómo saben que el runner detecta errores?

Una prueba de calidad copia un oráculo, lo altera en un directorio temporal y
confirma que el comparador rechaza la diferencia. El oráculo versionado no se
modifica.

### ¿Por qué no hay base de datos, fechas o varios recursos?

Están fuera del alcance declarado. Incorporarlos cambiaría el modelo semántico
y distraería del objetivo de implementar y explicar la cadena del lenguaje.

### ¿Qué mejorarían primero?

Completarían validación dinámica de memoria con Valgrind o sanitizers en Linux.
Como extensión funcional, diseñarían fechas y múltiples recursos antes de
persistencia, manteniendo explícitas las nuevas reglas semánticas.

## Entrega académica

### ¿El informe ya es definitivo?

No. Está compilado y revisado técnicamente, pero conserva marcadores explícitos
porque los nombres, institución, correos y ORCID no fueron proporcionados. La
defensa también requiere un ensayo humano cronometrado.
