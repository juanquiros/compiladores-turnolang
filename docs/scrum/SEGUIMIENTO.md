# Seguimiento de TurnoLang

## Tablero actual

| Campo | Estado basado en evidencia |
|---|---|
| Sprint actual | Sprint 3 — Estructuras internas y semántica, finalizado |
| Estado general | AST y análisis semántico completos. La ejecución visible del intérprete permanece pendiente. |
| Progreso del backlog | 18 tareas completadas, 12 pendientes, 0 en progreso, 0 bloqueadas. |
| Próximo objetivo | Iniciar Sprint 4 con TL-019: recorrer y ejecutar el AST sin duplicar las validaciones existentes. |

## Cierre de sprints

| Sprint | Estado | Evidencia de cierre |
|---|---|---|
| Sprint 0 — Definición y preparación | Completado | Diseño, guía, trazabilidad y herramientas verificadas. |
| Sprint 1 — Compilación | Completado | Construcción reproducible, ejecutable mínimo y cinco pruebas smoke. |
| Sprint 2 — Análisis léxico y sintáctico | Completado | Frontend completo, diagnósticos por etapa/línea y 23 pruebas de frontend. |
| Sprint 3 — Estructuras internas y semántica | Completado | AST ordenado, agenda temporal, seis reglas semánticas del backlog y 21 pruebas nuevas. |

## Actividades completadas

