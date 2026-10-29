# TurnoLang

TurnoLang es un lenguaje específico de dominio para describir operaciones sobre
la agenda diaria de un único recurso. El proyecto es un Trabajo Práctico
Integrador de Compiladores y busca mostrar, de forma pequeña y verificable, las
etapas de procesamiento de un lenguaje.

La versión actual corresponde al Sprint 2: implementa el frontend léxico y
sintáctico completo. Reconoce programas TurnoLang, pero todavía no construye un
AST, valida reglas de agenda ni ejecuta instrucciones.

## Instrucciones reconocidas

```text
AGENDA "Consultorio";
RESERVAR turno1 DESDE 09:00 HASTA 09:30;
LIBRE DESDE 10:00 HASTA 11:00;
CANCELAR turno1;
LISTAR;
```

`AGENDA` es una cabecera obligatoria y única. Después pueden aparecer cero o más
sentencias `RESERVAR`, `CANCELAR`, `LIBRE` o `LISTAR`.

## Tecnologías

- **C:** implementa el programa principal y la integración con el frontend.
- **Flex:** genera el scanner que transforma caracteres en tokens.
- **Bison:** genera el parser que comprueba la gramática.
- **GCC:** compila el código C propio y el generado.
- **GNU Make:** declara dependencias y automatiza generación, compilación,
  pruebas y limpieza.

## Arquitectura implementada

```text
Archivo .tl
    |
    v
Flex (src/lexer.l)
    |
    v
Tokens y valores textuales
    |
    v
Bison (src/parser.y)
    |
    v
Aceptación o diagnóstico del frontend
```

`src/main.c` abre el archivo y configura `yyin`. Luego llama a `yyparse`, la
función generada por Bison. Mientras analiza, `yyparse` solicita tokens a
`yylex`, la función generada por Flex. El código de retorno y la marca
`lexer_had_error` permiten distinguir una ejecución correcta de un fallo.

Las confirmaciones se escriben en `stdout`; los diagnósticos se escriben en
`stderr`.

## Análisis léxico con Flex

Un **token** es una categoría asignada a un lexema concreto. Por ejemplo,
`turno1` es un lexema de la categoría `TOK_IDENT`.

El archivo `src/lexer.l` reconoce:

| Categoría | Forma o lexema |
|---|---|
| Palabras reservadas | `AGENDA`, `RESERVAR`, `CANCELAR`, `DESDE`, `HASTA`, `LIBRE`, `LISTAR` |
| `TOK_IDENT` | `[A-Za-z_][A-Za-z0-9_]*` |
| `TOK_CADENA` | Texto entre comillas dobles, sin escapes ni saltos de línea |
| `TOK_HORA` | `[0-9]{2}:[0-9]{2}` |
| `TOK_PUNTO_Y_COMA` | `;` |

Las palabras reservadas son sensibles a mayúsculas. Por eso `RESERVAR` produce
el token reservado, mientras que `reservar` produce `TOK_IDENT`.

### Horarios mal formados

La regla de hora válida aparece antes de una regla amplia para candidatos
numéricos. Flex elige primero la coincidencia más larga y, ante igual longitud,
la regla escrita antes. Así:

- `25:70` tiene forma `HH:MM` y produce `TOK_HORA`; su rango se validará en el
  Sprint 3;
- `9:30`, `09:3`, `09-30` y `09:300` coinciden completos con la regla de error y
  se informan como horarios mal formados; y
- no se fragmentan silenciosamente en varios tokens.

El scanner también detecta cadenas sin cierre y cualquier carácter desconocido.
Todos los errores léxicos incluyen etapa, línea, motivo y fragmento encontrado.

### Propiedad de los valores

Flex reserva una copia dinámica para cadenas, identificadores y horarios. En una
reducción correcta, la acción correspondiente de Bison libera esos valores. Si
el parser descarta un token por un error, `%destructor` lo libera. En este sprint
los datos no se conservan porque el AST pertenece al Sprint 3.

## Análisis sintáctico con Bison

Una **producción gramatical** describe una estructura válida de tokens. Bison
implementa estas producciones:

```ebnf
programa       ::= cabecera sentencia* EOF ;
cabecera       ::= AGENDA CADENA ";" ;
sentencia      ::= reserva | cancelacion | disponibilidad | listado ;
reserva        ::= RESERVAR IDENT DESDE HORA HASTA HORA ";" ;
cancelacion    ::= CANCELAR IDENT ";" ;
disponibilidad ::= LIBRE DESDE HORA HASTA HORA ";" ;
listado        ::= LISTAR ";" ;
```

La repetición se representa en `src/parser.y` mediante una lista recursiva con
`%empty`. Reconocer una instrucción significa comprobar que sus tokens aparecen
en el orden de una producción; todavía no significa ejecutarla.

Por ejemplo:

