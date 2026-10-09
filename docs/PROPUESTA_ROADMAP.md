# Propuesta de trabajo integrador: TurnoLang

## Idea

**TurnoLang** es un lenguaje de dominio específico (DSL) para cargar y consultar
la agenda de turnos de un único recurso durante un día: por ejemplo, un
consultorio, una cancha o una sala de reuniones. El intérprete valida que los
turnos sean consistentes y que no se superpongan; luego genera una agenda
ordenada y responde consultas de disponibilidad.

El problema es habitual y fácil de explicar: una agenda manual puede contener
horarios inválidos, turnos repetidos o solapados. TurnoLang centraliza esas
validaciones y ofrece una sintaxis breve para automatizarlas.

## Alcance cerrado

- Un día por archivo; no se manejan fechas, usuarios ni persistencia.
- Horarios en formato `HH:MM`, con intervalo semiabierto `[inicio, fin)`.
- Identificadores simples para cada turno.
- Instrucciones: reservar, cancelar, listar y consultar disponibilidad.
- Salida por consola; no habrá interfaz gráfica.

Este alcance evita que el proyecto se convierta en un sistema de calendarios y
deja espacio para demostrar análisis léxico, sintáctico y semántico.

## Lenguaje fuente propuesto

Ejemplo ejecutable:

```txt
AGENDA "Consultorio A";

RESERVAR consulta_ana DESDE 09:00 HASTA 09:30;
RESERVAR reunion_equipo DESDE 10:00 HASTA 11:00;
LIBRE DESDE 09:30 HASTA 10:00;
CANCELAR consulta_ana;
LISTAR;
```

Salida esperada (orientativa):

```txt
Franja 09:30-10:00: DISPONIBLE
Agenda: Consultorio A
10:00-11:00  reunion_equipo
```

Gramática EBNF inicial:

```ebnf
programa       ::= cabecera sentencia* EOF ;
cabecera       ::= AGENDA CADENA ";" ;
sentencia      ::= reserva | cancelacion | listado | disponibilidad ;
reserva        ::= RESERVAR IDENT DESDE HORA HASTA HORA ";" ;
cancelacion    ::= CANCELAR IDENT ";" ;
listado        ::= LISTAR ";" ;
disponibilidad ::= LIBRE DESDE HORA HASTA HORA ";" ;
```

Tokens principales: palabras reservadas, `IDENT`, `CADENA`, `HORA`, punto y
coma. Flex reconocerá `HORA` y Bison controlará la estructura de las
sentencias.

## Reglas semánticas

1. La hora de inicio debe ser estrictamente menor a la de fin.
2. Un identificador no puede reservarse dos veces mientras esté activo.
3. No puede existir solapamiento entre dos turnos activos.
4. Solo se puede cancelar un turno existente.
5. La consulta `LIBRE` también debe tener un intervalo válido.

Los horarios se convierten a minutos desde medianoche; así el chequeo de
solapamiento se reduce a `inicioNuevo < finExistente && finNuevo > inicioExistente`.

## Arquitectura

```text
archivo .tl
   |
Flex (lexer.l) -> tokens
   |
Bison (parser.y) -> AST/lista de sentencias
   |
analizador semántico -> tabla/lista de turnos y diagnósticos
   |
intérprete C -> agenda ordenada y consultas por consola
```

El destino no necesita ser otro lenguaje: es la ejecución interpretada y la
salida textual de la agenda. Cada error debe incluir etapa, línea y motivo.

## Estructura sugerida del repositorio

```text
turnolang/
  src/lexer.l       src/parser.y       src/main.c
  src/ast.[ch]      src/semantica.[ch] src/interprete.[ch]
  examples/ok_basico.tl
  examples/ok_cancelacion.tl
  examples/error_lexico.tl
  examples/error_sintactico.tl
  examples/error_horario.tl
  examples/error_solapamiento.tl
  examples/error_cancelacion.tl
  scripts/ejecutar_todos.sh
  Makefile           README.md          informe/
```

## Roadmap

| Hito | Resultado verificable |
|---|---|
| 1. Aprobación | Problema, ejemplo y gramática EBNF acordados con el docente. |
| 2. Base de compilación | `make` genera lexer con Flex, parser con Bison y el ejecutable C. |
| 3. Frontend mínimo | Reconoce cabecera, reservas y `LISTAR`; reporta error léxico/sintáctico con línea. |
| 4. AST y semántica | Tabla de turnos, validación de rangos, duplicados y solapamientos. |
| 5. Backend | Ejecuta cancelaciones/consultas y muestra agenda ordenada. |
| 6. Ambiente de pruebas | `make test` o script ejecuta todos los ejemplos y muestra resultado esperado. |
| 7. Entrega/defensa | Informe LNCS, README reproducible y guion de demo de 15 minutos. |

Orden recomendado: primero lograr una reserva válida de punta a punta; después
agregar reglas semánticas de a una. No incorporar recurrentes, múltiples días,
usuarios, archivos de salida ni GUI salvo que todo el alcance mínimo ya esté
terminado.

## Casos de prueba mínimos

| Archivo | Debe demostrar |
|---|---|
| `ok_basico.tl` | Dos reservas, listado ordenado y una franja libre. |
| `ok_cancelacion.tl` | Cancelar y volver a consultar/listar. |
| `error_lexico.tl` | Símbolo o formato de hora no reconocido. |
| `error_sintactico.tl` | Falta de `;` o palabra clave. |
| `error_horario.tl` | Inicio igual o posterior al fin. |
| `error_solapamiento.tl` | Dos reservas activas con intersección horaria. |
| `error_cancelacion.tl` | Cancelación de identificador inexistente. |

## Qué presentar hoy al docente

"Queremos construir TurnoLang, un intérprete en C con Flex y Bison para
validar y consultar la agenda de un recurso durante un día. El lexer reconocerá
horas, identificadores y palabras reservadas; Bison construirá un AST; una fase
semántica detectará rangos inválidos, IDs duplicados, turnos inexistentes y
solapamientos; finalmente el intérprete imprimirá agenda y disponibilidad.
Entregaremos Makefile, scripts de casos y un informe LNCS. Delimitamos el
alcance a un día y sin recurrencias para asegurar una implementación y defensa
completas."

## Defensa de 15 minutos

1. Problema y alcance: 2 min.
2. Sintaxis, tokens y gramática: 3 min.
3. Arquitectura Flex -> Bison -> semántica -> intérprete: 3 min.
4. Demo de caso válido y tres errores de etapas distintas: 5 min.
5. Conclusiones, límites y posible extensión: 2 min.

Para el informe LNCS: incluir título, autores, resumen, palabras clave,
introducción, antecedentes, desarrollo (lenguaje, arquitectura y pruebas),
conclusiones y referencias citadas en el texto. Numerar y citar figuras,
tablas y fragmentos de código antes de que aparezcan.


