# Seguimiento de TurnoLang

## Tablero actual

| Campo | Estado basado en evidencia |
|---|---|
| Sprint actual | Sprint 4 — Intérprete completo, finalizado |
| Estado general | Backend funcional con reserva, cancelación, disponibilidad y listado determinista. |
| Progreso del backlog | 23 tareas completadas, 7 pendientes, 0 en progreso, 0 bloqueadas. |
| Próximo objetivo | Sprint 5: TL-024 a TL-027, pruebas ampliadas, memoria y reproducibilidad. |

## Cierre de sprints

| Sprint | Estado | Evidencia de cierre |
|---|---|---|
| Sprint 0 — Definición y preparación | Completado | Diseño, guía, trazabilidad y herramientas verificadas. |
| Sprint 1 — Compilación | Completado | Construcción reproducible, ejecutable mínimo y 5 pruebas smoke. |
| Sprint 2 — Análisis léxico y sintáctico | Completado | Frontend completo, diagnósticos y 23 pruebas. |
| Sprint 3 — Estructuras internas y semántica | Completado | AST, agenda, reglas semánticas y 21 pruebas nuevas. |
| Sprint 4 — Intérprete completo | Completado | Motor secuencial, salidas estables y 15 escenarios funcionales. |

## Actividades completadas

