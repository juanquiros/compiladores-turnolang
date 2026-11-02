# Resultados técnicos de TurnoLang

Documento interno de evidencia para el futuro informe académico. No reemplaza
el informe LNCS ni declara completada la defensa.

## Contexto de la verificación

- **Fecha:** 2 de noviembre de 2026.
- **Sistema principal:** Windows 11, NT 10.0.26200.0.
- **Shell:** GNU Bash 5.3.15 de Git for Windows.
- **Flex:** 2.6.4 (`winflexbison` 2.5.25).
- **Bison:** 3.8.2.
- **GCC:** 15.2.0 para MinGW-w64.
- **GNU Make:** 4.4.1.
- **Arquitectura:** archivo → Flex → Bison → AST → semántica → intérprete.

La línea base del Sprint 4 se ejecutó antes de modificar archivos: compilación
normal sin advertencias relevantes y 64 de 64 escenarios aprobados.

## Gramática verificada

```ebnf
programa       ::= cabecera sentencia* EOF ;
cabecera       ::= AGENDA CADENA ";" ;
sentencia      ::= reserva | cancelacion | disponibilidad | listado ;
reserva        ::= RESERVAR IDENT DESDE HORA HASTA HORA ";" ;
cancelacion    ::= CANCELAR IDENT ";" ;
disponibilidad ::= LIBRE DESDE HORA HASTA HORA ";" ;
listado        ::= LISTAR ";" ;
```

Flex reconoce palabras reservadas, identificadores, cadenas, horarios y `;`.
Bison valida la estructura y construye una lista AST tipada. El motor semántico
valida y aplica cada instrucción una vez; el intérprete observa ese recorrido
para producir resultados.

## Resultado integral

| Etapa | Pruebas | Aprobadas | Fallidas |
|---|---:|---:|---:|
| Sprint 1 — Smoke y proceso | 5 | 5 | 0 |
| Sprint 2 — Frontend | 23 | 23 | 0 |
| Sprint 3 — Semántica | 21 | 21 | 0 |
| Sprint 4 — Intérprete | 15 | 15 | 0 |
| Sprint 5 — Calidad | 4 | 4 | 0 |
| **Total** | **68** | **68** | **0** |

Las cuatro comprobaciones nuevas cubren:

1. archivo completamente vacío;
2. archivo válido sin salto de línea final;
3. ruta de entrada con espacios; y
4. detección controlada de un oráculo alterado.

La matriz detallada se mantiene en [`MATRIZ_PRUEBAS.md`](MATRIZ_PRUEBAS.md).

## Fortalecimiento del runner

`make test` ejecuta `scripts/test_all.sh`, que conserva y coordina los scripts
de cada sprint. El resumen se calcula contando aprobaciones emitidas por cada
suite y se contrasta con la cantidad declarada. Cualquier script con código no
cero, cantidad incompleta o comparación fallida hace fallar el objetivo Make.

Las mejoras específicas fueron:

- códigos `0` y `1` leídos desde oráculos versionados;
- salidas académicas válidas comparadas completas, no por una subcadena;
- errores de frontend limitados a tres líneas, etapa única y `stdout` vacío;
- errores semánticos con salida académica exacta, diagnóstico de tres líneas,
  etapa, línea y motivo;
- salidas del intérprete comparadas completas como antes; y
- canonización exclusiva de `CRLF`/`LF` para ejecutar binarios Windows desde
  Git Bash.
- política `.gitattributes` con `LF` estable para scripts, fuentes y oráculos.

Para verificar el propio runner, `test_calidad.sh` copia el oráculo correcto a
un directorio temporal, agrega una línea intencional y confirma que `cmp`
rechaza la comparación. El oráculo versionado no se modifica.

## Compilación y reproducibilidad

Los procedimientos comprobados son:

```bash
make clean
make
make test
make

make clean
make -j2
make test
```

La primera construcción genera parser, scanner, objetos y ejecutable. La
segunda invocación de `make` no reconstruye archivos innecesarios. La limpieza
elimina únicamente `build/` y `bin/`. La construcción paralela respeta la
dependencia del scanner respecto del encabezado de Bison.

El sistema reproducible verificado es Windows 11 con Git Bash y herramientas de
Scoop. PowerShell por sí solo no proporciona `rm` y `mkdir` POSIX para las
recetas del Makefile.

## Verificación de memoria

### Herramientas investigadas

| Herramienta | Resultado real |
|---|---|
| Valgrind | No instalado en Windows/Git Bash. |
| AddressSanitizer/UBSan de MinGW | Los objetos compilan, pero el enlace falla porque no existen `libasan` ni `libubsan`. |
| WSL Ubuntu | No instalado; solo existe la distribución interna `docker-desktop`. |
| Docker Linux | Cliente instalado, motor detenido y sin API disponible. |
| GCC `-fanalyzer` | Ejecutado sobre módulos propios y generados. |

