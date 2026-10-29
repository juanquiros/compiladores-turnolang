# TurnoLang

TurnoLang es un lenguaje específico de dominio para describir operaciones sobre
la agenda diaria de un único recurso. Es un Trabajo Práctico Integrador de
Compiladores y permite observar, en un proyecto acotado, las etapas que procesan
un lenguaje.

La versión actual corresponde al Sprint 3. Implementa el frontend completo,
construye un AST y valida el significado de las instrucciones contra un estado
temporal de agenda. Todavía no ejecuta el backend visible: no muestra reservas,
disponibilidad ni listados.

## Instrucciones reconocidas

```text
AGENDA "Consultorio";
RESERVAR turno1 DESDE 09:00 HASTA 09:30;
LIBRE DESDE 10:00 HASTA 11:00;
CANCELAR turno1;
LISTAR;
```

`AGENDA` es obligatoria y única. Después pueden aparecer cero o más sentencias
`RESERVAR`, `CANCELAR`, `LIBRE` o `LISTAR`.

## Tecnologías

- **C:** implementa AST, estado de agenda, semántica y programa principal.
- **Flex:** genera el scanner que transforma caracteres en tokens.
- **Bison:** genera el parser que comprueba la gramática y construye el AST.
- **GCC:** compila el código propio y el generado.
- **GNU Make:** automatiza generación, compilación, pruebas y limpieza.

## Arquitectura implementada

```text
Archivo .tl
    ↓
Flex / lexer.l
    ↓ tokens y valores
Bison / parser.y
    ↓
AST mínimo
    ↓
Análisis semántico
    ↓
Programa válido o diagnóstico
```

`main.c` abre el archivo y llama a `yyparse`. Bison solicita tokens a `yylex` y,
si acepta todo el archivo, entrega `programa_analizado`. En modo normal, `main`
envía ese AST a `semantica_validar_programa`. En todos los caminos se liberan
scanner, archivo, AST y estado temporal.

Las confirmaciones se escriben en `stdout`; los errores, en `stderr`.

## Análisis léxico con Flex

Un **token** es la categoría asignada a un lexema. Por ejemplo, `turno1` es un
lexema de la categoría `TOK_IDENT`.

`src/lexer.l` reconoce:

| Categoría | Forma o lexema |
|---|---|
| Palabras reservadas | `AGENDA`, `RESERVAR`, `CANCELAR`, `DESDE`, `HASTA`, `LIBRE`, `LISTAR` |
| `TOK_IDENT` | `[A-Za-z_][A-Za-z0-9_]*` |
| `TOK_CADENA` | Texto entre comillas, sin escapes ni saltos de línea |
| `TOK_HORA` | `[0-9]{2}:[0-9]{2}` |
| `TOK_PUNTO_Y_COMA` | `;` |

Las reservadas distinguen mayúsculas. `RESERVAR` produce el token reservado;
`reservar` es un identificador y será rechazado sintácticamente si aparece donde
se espera una instrucción.

La regla de `HH:MM` aparece antes de un candidato numérico amplio. Por la
coincidencia más larga de Flex, `9:30`, `09:3`, `09-30` y `09:300` se informan
completos como errores léxicos. `25:70` sí produce `TOK_HORA`: tiene la forma
correcta y su rango se rechaza después, durante la semántica.

Con `%locations`, cada token entrega su línea a Bison. No se siguen columnas
porque no son necesarias para los diagnósticos actuales.

## Análisis sintáctico con Bison

Una **producción gramatical** describe una estructura válida de tokens. Bison
implementa:

```ebnf
programa       ::= cabecera sentencia* EOF ;
cabecera       ::= AGENDA CADENA ";" ;
sentencia      ::= reserva | cancelacion | disponibilidad | listado ;
reserva        ::= RESERVAR IDENT DESDE HORA HASTA HORA ";" ;
cancelacion    ::= CANCELAR IDENT ";" ;
disponibilidad ::= LIBRE DESDE HORA HASTA HORA ";" ;
listado        ::= LISTAR ";" ;
```