- [x] TL-001 a TL-005 — definición, arquitectura, documentación y entorno.
- [x] TL-006 a TL-008 — estructura, Makefile y ejecutable mínimo.
- [x] TL-009 a TL-012 — scanner, parser, diagnósticos y pruebas del frontend.
- [x] TL-013 a TL-018 — AST, agenda y análisis semántico.
- [x] [TL-019 — Implementar el recorrido secuencial](BACKLOG.md#tl-019).
- [x] [TL-020 — Ejecutar reservas y cancelaciones](BACKLOG.md#tl-020).
- [x] [TL-021 — Ejecutar consultas de disponibilidad](BACKLOG.md#tl-021).
- [x] [TL-022 — Ejecutar el listado ordenado](BACKLOG.md#tl-022).
- [x] [TL-023 — Estabilizar salida y códigos de proceso](BACKLOG.md#tl-023).

## Actividades pendientes inmediatas

- [ ] [TL-024 — Completar el corpus de escenarios](BACKLOG.md#tl-024).
- [ ] [TL-025 — Consolidar el runner integral](BACKLOG.md#tl-025).
- [ ] [TL-026 — Verificar memoria y compilación limpia](BACKLOG.md#tl-026).
- [ ] [TL-027 — Documentar instalación y uso reproducible](BACKLOG.md#tl-027).

Los 15 casos funcionales añadidos en Sprint 4 acreditan su incremento, pero no
cierran por sí solos el corpus ampliado, la prueba de memoria ni la
reproducibilidad integral previstas para Sprint 5. El informe LNCS y la defensa
permanecen en Sprint 6.

## Actividades bloqueadas

No hay tareas bloqueadas. Sprint 5 no fue iniciado.

## Entorno verificado

| Componente | Versión detectada | Procedencia |
|---|---|---|
| Sistema operativo | Windows 11, NT 10.0.26200.0 | Entorno local. |
| Shell | GNU Bash 5.3.15 | Git for Windows. |
| Flex | 2.6.4 | `winflexbison` 2.5.25 mediante Scoop. |
| Bison | GNU Bison 3.8.2 | `winflexbison` 2.5.25 mediante Scoop. |
| GCC | 15.2.0 | Scoop. |
| GNU Make | 4.4.1 | Scoop. |

Valgrind y AddressSanitizer no están disponibles en este entorno MinGW. No se
declara una ejecución dinámica de memoria que no pudo realizarse.

## Evidencia del Sprint 4

| Comando o comprobación | Resultado real |
|---|---|
| Línea base `make clean && make && make test` | Aprobada antes de modificar: 49/49 pruebas. |
| Compilación del backend | `interprete.c` y siete unidades totales enlazadas sin advertencias normales ni conflictos Bison. |
| `make test` | Aprobado: 5 smoke + 23 frontend + 21 semánticas + 15 intérprete = 64 escenarios. |
| Construcción incremental | Segunda invocación de `make`: no había trabajo pendiente. |
| `make clean && make -j2` | Aprobado desde limpio; fuentes y ejemplos preservados por la limpieza. |
| Modo `--solo-sintaxis` | Aprobado; no valida ni interpreta. |
| Modo `--solo-semantica` | Aprobado; usa el motor común sin salida funcional. |
| Modo completo | Aprobado; `stdout` contiene solo resultados del lenguaje. |
| Reserva/cancelación/reutilización | Aprobado; solo las reservas activas aparecen y ocupan intervalos. |
| `LIBRE` | Aprobado; informa ambos estados, no muta y `OCUPADO` permite continuar. |
| `LISTAR` | Aprobado; orden cronológico, canceladas omitidas y agenda vacía definida. |
| Errores tardíos de frontend | Aprobado; no se emite salida funcional antes de aceptar el archivo completo. |
| Error semántico intermedio | Aprobado; conserva salida previa, rechaza la operación y omite las posteriores. |
| Repetibilidad | Dos ejecuciones de `ok_completo.tl` produjeron código y flujos idénticos. |

La suite completa volvió a aprobar después de la construcción paralela.

## Arquitectura implementada

`semantica_procesar_programa` es el único recorrido de negocio. Conserva las
funciones internas `validar_sentencia` y `aplicar_sentencia`; después de una
aplicación válida invoca un observador opcional. `semantica_validar_programa`
usa el recorrido sin observador y `interprete_ejecutar_programa` lo usa con un
observador de salida.

Así, ambos modos comparten:

- orden del AST;
- conversión y validación de horas;
- identificadores y cancelaciones;
- algoritmo de superposición;
- actualización de la misma agenda; y
- detención y liberación ante error.

La agenda sigue ocultando `ReservaAgenda`. Solo entrega un arreglo temporal de
vistas activas ordenadas para `LISTAR`, que el intérprete libera después de
imprimir.

## Problemas encontrados

1. Al invocar `make clean` desde PowerShell, GNU Make no encontró `rm`. Se
   confirmó que el proyecto está definido y documentado para Git Bash; la línea
   base y la validación final se ejecutan en ese entorno.
2. El ejecutable nativo de Windows genera `CRLF`, mientras los oráculos de Git
   usan `LF`. El runner canoniza únicamente el terminador de línea antes de la
   comparación byte a byte; contenido, orden, código y separación de flujos se
   siguen comparando estrictamente.
3. El modo normal anterior imprimía mensajes académicos y habría contaminado el
   contrato funcional. Esos mensajes quedaron limitados a `--solo-sintaxis` y
   `--solo-semantica`; el modo completo solo imprime resultados del lenguaje.

No quedaron defectos abiertos del Sprint 4.

## Decisiones relevantes

| Decisión | Justificación | Consecuencia |
|---|---|---|
| Observador opcional después de aplicar. | Comparte recorrido y estado entre semántica e intérprete. | No hay doble validación ni segunda agenda. |
| `LIBRE` conserva el resultado de la intersección. | Ya consulta la función común durante validación. | `OCUPADO` se imprime sin repetir el algoritmo. |
| Vista temporal ordenada de reservas. | Mantiene privado el nodo de agenda. | `LISTAR` es simple y libera un único arreglo temporal. |
| Silencio para reserva/cancelación. | Evita mensajes no especificados. | Solo consultas y listados aparecen en `stdout`. |
| Oráculos completos versionados. | Hace observable cualquier cambio de línea u orden. | Los 15 casos fallan ante salida extra, faltante o código incorrecto. |

## Registro breve de avances

| Fecha | Avance | Evidencia / resultado |
|---|---|---|
| 2026-10-09 | Definición académica inicial. | Roadmap, guía y seguimiento creados. |
| 2026-10-29 | Sprints 1 a 3 completados. | Frontend, AST, semántica y 49 pruebas. |
| 2026-11-02 | Motor compartido e intérprete implementados. | Tres modos sin duplicar validadores. |
| 2026-11-02 | Contrato funcional automatizado. | 15 escenarios y repetibilidad aprobados. |

## Retrospectiva — Sprint 4

- **Qué funcionó:** el contrato `validar → aplicar → observar` permitió agregar
  salidas sin alterar las reglas ya probadas.
- **Qué dificultades aparecieron:** la diferencia `CRLF`/`LF` y el uso de
  utilidades POSIX requerían distinguir entorno de ejecución de lógica del DSL.
- **Qué debe mejorarse:** Sprint 5 debe ejecutar una herramienta dinámica de
  memoria en un entorno compatible y ampliar los bordes del corpus.
- **Qué continúa en el próximo sprint:** TL-024 a TL-027; no se inició el
  informe LNCS ni trabajo del Sprint 6.