Comando sanitizer intentado:

```bash
make clean
make \
  CFLAGS="-std=c11 -Wall -Wextra -Wpedantic -g -O1 -fsanitize=address,undefined -fno-omit-frame-pointer" \
  LDFLAGS="-fsanitize=address,undefined"
```

El enlazador informó `cannot find -lasan` y `cannot find -lubsan`; por eso no se
ejecutó una batería instrumentada.

Comando estático ejecutado:

```bash
make clean
make CFLAGS="-std=c11 -Wall -Wextra -Wpedantic -fanalyzer"
```

Terminó con código cero. Los módulos propios (`main`, `ast`, `agenda`,
`semantica` e `interprete`) no emitieron advertencias del analizador. Se
registraron cuatro clases de advertencia, cinco apariciones, únicamente en el
código generado por Flex/Bison:

- pila dinámica de Bison reportada como posible fuga y valor no inicializado;
- reasignación del búfer de Flex reportada como posible fuga ante OOM; y
- posible puntero nulo en una ruta de inicialización de Flex.

La inspección del generado confirmó que Bison libera la pila dinámica en su
etiqueta común de retorno y que Flex termina el proceso mediante
`YY_FATAL_ERROR` en los caminos de asignación fallida. No se editaron los
archivos generados ni se ocultaron las advertencias.

### Revisión de propiedad

| Recurso | Propietario y liberación |
|---|---|
| Textos de Flex | Se transfieren al AST; `%destructor` cubre descartes. |
| Programa y nodos AST | `main` libera el símbolo inicial aceptado una vez. |
| Listas parciales de Bison | `%destructor` llama a las rutinas del AST. |
| Identificadores de agenda | La agenda crea copias y libera nodos activos e inactivos. |
| Vistas ordenadas | Referencian IDs de agenda; solo el arreglo temporal se libera. |
| Scanner y archivo | `yylex_destroy` y `fclose` se ejecutan antes del backend. |
| Error semántico anticipado | El motor libera la agenda y `main` libera el AST. |

Las pruebas ejercitan éxito, errores léxicos y sintácticos tardíos, errores
semánticos después de efectos, cancelaciones y múltiples listados. Permanece la
limitación de no haber ejecutado una herramienta dinámica de memoria en Linux.

La redirección a `/dev/full` de Git Bash tampoco permite verificar de forma
fiable errores de escritura de un ejecutable nativo Windows; no se atribuye esa
prueba como aprobada.

## Matriz de cumplimiento académico

| Requisito | Implementación | Verificación | Evidencia |
|---|---|---|---|
| Problema y alcance del lenguaje | Implementado | Verificado documentalmente | `PROPUESTA_ROADMAP.md`, README |
| Sintaxis y gramática | Implementado | Verificado con casos válidos/inválidos | `parser.y`, 23 casos frontend |
| Análisis léxico con Flex | Implementado | Verificado | `lexer.l`, errores léxicos y líneas |
| Análisis sintáctico con Bison | Implementado | Verificado | `parser.y`, generación sin conflictos |
| Análisis semántico | Implementado | Verificado | 21 casos semánticos |
| AST y relación Bison–C | Implementado | Verificado por recorridos y errores tardíos | `ast.*`, `parser.y` |
| Backend funcional | Implementado | Verificado | 15 casos del intérprete |
| Diagnósticos claros | Implementado | Verificado | etapa, línea, motivo y códigos |
| Makefile reproducible | Implementado | Verificado en Windows/Git Bash | normal, incremental y paralelo |
| Runner integral | Implementado | Verificado con 68 casos y falla inducida | `test_all.sh`, `test_calidad.sh` |
| Revisión de memoria | Implementado según herramientas disponibles | Parcial: estática y manual; dinámica pendiente por entorno | esta sección |
| README de instalación y uso | Implementado | Verificado contra comandos del Sprint 5 | README |
| Informe LNCS y referencias | Pendiente | No iniciado | Sprint 6 / TL-028 |
| Demostración y defensa | Pendiente | No iniciada | Sprint 6 / TL-029 |
| Revisión final de trazabilidad | Pendiente | No iniciada | Sprint 6 / TL-030 |

## Limitaciones y riesgos para la entrega

- Falta una ejecución dinámica de memoria en un Linux con Valgrind o ASan.
- El entorno principal requiere Git Bash; ejecutar recetas directamente desde
  PowerShell falla si no dispone de utilidades POSIX.
- El informe LNCS, referencias bibliográficas, figuras y ensayo de defensa
  pertenecen al Sprint 6 y permanecen pendientes.

No existen dependencias de base de datos, red, GUI ni bibliotecas externas.
