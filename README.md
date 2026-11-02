# TurnoLang

TurnoLang es un lenguaje específico de dominio para administrar las reservas de
un único recurso durante un único día. El proyecto corresponde al Trabajo
Práctico Integrador de Compiladores y muestra el procesamiento completo de un
lenguaje: scanner, parser, AST, semántica e interpretación.

La versión actual corresponde al Sprint 4. Ejecuta reservas y cancelaciones,
consulta disponibilidad y lista las reservas activas en orden cronológico. El
estado existe solo durante la ejecución: no hay base de datos ni persistencia.

## Lenguaje

Cada programa declara exactamente una agenda y puede contener cero o más
instrucciones:

```text
AGENDA "Consultorio";

RESERVAR turno1 DESDE 09:00 HASTA 09:30;
LIBRE DESDE 09:15 HASTA 09:45;
CANCELAR turno1;
LISTAR;
```

| Instrucción | Comportamiento |
|---|---|
| `AGENDA "nombre";` | Define el nombre no vacío de la agenda. |
| `RESERVAR id DESDE HH:MM HASTA HH:MM;` | Registra una reserva válida y no superpuesta. |
| `CANCELAR id;` | Desactiva una reserva activa. El identificador puede reutilizarse. |
| `LIBRE DESDE HH:MM HASTA HH:MM;` | Informa si el intervalo completo está disponible, sin cambiar el estado. |
| `LISTAR;` | Muestra las reservas activas ordenadas por hora de inicio. |

Las palabras reservadas distinguen mayúsculas y minúsculas. Las horas deben
tener forma exacta `HH:MM`; sus valores se validan semánticamente entre `00:00`
y `23:59`. Los intervalos son semiabiertos `[inicio, fin)`, por lo que dos
reservas consecutivas son válidas.

## Arquitectura

```text
Archivo .tl
    ↓
Flex / lexer.l
    ↓ tokens, valores y líneas
Bison / parser.y
    ↓
AST mínimo y ordenado
    ↓
Motor semántico: validar → aplicar
    ↓
Intérprete: producir resultado
    ↓
stdout o diagnóstico en stderr
```

| Componente | Responsabilidad |
|---|---|
| `src/lexer.l` | Reconoce lexemas y clasifica errores léxicos. |
| `src/parser.y` | Comprueba la gramática y construye el AST. |
| `src/ast.c` | Conserva tipo, datos, línea y orden de cada instrucción. |
| `src/agenda.c` | Mantiene la única lista de reservas y la intersección de intervalos. |
| `src/semantica.c` | Recorre, valida y aplica cada nodo contra el estado actual. |
| `src/interprete.c` | Observa las instrucciones ya aplicadas y genera `LIBRE` o `LISTAR`. |
| `src/main.c` | Selecciona el modo, coordina fases, códigos y liberación. |

### Un solo recorrido de backend

`semantica_procesar_programa` implementa el recorrido compartido. Para cada
instrucción:

1. `validar_sentencia` consulta el estado sin modificarlo;
2. ante error, informa la línea y detiene el programa;
3. `aplicar_sentencia` modifica la agenda solo si la validación fue correcta;
4. un observador opcional genera el resultado visible; y
5. continúa con el siguiente nodo.

El modo semántico llama al mismo motor sin observador. El intérprete instala un
observador para las salidas, de modo que no vuelve a validar, no recorre dos
veces el AST y no mantiene una segunda agenda.

### Estado y listado

La estructura `ReservaAgenda` permanece privada. Para `LISTAR`, `agenda.c`
construye un arreglo temporal de vistas de las reservas activas, lo ordena por
inicio y, como desempate defensivo, por identificador. El intérprete imprime las
vistas y libera el arreglo. Las reservas canceladas permanecen inactivas en la
lista y no aparecen ni ocupan intervalos.

## Recorrido completo de una reserva

Para:

```text
RESERVAR turno1 DESDE 09:00 HASTA 09:30;
```

1. Flex produce los tokens `TOK_RESERVAR`, `TOK_IDENT`, `TOK_DESDE`, dos
   `TOK_HORA`, `TOK_HASTA` y `TOK_PUNTO_Y_COMA`.
2. Bison reconoce la producción `reserva`.
3. La acción crea un nodo AST con ID, horas y línea de origen.
4. El motor semántico convierte las horas a 540 y 570 minutos.
5. Valida rango, orden, identificador activo y superposición.
6. La agenda copia el identificador y registra la reserva activa.
7. Una instrucción `LISTAR` posterior permite observar el resultado.

Esta separación permite distinguir análisis léxico, análisis sintáctico,
representación interna, análisis semántico e interpretación.

## Contrato de salida

En interpretación completa, `stdout` contiene exclusivamente resultados del
lenguaje. `RESERVAR` y `CANCELAR` no imprimen confirmaciones.

Disponibilidad:

```text
Franja 09:30-10:00: DISPONIBLE
Franja 09:15-09:45: OCUPADO
```