```text
RESERVAR turno1 DESDE 09:00 HASTA 09:30;
```

Flex entrega:

```text
TOK_RESERVAR TOK_IDENT TOK_DESDE TOK_HORA
TOK_HASTA TOK_HORA TOK_PUNTO_Y_COMA
```

Bison comprueba que esa secuencia coincide con la producción `reserva` y libera
los valores textuales. No agrega una reserva a ninguna agenda.

## Sintaxis y semántica

Una construcción puede ser sintácticamente válida y semánticamente incorrecta.
El frontend acepta deliberadamente:

```text
AGENDA "";
RESERVAR turno1 DESDE 25:70 HASTA 10:00;
RESERVAR turno2 DESDE 11:00 HASTA 09:00;
```

Las tres respetan la forma del lenguaje. Nombre vacío, rango horario e intervalo
invertido se validarán en el Sprint 3. Este frontend tampoco detecta duplicados,
superposiciones ni cancelaciones inexistentes.

## Diagnósticos

Un error léxico se produce cuando un fragmento no puede convertirse en un token
válido:

```text
Error léxico en línea 3:
Horario mal formado: '9:30'.
```

Un error sintáctico se produce cuando los tokens existen, pero no respetan una
producción:

```text
Error sintáctico en línea 3:
La entrada no respeta la gramática (...).
```

El scanner conserva la línea del último token. Esto permite que una falta de
`;` al final del archivo se atribuya a la instrucción que quedó incompleta y no
a una línea vacía posterior. Un error léxico suprime el mensaje sintáctico
secundario para no mezclar etapas.

## Entorno verificado

La compilación y las pruebas se verificaron en Windows 11 con Git Bash y:

- Flex 2.6.4, provisto por winflexbison 2.5.25;
- GNU Bison 3.8.2;
- GCC 15.2.0;
- GNU Make 4.4.1; y
- GNU Bash 5.3.15.

No se declara compatibilidad con otros entornos hasta verificarlos.

### Instalación en el entorno verificado

1. Instalar [Git for Windows](https://gitforwindows.org/) para disponer de Git
   Bash.
2. Instalar [Scoop](https://scoop.sh/) siguiendo su documentación oficial.
3. Desde PowerShell, instalar las herramientas:

```powershell
scoop install gcc make winflexbison
```

4. Cerrar y volver a abrir Git Bash para que reciba el `PATH` actualizado.

Los comandos siguientes se ejecutan desde Git Bash, en la raíz del repositorio.

## Compilación

```bash
make
```

Make crea `build/` y `bin/` cuando son necesarios. Bison genera
`build/parser.c` y `build/parser.h`; Flex genera `build/lexer.c`; GCC compila
esos archivos y `src/main.c`, y enlaza `bin/turnolang.exe`.

La dependencia de `build/lexer.c` respecto de `build/parser.h` garantiza que
Bison defina los tokens antes de generar y compilar el scanner. Una segunda
ejecución de `make` sin cambios no reconstruye archivos.

## Ejecución

```bash
./bin/turnolang examples/frontend/ok_todas_instrucciones.tl
```

Salida esperada:

```text
TurnoLang
Análisis léxico y sintáctico: correcto.
Semántica e interpretación: pendientes.
```

## Pruebas

```bash
make test
```

El objetivo ejecuta dos scripts:

- `scripts/test_smoke.sh` mantiene las cinco regresiones del Sprint 1; y
- `scripts/test_frontend.sh` comprueba veintiún escenarios del Sprint 2.

Las pruebas capturan `stdout` y `stderr`, verifican códigos de salida,
clasificación y líneas. Cubren programas válidos, errores de horario, símbolo y
cadena, errores de estructura y entradas semánticamente inválidas que todavía
deben aceptarse.

Los archivos se encuentran en `examples/frontend/`.

## Limpieza

```bash
make clean
```

Elimina únicamente `build/` y `bin/`, que contienen generados, objetos y el
ejecutable. No elimina fuentes, ejemplos, scripts ni documentación.

## Estado

Implementado y verificado hasta Sprint 2:

- scanner Flex completo;
- parser Bison para toda la gramática;
- clasificación básica de errores léxicos y sintácticos;
- manejo de valores textuales y descarte seguro;
- compilación limpia, incremental y paralela con Make; y
- 26 pruebas automatizadas acumuladas.

Pendiente para sprints posteriores:

- AST mínimo del programa;
- análisis semántico de nombres, horarios e intervalos;
- estado de reservas y reglas de superposición;
- intérprete y resultados de agenda; y
- batería integral final e informe LNCS.

La especificación técnica completa está en
[`docs/PROPUESTA_ROADMAP.md`](docs/PROPUESTA_ROADMAP.md) y la explicación de los
conceptos en [`docs/GUIA_ESTUDIO.md`](docs/GUIA_ESTUDIO.md).