- [x] [TL-001 — Revisar requisitos y delimitar el alcance](BACKLOG.md#tl-001)
- [x] [TL-002 — Cerrar la especificación del lenguaje](BACKLOG.md#tl-002)
- [x] [TL-003 — Definir arquitectura, semántica y pruebas](BACKLOG.md#tl-003)
- [x] [TL-004 — Preparar guía y seguimiento académico](BACKLOG.md#tl-004)
- [x] [TL-005 — Verificar el entorno de herramientas](BACKLOG.md#tl-005)
- [x] [TL-006 — Crear la estructura técnica mínima](BACKLOG.md#tl-006)
- [x] [TL-007 — Automatizar generación y compilación](BACKLOG.md#tl-007)
- [x] [TL-008 — Integrar un ejecutable mínimo](BACKLOG.md#tl-008)
- [x] [TL-009 — Implementar tokens y scanner](BACKLOG.md#tl-009)
- [x] [TL-010 — Implementar gramática y parser](BACKLOG.md#tl-010)
- [x] [TL-011 — Implementar diagnósticos del frontend](BACKLOG.md#tl-011)
- [x] [TL-012 — Automatizar pruebas del frontend](BACKLOG.md#tl-012)
- [x] [TL-013 — Implementar el AST mínimo](BACKLOG.md#tl-013)
- [x] [TL-014 — Implementar el modelo de agenda](BACKLOG.md#tl-014)
- [x] [TL-015 — Validar horas e intervalos](BACKLOG.md#tl-015)
- [x] [TL-016 — Validar identificadores y cancelaciones](BACKLOG.md#tl-016)
- [x] [TL-017 — Validar superposiciones](BACKLOG.md#tl-017)
- [x] [TL-018 — Integrar diagnósticos semánticos](BACKLOG.md#tl-018)

Los completados de Sprint 3 acreditan validación y actualización de un estado
temporal. No acreditan todavía resultados funcionales de agenda.

## Actividades pendientes inmediatas

- [ ] [TL-019 — Implementar el recorrido secuencial](BACKLOG.md#tl-019)
- [ ] [TL-020 — Ejecutar reservas y cancelaciones](BACKLOG.md#tl-020)
- [ ] [TL-021 — Ejecutar consultas de disponibilidad](BACKLOG.md#tl-021)
- [ ] [TL-022 — Ejecutar el listado ordenado](BACKLOG.md#tl-022)
- [ ] [TL-023 — Estabilizar salida y códigos de proceso](BACKLOG.md#tl-023)

El resto del trabajo permanece priorizado en
[`BACKLOG.md`](BACKLOG.md); no se reproduce aquí para evitar dos fuentes de
estado.

## Actividades bloqueadas

No hay tareas bloqueadas. Sprint 4 no fue iniciado.

## Entorno verificado

| Componente | Versión detectada | Procedencia |
|---|---|---|
| Sistema operativo | Windows 11, versión NT 10.0.26200.0 | Entorno de ejecución local. |
| Shell | GNU Bash 5.3.15 | Git for Windows. |
| Flex | 2.6.4 | `winflexbison` 2.5.25 instalado con Scoop. |
| Bison | GNU Bison 3.8.2 | `winflexbison` 2.5.25 instalado con Scoop. |
| GCC | 15.2.0 | Paquete `gcc` de Scoop. |
| GNU Make | 4.4.1 | Paquete `make` de Scoop. |

No se incorporaron dependencias externas en Sprint 3. Valgrind y AddressSanitizer
no están disponibles en este entorno MinGW.

## Evidencia del Sprint 3

| Comando o comprobación | Resultado real |
|---|---|
| `make clean && make` | Aprobado; seis unidades de traducción propias/generadas compiladas sin advertencias normales ni conflictos Bison. |
| `make test` | Aprobado; 5 smoke, 23 frontend y 21 semánticas: 49 pruebas acumuladas. |
| Modo `--solo-sintaxis` | Aprobado; construye/libera AST y conserva aceptación de entradas semánticamente inválidas del Sprint 2. |
| AST y orden | Aprobado; errores tardíos en líneas 5/7 dependen de nodos previos y se atribuyen a la instrucción correcta. |
| Horas e intervalos | Aprobado; límites, rango, vacío e inversión clasificados como se especificó. |
| Identificadores y cancelaciones | Aprobado; duplicado, inexistente, doble cancelación y reutilización cubiertos. |
| Superposiciones | Aprobado; cruce parcial, ambas contenciones y reservas consecutivas cubiertos. |
| Consulta ocupada | Aprobado; usa el estado sin producir error ni salida funcional. |
| Propiedad de memoria | Aprobado por revisión y rutas ejecutadas; tokens, listas, AST, agenda y scanner tienen liberación definida. |

## Problemas encontrados

1. El primer contrato del símbolo inicial tenía un `%destructor` para
   `Programa` y `main` también lo liberaba. Las regresiones detectaron corrupción
   de heap. Se eliminó únicamente ese destructor: al aceptar, la propiedad se
   transfiere a `programa_analizado`; los demás destructores continúan cubriendo
   errores y descartes.
2. La línea semántica no podía depender del último token global por el lookahead
   de Bison. Se integró `%locations`; cada nodo guarda `@1.first_line` de su
   palabra reservada.
3. Las pruebas del Sprint 2 necesitaban conservar entradas como `25:70`. Se
   incorporó `--solo-sintaxis`, que construye y libera el AST pero omite
   semántica.
4. El entorno no dispone de una herramienta dinámica de memoria. Se documentó
   la limitación, se revisó la propiedad y se agregaron errores léxico/sintáctico
   después de una lista AST no vacía para ejercitar liberaciones.

No quedaron problemas abiertos para Sprint 3.

## Decisiones relevantes

| Decisión | Justificación | Consecuencia |
|---|---|---|
| AST como lista tipada con unión. | Conserva datos, línea y orden sin infraestructura genérica. | Inserción O(1) mediante primer/último nodo. |
| Transferencia de textos desde Bison. | Evita copias innecesarias y prepara el backend. | El nodo libera los textos; `%destructor` solo actúa si se descartan antes. |
| `%locations` para nodos. | Evita que el lookahead cambie la línea atribuida. | Los errores semánticos señalan la palabra reservada de la instrucción. |
| Validar y aplicar en funciones separadas. | Una operación rechazada no debe mutar estado. | El estado temporal solo recibe instrucciones ya validadas. |
| Agenda copia identificadores. | Su vida útil es independiente del AST durante la validación. | Agenda y AST pueden liberarse sin propiedad compartida. |
| Una función de intersección semiabierta. | Evita duplicación y permite turnos consecutivos. | Reserva y `LIBRE` consultan la misma regla. |
| `LISTAR` y `LIBRE` sin salida visible. | El backend corresponde al Sprint 4. | Sprint 3 solo informa validez global o errores. |

## Registro breve de avances

| Fecha | Avance | Evidencia / resultado |
|---|---|---|
| 2026-10-09 | Definición académica inicial. | Roadmap, guía y seguimiento creados. |
| 2026-10-29 | Sprints 1 y 2 completados. | Construcción reproducible y frontend completo. |
| 2026-10-29 | AST y ubicaciones integrados. | Programa y lista tipada construidos por acciones Bison. |
| 2026-10-29 | Semántica y agenda temporal implementadas. | Horas, intervalos, IDs, cancelaciones y cruces validados en orden. |
| 2026-10-29 | Sprint 3 verificado. | 49 pruebas acumuladas y regresiones de memoria/ubicación aprobadas. |

## Retrospectiva — Sprint 3

- **Qué funcionó:** separar AST, agenda y semántica permitió probar reglas sin
  introducir salidas propias del intérprete.
- **Qué dificultades aparecieron:** la transferencia del start symbol mostró que
  los destructores de Bison requieren un contrato de propiedad explícito.
- **Qué debe mejorarse:** Sprint 4 debe reutilizar el estado y validadores
  actuales; antes de cambiar salidas se debe fijar un contrato determinista.
- **Qué continúa en el próximo sprint:** TL-019 a TL-023, sin iniciar pruebas
  integrales de Sprint 5 ni el informe final.

## Plantilla de retrospectiva

Completar al finalizar cada sprint posterior.

### Retrospectiva — Sprint N

- **Qué funcionó:** prácticas o decisiones que ayudaron a producir el incremento.
- **Qué dificultades aparecieron:** problemas técnicos observados, no supuestos.
- **Qué debe mejorarse:** una acción concreta y verificable para el sprint
  siguiente.
- **Qué continúa en el próximo sprint:** IDs no completados o trabajo derivado,
  con su estado actualizado en el backlog.
