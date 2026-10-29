# Seguimiento de TurnoLang

## Tablero actual

| Campo | Estado basado en evidencia |
|---|---|
| Sprint actual | Sprint 2 — Análisis léxico y sintáctico, finalizado |
| Estado general | Frontend completo y verificable. Semántica, AST e interpretación todavía pendientes. |
| Progreso del backlog | 12 tareas completadas, 18 pendientes, 0 en progreso, 0 bloqueadas. |
| Próximo objetivo | Iniciar Sprint 3 con TL-013: construir el AST mínimo sin ejecutar todavía instrucciones. |

## Cierre de sprints

| Sprint | Estado | Evidencia de cierre |
|---|---|---|
| Sprint 0 — Definición y preparación | Completado | Documentación revisada y cadena de herramientas verificada. |
| Sprint 1 — Compilación | Completado | Construcción reproducible, ejecutable mínimo y cinco pruebas smoke. |
| Sprint 2 — Análisis léxico y sintáctico | Completado | Gramática completa, diagnósticos por etapa y línea, 21 casos nuevos y cinco regresiones aprobadas. |

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

Los completados del Sprint 2 acreditan reconocimiento y clasificación del
frontend. No acreditan validación de horarios, reglas de reservas ni ejecución.

## Actividades pendientes inmediatas