La repetición usa una lista recursiva con `%empty`. Las acciones no validan
reglas de agenda: crean nodos del AST y transfieren los textos producidos por
Flex.

## AST mínimo

AST significa **árbol de sintaxis abstracta**. En TurnoLang se implementa como
un programa y una lista enlazada de instrucciones; no se necesita una jerarquía
genérica de árboles.

`src/ast.h` define:

- `Programa`: nombre, línea de `AGENDA` y lista en orden;
- `TipoInstruccion`: reserva, cancelación, disponibilidad o listado;
- `Instruccion`: tipo, línea, unión con sus datos y enlace siguiente; y
- `ListaInstrucciones`: punteros al primer y último nodo.

Ejemplo conceptual:

```text
Instruccion
├── tipo: INSTRUCCION_RESERVA
├── linea: 3
├── identificador: "turno1"
├── inicio: "09:00"
└── fin: "09:30"
```

Mantener el último nodo permite agregar instrucciones sin invertir el orden ni
recorrer nuevamente la lista.

## Estado interno de agenda

`src/agenda.c` mantiene una lista de reservas con identificador, minutos de
inicio/fin y marca activa. Este estado existe únicamente durante el análisis
semántico.

Las operaciones disponibles son:

- buscar una reserva activa por identificador;
- agregar una reserva ya validada;
- cancelar una reserva activa;
- buscar una intersección; y
- liberar todo el estado.

Una reserva cancelada permanece inactiva en el estado, por lo que el mismo ID
puede usarse después en una reserva nueva. No hay persistencia ni salida
funcional.

## Análisis semántico

`src/semantica.c` recorre el AST en orden. Para cada nodo primero ejecuta una
validación que no modifica la agenda; solo si es correcta aplica el cambio
temporal necesario para validar instrucciones posteriores.

### Horas e intervalos

Una hora se convierte mediante:

```text
minutos = HH × 60 + MM
```

Se exige `00 ≤ HH ≤ 23`, `00 ≤ MM ≤ 59` e `inicio < fin`. Se distinguen hora
fuera de rango, intervalo vacío e intervalo invertido.

### Identificadores y cancelaciones

- reservar un ID activo es error;
- cancelar exige una reserva activa; y
- después de cancelar, el ID puede reutilizarse.

### Superposición

Los intervalos son semiabiertos `[inicio, fin)`. La única función de
intersección evalúa:

```c
inicio_nuevo < fin_existente && fin_nuevo > inicio_existente
```

Detecta cruces parciales y contención. Dos reservas consecutivas son válidas.
`LIBRE` reutiliza la consulta de intersección, pero un intervalo ocupado no es
error semántico: el resultado `OCUPADO` se mostrará recién en Sprint 4.

### Nombre de agenda

Una cadena vacía es sintácticamente válida, pero el análisis semántico rechaza
`AGENDA "";`.

## Ejemplo de punta a punta

Para:

```text
RESERVAR turno1 DESDE 09:00 HASTA 09:30;
```

1. Flex produce `TOK_RESERVAR`, `TOK_IDENT`, `TOK_DESDE`, dos `TOK_HORA`,
   `TOK_HASTA` y `TOK_PUNTO_Y_COMA`.
2. Bison reduce la producción `reserva`.
3. La acción transfiere ID y horas a un nodo con la línea de `RESERVAR`.
4. Semántica convierte `09:00` y `09:30` a 540 y 570 minutos.
5. Comprueba que el intervalo esté ordenado.
6. Busca un ID activo y una reserva superpuesta.
7. Si todo es válido, incorpora la reserva al estado temporal.

El último paso permite validar sentencias posteriores; todavía no imprime una
confirmación ni constituye la ejecución visible del intérprete.

## Propiedad y liberación de memoria