Listado:

```text
Agenda: Consultorio
09:00-09:30  turno1
10:00-10:30  turno2
```

Agenda vacía:

```text
Agenda: Consultorio
(sin reservas)
```

Los errores se escriben en `stderr` y producen código distinto de cero. Si el
frontend falla, no se inicia el backend. Ante el primer error semántico, la
instrucción rechazada y las posteriores no se ejecutan; las salidas generadas
por instrucciones anteriores se conservan.

## Modos de ejecución

### Interpretación completa

```bash
./bin/turnolang examples/interprete/ok_completo.tl
```

Salida real:

```text
Franja 09:15-09:45: OCUPADO
Franja 09:00-09:30: DISPONIBLE
Agenda: Consultorio Integral
08:00-08:30  turno3
10:00-10:30  turno2
```

### Solo semántica

```bash
./bin/turnolang --solo-semantica examples/semantica/ok_programa.tl
```

Construye el AST y utiliza el mismo motor para validar y actualizar su agenda
temporal, pero no genera resultados funcionales:

```text
TurnoLang
Análisis léxico y sintáctico: correcto.
Análisis semántico: correcto.
```

### Solo sintaxis

```bash
./bin/turnolang --solo-sintaxis examples/frontend/ok_hora_fuera_rango.tl
```

Ejecuta Flex, Bison, construcción y liberación del AST, pero omite semántica e
interpretación. Este modo permite comprobar que `25:70` es léxica y
sintácticamente correcto aunque su valor sea semánticamente inválido.

## Diagnósticos

Los diagnósticos indican etapa, línea y motivo:

```text
Error semántico en línea 5:
La reserva 'turno2' se superpone con 'turno1'.
```

Un error léxico no produce además un error sintáctico. Los errores léxicos o
sintácticos tardíos impiden toda salida de agenda porque el AST solo se ejecuta
después de aceptar el archivo completo.

## Propiedad y liberación de memoria

- Flex reserva textos; los nodos AST toman su propiedad al construirse.
- Los `%destructor` de Bison liberan tokens, nodos o listas descartados.
- `programa_analizado` se transfiere a `main` y se libera exactamente una vez.
- La agenda copia los identificadores y libera todos sus nodos al terminar.
- El arreglo temporal de `LISTAR` contiene referencias, no copias, y se libera
  antes de abandonar la instrucción.
- En errores semánticos y fallos internos, el motor libera la agenda; `main`
  libera AST, scanner y archivo.

El entorno MinGW verificado no dispone de Valgrind ni AddressSanitizer. Se
revisó el contrato de propiedad y se ejercitaron rutas normales, errores del
frontend después de nodos válidos y finalización semántica anticipada.

## Entorno verificado

Windows 11 con Git Bash y:

- Flex 2.6.4 (`winflexbison` 2.5.25);
- GNU Bison 3.8.2;
- GCC 15.2.0;
- GNU Make 4.4.1; y
- GNU Bash 5.3.15.

Desde PowerShell se pueden instalar las herramientas con:

```powershell
scoop install gcc make winflexbison
```

Los comandos de construcción deben ejecutarse desde Git Bash, porque el
Makefile usa utilidades POSIX como `rm` y `mkdir`.

## Compilación

```bash
make
```

Bison y Flex generan sus fuentes en `build/`; GCC enlaza
`bin/turnolang.exe`. El grafo de dependencias admite compilación incremental y
paralela.

## Pruebas

```bash
make test
```

Se ejecutan 64 escenarios:

- 5 pruebas smoke del Sprint 1;
- 23 pruebas del frontend con `--solo-sintaxis`;
- 21 pruebas semánticas con `--solo-semantica`; y
- 15 pruebas funcionales del intérprete.

Las pruebas del intérprete comparan código, `stdout` y `stderr` completos contra
oráculos versionados. También comprueban orden, cancelación, reutilización,
agenda vacía, salidas previas a error, bloqueo del backend ante fallos de
frontend y repetibilidad. El runner normaliza únicamente `CRLF`/`LF` para que la
comparación sea reproducible entre el ejecutable de Windows y Git.

## Limpieza

```bash
make clean
```

Elimina solo `build/` y `bin/`; no borra fuentes, ejemplos, scripts ni
documentación.

## Estado

Los Sprints 0 a 4 y las tareas TL-001 a TL-023 están completados. El Sprint 5
permanece pendiente: ampliación del corpus, revisión reproducible de memoria y
documentación final de instalación. No se implementaron bases de datos,
persistencia, interfaz, múltiples recursos, fechas ni el informe LNCS.

La especificación técnica está en
[`docs/PROPUESTA_ROADMAP.md`](docs/PROPUESTA_ROADMAP.md), la guía conceptual en
[`docs/GUIA_ESTUDIO.md`](docs/GUIA_ESTUDIO.md) y el estado de tareas en
[`docs/scrum/BACKLOG.md`](docs/scrum/BACKLOG.md).