- [ ] [TL-013 — Implementar el AST mínimo](BACKLOG.md#tl-013)
- [ ] [TL-014 — Implementar el modelo de agenda](BACKLOG.md#tl-014)
- [ ] [TL-015 — Validar horas e intervalos](BACKLOG.md#tl-015)
- [ ] [TL-016 — Validar identificadores y cancelaciones](BACKLOG.md#tl-016)
- [ ] [TL-017 — Validar superposiciones](BACKLOG.md#tl-017)
- [ ] [TL-018 — Integrar diagnósticos semánticos](BACKLOG.md#tl-018)

El resto del trabajo permanece priorizado en
[`BACKLOG.md`](BACKLOG.md); no se reproduce aquí para evitar dos fuentes de
estado.

## Actividades bloqueadas

No hay tareas bloqueadas. Sprint 3 no fue iniciado.

## Entorno verificado

| Componente | Versión detectada | Procedencia |
|---|---|---|
| Sistema operativo | Windows 11, versión NT 10.0.26200.0 | Entorno de ejecución local. |
| Shell | GNU Bash 5.3.15 | Git for Windows. |
| Flex | 2.6.4 | `winflexbison` 2.5.25 instalado con Scoop. |
| Bison | GNU Bison 3.8.2 | `winflexbison` 2.5.25 instalado con Scoop. |
| GCC | 15.2.0 | Paquete `gcc` de Scoop. |
| GNU Make | 4.4.1 | Paquete `make` de Scoop. |

No se incorporaron herramientas ni dependencias adicionales en Sprint 2.

## Evidencia del Sprint 2

| Comando o comprobación | Resultado real |
|---|---|
| `make clean && make` | Aprobado; generación y compilación sin advertencias normales ni conflictos Bison. |
| `make test` | Aprobado; 5 regresiones del Sprint 1 y 21 escenarios del Sprint 2. |
| Programas con las cinco instrucciones | Aprobado; código 0 y confirmación del frontend. |
| `25:70`, agenda vacía e intervalo invertido | Aprobado; aceptados como sintaxis válida, sin anticipar semántica. |
| Cuatro formas de hora incorrecta | Aprobado; error léxico completo y línea 3. |
| Símbolo desconocido y cadena sin cierre | Aprobado; error léxico sin diagnóstico sintáctico duplicado. |
| Identificadores válidos e inválidos | Aprobado; letras/guion bajo aceptados y comienzo numérico/guion rechazados. |
| Cinco estructuras inválidas y palabra en minúsculas | Aprobado; error sintáctico y línea correcta. |
| Revisión de propiedad de cadenas, ID y horas | Aprobado; acciones liberan reducciones, `%destructor` cubre descartes y `yylex_destroy` libera el scanner. |

## Problemas encontrados

1. Los horarios mal formados podían fragmentarse en tokens válidos más pequeños.
   Se resolvió ubicando la regla `HH:MM` antes de un candidato numérico amplio:
   la coincidencia más larga captura completos `9:30`, `09-30`, `09:3` y
   `09:300`, mientras `25:70` conserva el token de hora.
2. Al faltar `;` antes de EOF, `yylineno` podía apuntar a la línea posterior al
   último salto. Se conserva `lexer_token_line` para atribuir el error al último
   token significativo.
3. El `-fanalyzer` disponible emitió advertencias en las implementaciones
   generadas por Flex/Bison, no en los módulos propios, y este MinGW no incluye
   AddressSanitizer. Se realizó revisión de propiedad explícita y se agregó
   `yylex_destroy`; la compilación normal permanece sin advertencias.

No quedaron problemas abiertos para Sprint 2.

## Riesgos identificados

| Riesgo | Impacto | Mitigación / señal de control |
|---|---|---|
| El AST toma propiedad sin ajustar las liberaciones actuales. | Doble liberación o pérdida de valores en Sprint 3. | Definir el traspaso de propiedad en TL-013 antes de cambiar acciones Bison. |
| Las acciones de Bison incorporan reglas de agenda. | Mezcla fases y duplica lógica. | Limitar acciones futuras a construcción del AST; semántica va en módulos C. |
| Una validación semántica modifica estado antes de terminar. | Una sentencia inválida deja efectos parciales. | Mantener el contrato validar-sin-mutar y ejecutar después. |
| Se asume compatibilidad fuera del entorno probado. | La construcción puede no ser reproducible. | Mantener el README limitado a Windows 11 + Git Bash + Scoop. |
| Se redacta el informe con resultados previstos. | Incumple honestidad académica. | TL-028 continúa dependiendo de las pruebas ejecutadas de TL-025. |

## Decisiones relevantes

| Decisión | Justificación | Consecuencia |
|---|---|---|
| Palabras reservadas antes de `IDENT`. | Flex resuelve empates por orden de regla. | Mayúsculas producen tokens reservados; minúsculas permanecen identificadores. |
| Candidato numérico después de `HORA`. | Evita fragmentar horarios incorrectos sin rechazar `25:70`. | Forma y rango permanecen en etapas distintas. |
| Valores textuales para ID, cadena y hora. | Prepara el contrato para el AST futuro. | Flex reserva; Bison libera hoy y transferirá propiedad en Sprint 3. |
| Lista recursiva con `%empty`. | Traduce `sentencia*` sin ambigüedad ni advertencias. | La cabecera sigue siendo obligatoria y única. |
| Suprimir `yyerror` tras fallo léxico. | Evita dos diagnósticos de etapas diferentes para un mismo fragmento. | El primer error relevante detiene el procesamiento. |
| Mantener scripts separados por sprint. | Conserva evidencia de regresión y hace legible el crecimiento. | `make test` ejecuta smoke y frontend en orden. |

## Registro breve de avances

| Fecha | Avance | Evidencia / resultado |
|---|---|---|
| 2026-10-09 | Revisión de la propuesta inicial y cierre de decisiones de diseño. | Roadmap, guía de estudio y seguimiento Scrum creados. |
| 2026-10-29 | Verificación e implementación de Sprint 1. | Cadena Flex/Bison/GCC/Make y cinco pruebas smoke. |
| 2026-10-29 | Implementación del scanner y parser completos. | Siete palabras reservadas, tres tokens con valor y cuatro clases de sentencia. |
| 2026-10-29 | Verificación de Sprint 2. | 26 pruebas acumuladas, diagnóstico por etapa/línea y compilación limpia. |

## Retrospectiva — Sprint 2

- **Qué funcionó:** mantener casos separados por etapa permitió comprobar que un
  error léxico no se informara además como sintáctico.
- **Qué dificultades aparecieron:** la coincidencia más larga de Flex y la línea
  de EOF exigieron reglas y estado explícitos.
- **Qué debe mejorarse:** en Sprint 3, documentar la propiedad de cada puntero en
  el AST antes de modificar las acciones que hoy liberan valores.
- **Qué continúa en el próximo sprint:** TL-013 a TL-018, sin comenzar todavía
  la ejecución de instrucciones del Sprint 4.

## Plantilla de retrospectiva

Completar al finalizar cada sprint posterior.

### Retrospectiva — Sprint N

- **Qué funcionó:** prácticas o decisiones que ayudaron a producir el incremento.
- **Qué dificultades aparecieron:** problemas técnicos observados, no supuestos.
- **Qué debe mejorarse:** una acción concreta y verificable para el sprint
  siguiente.
- **Qué continúa en el próximo sprint:** IDs no completados o trabajo derivado,
  con su estado actualizado en el backlog.