- Flex reserva cadenas, identificadores y horarios.
- Un nodo AST toma su propiedad cuando el constructor tiene éxito.
- `%destructor` libera tokens, instrucciones o listas descartados por Bison.
- El símbolo inicial aceptado se transfiere a `programa_analizado` y `main` lo
  libera exactamente una vez.
- La agenda copia los identificadores que necesita y libera sus reservas al
  terminar la validación.
- `yylex_destroy` libera los buffers internos del scanner.

Las pruebas incluyen errores después de construir una lista AST no vacía para
ejercitar los destructores. El entorno MinGW verificado no incluye Valgrind ni
AddressSanitizer; se realizó revisión de propiedad y pruebas de rutas de éxito y
error.

## Modos de ejecución

### Análisis completo

```bash
./bin/turnolang examples/semantica/ok_programa.tl
```

Salida:

```text
TurnoLang
Análisis léxico y sintáctico: correcto.
Análisis semántico: correcto.
Interpretación: pendiente.
```

### Solo sintaxis

```bash
./bin/turnolang --solo-sintaxis examples/frontend/ok_hora_fuera_rango.tl
```

Construye y libera el AST, pero omite semántica. Este modo conserva las pruebas
del frontend y demuestra que `25:70` es una hora léxica/sintácticamente válida.

## Diagnósticos

Los errores informan etapa, línea y motivo. Por ejemplo:

```text
Error semántico en línea 5:
La reserva 'turno2' se superpone con 'turno1'.
```

El primer error relevante detiene el procesamiento. Un error léxico no genera
además un mensaje sintáctico, y la semántica no comienza si falló el frontend.

## Entorno verificado

La compilación y las pruebas se verificaron en Windows 11 con Git Bash y:

- Flex 2.6.4, provisto por winflexbison 2.5.25;
- GNU Bison 3.8.2;
- GCC 15.2.0;
- GNU Make 4.4.1; y
- GNU Bash 5.3.15.

No se declara compatibilidad con otros entornos hasta verificarlos.

### Instalación

Instalar Git for Windows y Scoop. Desde PowerShell:

```powershell
scoop install gcc make winflexbison
```

Cerrar y abrir Git Bash antes de ejecutar los comandos siguientes.

## Compilación

```bash
make
```

Bison genera `build/parser.c` y `build/parser.h`; Flex genera
`build/lexer.c`; GCC compila módulos propios y generados y enlaza
`bin/turnolang.exe`. Las dependencias admiten construcción incremental y
paralela.

## Pruebas

```bash
make test
```

Se ejecutan:

- 5 pruebas smoke del Sprint 1;
- 23 pruebas del frontend en modo `--solo-sintaxis`; y
- 21 pruebas semánticas del Sprint 3.

Las 49 pruebas acumuladas comprueban códigos, flujos separados, etapa, línea,
motivo, aceptación válida y ausencia de resultados funcionales adelantados.

## Limpieza

```bash
make clean
```

Elimina solo `build/` y `bin/`. No elimina fuentes, ejemplos, scripts ni
documentación.

## Estado

Implementado y verificado hasta Sprint 3:

- scanner y parser completos;
- AST mínimo ordenado con ubicaciones;
- estado temporal de reservas;
- horas, intervalos, IDs, cancelaciones y superposiciones;
- diagnósticos léxicos, sintácticos y semánticos; y
- pruebas acumuladas de los tres sprints técnicos.

Pendiente para Sprint 4:

- ejecución secuencial visible;
- confirmaciones de reserva y cancelación;
- resultados `DISPONIBLE`/`OCUPADO`;
- listado ordenado de reservas activas; y
- contrato final de salidas y códigos.

La especificación completa está en
[`docs/PROPUESTA_ROADMAP.md`](docs/PROPUESTA_ROADMAP.md) y la guía conceptual en
[`docs/GUIA_ESTUDIO.md`](docs/GUIA_ESTUDIO.md).
