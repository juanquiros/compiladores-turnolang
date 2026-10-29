# Product Backlog de TurnoLang

Este archivo es la fuente principal del estado de las actividades. Los criterios
describen qué evidencia se necesita; no implican que esa evidencia ya exista.

## Resumen

| ID | Descripción breve | Prioridad | Sprint | Estado |
|---|---|---|---:|---|
| [TL-001](#tl-001) | Revisar requisitos y alcance | Crítica | 0 | Completado |
| [TL-002](#tl-002) | Cerrar especificación del lenguaje | Crítica | 0 | Completado |
| [TL-003](#tl-003) | Definir arquitectura, semántica y pruebas | Crítica | 0 | Completado |
| [TL-004](#tl-004) | Preparar guía y seguimiento académico | Alta | 0 | Completado |
| [TL-005](#tl-005) | Verificar entorno de herramientas | Crítica | 0 | Completado |
| [TL-006](#tl-006) | Crear estructura técnica mínima | Alta | 1 | Completado |
| [TL-007](#tl-007) | Automatizar generación y compilación | Crítica | 1 | Completado |
| [TL-008](#tl-008) | Integrar ejecutable mínimo | Crítica | 1 | Completado |
| [TL-009](#tl-009) | Implementar tokens y scanner | Crítica | 2 | Completado |
| [TL-010](#tl-010) | Implementar gramática y parser | Crítica | 2 | Completado |
| [TL-011](#tl-011) | Implementar diagnósticos del frontend | Alta | 2 | Completado |
| [TL-012](#tl-012) | Automatizar pruebas del frontend | Alta | 2 | Completado |
| [TL-013](#tl-013) | Implementar AST mínimo | Alta | 3 | Completado |
| [TL-014](#tl-014) | Implementar modelo de agenda | Crítica | 3 | Completado |
| [TL-015](#tl-015) | Validar horas e intervalos | Crítica | 3 | Completado |
| [TL-016](#tl-016) | Validar identificadores y cancelaciones | Crítica | 3 | Completado |
| [TL-017](#tl-017) | Validar superposiciones | Crítica | 3 | Completado |
| [TL-018](#tl-018) | Integrar diagnósticos semánticos | Alta | 3 | Completado |
| [TL-019](#tl-019) | Implementar recorrido secuencial | Crítica | 4 | Pendiente |
| [TL-020](#tl-020) | Ejecutar reservas y cancelaciones | Crítica | 4 | Pendiente |
| [TL-021](#tl-021) | Ejecutar disponibilidad | Alta | 4 | Pendiente |
| [TL-022](#tl-022) | Ejecutar listado ordenado | Alta | 4 | Pendiente |
| [TL-023](#tl-023) | Estabilizar salida y códigos de proceso | Alta | 4 | Pendiente |
| [TL-024](#tl-024) | Completar corpus de escenarios | Crítica | 5 | Pendiente |
| [TL-025](#tl-025) | Implementar runner y `make test` | Crítica | 5 | Pendiente |
| [TL-026](#tl-026) | Verificar memoria y compilación limpia | Alta | 5 | Pendiente |
| [TL-027](#tl-027) | Documentar instalación y uso | Alta | 5 | Pendiente |
| [TL-028](#tl-028) | Elaborar informe LNCS | Crítica | 6 | Pendiente |
| [TL-029](#tl-029) | Preparar demostración y defensa | Crítica | 6 | Pendiente |
| [TL-030](#tl-030) | Ejecutar revisión final de trazabilidad | Crítica | 6 | Pendiente |

## Sprint 0: definición y preparación

<a id="tl-001"></a>
### TL-001 — Revisar requisitos y delimitar el alcance

- **Descripción:** analizar la propuesta inicial y los requisitos de la cátedra;
  conservar una agenda, un recurso y un día, y excluir funcionalidades ajenas.
- **Prioridad:** Crítica.
- **Sprint asignado:** 0.
- **Dependencias:** Ninguna.
- **Criterios de aceptación:** el problema, funcionalidades, exclusiones y
  requisitos académicos aparecen de forma explícita y sin fechas ficticias en
  `docs/PROPUESTA_ROADMAP.md`.
- **Estado:** Completado.

<a id="tl-002"></a>
### TL-002 — Cerrar la especificación del lenguaje

- **Descripción:** definir extensión, palabras reservadas, tokens,
  identificadores, literales, instrucciones, EBNF y decisiones de borde.
- **Prioridad:** Crítica.
- **Sprint asignado:** 0.
- **Dependencias:** TL-001.
- **Criterios de aceptación:** la gramática no es ambigua para las instrucciones
  previstas y diferencia forma de hora, rango, intervalos consecutivos,
  duplicados, cancelados y consultas.
- **Estado:** Completado.

<a id="tl-003"></a>
### TL-003 — Definir arquitectura, semántica y estrategia de pruebas

- **Descripción:** justificar intérprete y AST mínimo; separar frontend,
  validación y ejecución; trazar requisitos con casos futuros.
- **Prioridad:** Crítica.
- **Sprint asignado:** 0.
- **Dependencias:** TL-001, TL-002.
- **Criterios de aceptación:** existe un diagrama coherente con C, Flex y Bison,
  cada requisito obligatorio tiene evidencia planificada y cada caso mínimo
  tiene objetivo, resultado, clasificación y forma de verificación.
- **Estado:** Completado.

<a id="tl-004"></a>
### TL-004 — Preparar guía de estudio y seguimiento académico

- **Descripción:** documentar los conceptos necesarios para implementación y
  defensa, y crear backlog, sprints y tablero sin duplicar estados.
- **Prioridad:** Alta.
- **Sprint asignado:** 0.
- **Dependencias:** TL-002, TL-003.
- **Criterios de aceptación:** `docs/GUIA_ESTUDIO.md` cubre el flujo completo y
  `docs/scrum/` contiene los cuatro archivos acordados con estados basados en
  evidencia del repositorio.
- **Estado:** Completado.

<a id="tl-005"></a>
### TL-005 — Verificar el entorno de herramientas

- **Descripción:** instalar o comprobar Flex, Bison, GNU Make, GCC y la shell en
  el entorno elegido; registrar versiones y comandos reales.
- **Prioridad:** Crítica.
- **Sprint asignado:** 0.
- **Dependencias:** TL-003.
- **Criterios de aceptación:** todos los comandos de versión funcionan en el
  entorno objetivo y el método de instalación queda anotado sin suponer
  compatibilidad no probada.
- **Estado:** Completado.

## Sprint 1: compilación

<a id="tl-006"></a>
### TL-006 — Crear la estructura técnica mínima

- **Descripción:** crear las carpetas y archivos fuente mínimos acordados, sin
  módulos o dependencias fuera de alcance.
- **Prioridad:** Alta.
- **Sprint asignado:** 1.
- **Dependencias:** TL-005.
- **Criterios de aceptación:** la estructura distingue fuentes, generados,
  ejemplos y scripts y cada archivo tiene una responsabilidad documentada.
- **Estado:** Completado.

<a id="tl-007"></a>
### TL-007 — Automatizar generación y compilación

- **Descripción:** crear el Makefile con dependencias para Flex, Bison, GCC,
  enlace, limpieza y objetivo de pruebas.
- **Prioridad:** Crítica.
- **Sprint asignado:** 1.
- **Dependencias:** TL-005, TL-006.
- **Criterios de aceptación:** `make` desde una limpieza genera archivos en el
  orden correcto, y `make clean` elimina solo artefactos generados.
- **Estado:** Completado.

<a id="tl-008"></a>
### TL-008 — Integrar un ejecutable mínimo

- **Descripción:** conectar `main`, un scanner y parser mínimos para abrir un
  archivo y terminar con un código controlado.
- **Prioridad:** Crítica.
- **Sprint asignado:** 1.
- **Dependencias:** TL-007.
- **Criterios de aceptación:** el ejecutable se construye sin errores ni
  advertencias relevantes y procesa una entrada mínima documentada.
- **Estado:** Completado.

## Sprint 2: análisis léxico y sintáctico

<a id="tl-009"></a>
### TL-009 — Implementar tokens y scanner

- **Descripción:** implementar palabras reservadas, ID, cadena, hora, `;`,
  espacios, líneas y captura de entradas no reconocidas en Flex.
- **Prioridad:** Crítica.
- **Sprint asignado:** 2.
- **Dependencias:** TL-008.
- **Criterios de aceptación:** la secuencia de tokens coincide con la
  especificación y distingue `9:00` de `25:00` según el contrato documentado.
- **Estado:** Completado.

<a id="tl-010"></a>
### TL-010 — Implementar gramática y parser

- **Descripción:** trasladar la EBNF a producciones Bison para cabecera y las
  cuatro clases de sentencia.
- **Prioridad:** Crítica.
- **Sprint asignado:** 2.
- **Dependencias:** TL-009.
- **Criterios de aceptación:** acepta todos los ejemplos sintácticamente válidos,
  rechaza orden o elementos incorrectos y no presenta conflictos no justificados.
- **Estado:** Completado.

<a id="tl-011"></a>
### TL-011 — Implementar diagnósticos del frontend

- **Descripción:** producir errores léxicos y sintácticos con etapa, línea,
  lexema o token relevante y motivo comprensible.
- **Prioridad:** Alta.
- **Sprint asignado:** 2.
- **Dependencias:** TL-009, TL-010.
- **Criterios de aceptación:** un símbolo, una hora mal formada y la falta de `;`
  se clasifican correctamente y el proceso devuelve código no cero.
- **Estado:** Completado.

<a id="tl-012"></a>
### TL-012 — Automatizar pruebas del frontend

- **Descripción:** agregar entradas y comparaciones mínimas para éxito de parseo,
  error léxico y error sintáctico.
- **Prioridad:** Alta.
- **Sprint asignado:** 2.
- **Dependencias:** TL-011.
- **Criterios de aceptación:** una ejecución automatizada demuestra aceptación y
  ambos errores, incluyendo códigos de retorno.
- **Estado:** Completado.

## Sprint 3: estructuras internas y semántica

<a id="tl-013"></a>
### TL-013 — Implementar el AST mínimo

- **Descripción:** crear programa, unión de sentencias, lista en orden y rutinas
  de construcción/liberación; conectar acciones Bison.
- **Prioridad:** Alta.
- **Sprint asignado:** 3.
- **Dependencias:** TL-010.
- **Criterios de aceptación:** todas las instrucciones conservan valores y línea,
  el orden fuente es estable y los caminos de éxito/error liberan memoria.
- **Estado:** Completado.

<a id="tl-014"></a>
### TL-014 — Implementar el modelo de agenda

- **Descripción:** representar reservas activas con ID e intervalo y ofrecer
  búsqueda y actualización sin persistencia.
- **Prioridad:** Crítica.
- **Sprint asignado:** 3.
- **Dependencias:** TL-013.
- **Criterios de aceptación:** el estado admite agregar, localizar, desactivar,
  recorrer y liberar reservas mediante una interfaz pequeña.
- **Estado:** Completado.

<a id="tl-015"></a>
### TL-015 — Validar horas e intervalos

- **Descripción:** convertir `HH:MM` a minutos, validar componentes y exigir
  inicio estrictamente anterior al fin.
- **Prioridad:** Crítica.
- **Sprint asignado:** 3.
- **Dependencias:** TL-013.
- **Criterios de aceptación:** límites válidos, valor fuera de rango, intervalo
  vacío e invertido tienen resultados unitarios o integrados verificables.
- **Estado:** Completado.

<a id="tl-016"></a>
### TL-016 — Validar identificadores y cancelaciones

- **Descripción:** rechazar ID activo duplicado, permitir reutilización tras
  cancelar y rechazar cancelaciones sin reserva activa.
- **Prioridad:** Crítica.
- **Sprint asignado:** 3.
- **Dependencias:** TL-014.
- **Criterios de aceptación:** los tres comportamientos coinciden con la
  especificación y no se altera estado ante rechazo.
- **Estado:** Completado.

<a id="tl-017"></a>
### TL-017 — Validar superposiciones

- **Descripción:** implementar una única función de intersección semiabierta y
  usarla para reserva y consulta.
- **Prioridad:** Crítica.
- **Sprint asignado:** 3.
- **Dependencias:** TL-014, TL-015.
- **Criterios de aceptación:** detecta cruces parciales y contención, acepta
  intervalos consecutivos y no duplica el algoritmo.
- **Estado:** Completado.

<a id="tl-018"></a>
### TL-018 — Integrar diagnósticos semánticos

- **Descripción:** centralizar resultado de validación y mensajes con línea y
  motivo antes de aplicar efectos.
- **Prioridad:** Alta.
- **Sprint asignado:** 3.
- **Dependencias:** TL-015, TL-016, TL-017.
- **Criterios de aceptación:** cada regla fallida tiene diagnóstico distinguible,
  código no cero y estado intacto para la sentencia rechazada.
- **Estado:** Completado.

## Sprint 4: intérprete completo

<a id="tl-019"></a>
### TL-019 — Implementar el recorrido secuencial

- **Descripción:** recorrer AST en orden, validar cada nodo y ejecutar solo si es
  válido; detenerse en el primer error semántico.
- **Prioridad:** Crítica.
- **Sprint asignado:** 4.
- **Dependencias:** TL-013, TL-018.
- **Criterios de aceptación:** el orden observable coincide con el archivo y no
  hay interpretación si el frontend rechazó el programa.
- **Estado:** Pendiente.

<a id="tl-020"></a>
### TL-020 — Ejecutar reservas y cancelaciones

- **Descripción:** aplicar al estado las operaciones válidas y soportar el ciclo
  reservar–cancelar–reutilizar.
- **Prioridad:** Crítica.
- **Sprint asignado:** 4.
- **Dependencias:** TL-019.
- **Criterios de aceptación:** los efectos posteriores reflejan exactamente las
  reservas activas y una operación inválida no los modifica.
- **Estado:** Pendiente.

<a id="tl-021"></a>
### TL-021 — Ejecutar consultas de disponibilidad

- **Descripción:** informar `DISPONIBLE` u `OCUPADO` usando estado activo y la
  función común de intersección.
- **Prioridad:** Alta.
- **Sprint asignado:** 4.
- **Dependencias:** TL-017, TL-019, TL-020.
- **Criterios de aceptación:** consulta libre, ocupada y consecutiva producen el
  resultado esperado sin modificar estado.
- **Estado:** Pendiente.

<a id="tl-022"></a>
### TL-022 — Ejecutar el listado ordenado

- **Descripción:** mostrar nombre y reservas activas por inicio, con desempate
  determinista.
- **Prioridad:** Alta.
- **Sprint asignado:** 4.
- **Dependencias:** TL-019, TL-020.
- **Criterios de aceptación:** datos insertados fuera de orden aparecen ordenados
  y las reservas canceladas no se muestran.
- **Estado:** Pendiente.

<a id="tl-023"></a>
### TL-023 — Estabilizar salida y códigos de proceso

- **Descripción:** fijar mensajes de éxito, consulta, error, `stdout`, `stderr` y
  códigos para que sean un contrato comprobable.
- **Prioridad:** Alta.
- **Sprint asignado:** 4.
- **Dependencias:** TL-020, TL-021, TL-022.
- **Criterios de aceptación:** el formato está documentado y las ejecuciones
  repetidas generan resultados deterministas.
- **Estado:** Pendiente.

## Sprint 5: pruebas y reproducibilidad

<a id="tl-024"></a>
### TL-024 — Completar el corpus de escenarios

- **Descripción:** crear entradas válidas, léxicas, sintácticas, semánticas y de
  borde, junto con salidas y códigos esperados.
- **Prioridad:** Crítica.
- **Sprint asignado:** 5.
- **Dependencias:** TL-023.
- **Criterios de aceptación:** todos los casos de la estrategia de pruebas tienen
  archivo, objetivo, oráculo y clasificación, sin escenarios redundantes.
- **Estado:** Pendiente.

<a id="tl-025"></a>
### TL-025 — Implementar runner y `make test`

- **Descripción:** ejecutar cada escenario, capturar ambos flujos y código,
  comparar con el oráculo y resumir aprobados/fallidos.
- **Prioridad:** Crítica.
- **Sprint asignado:** 5.
- **Dependencias:** TL-007, TL-024.
- **Criterios de aceptación:** `make test` devuelve cero solo si todos los casos
  coinciden y señala de forma útil cualquier diferencia.
- **Estado:** Pendiente.

<a id="tl-026"></a>
### TL-026 — Verificar memoria y compilación limpia

- **Descripción:** revisar advertencias, propiedad de cadenas/nodos y recursos en
  rutas normales y de error con las herramientas disponibles.
- **Prioridad:** Alta.
- **Sprint asignado:** 5.
- **Dependencias:** TL-025.
- **Criterios de aceptación:** compilación sin advertencias relevantes, pruebas
  completas y verificación de memoria documentada en un entorno compatible.
- **Estado:** Pendiente.

<a id="tl-027"></a>
### TL-027 — Documentar instalación y uso reproducible

- **Descripción:** completar README con dependencias, versiones probadas,
  compilación, ejecución, pruebas, limpieza y solución de problemas esencial.
- **Prioridad:** Alta.
- **Sprint asignado:** 5.
- **Dependencias:** TL-005, TL-025, TL-026.
- **Criterios de aceptación:** otra persona puede reproducir construcción y
  pruebas desde una copia limpia siguiendo solo el README.
- **Estado:** Pendiente.

## Sprint 6: entrega y defensa

<a id="tl-028"></a>
### TL-028 — Elaborar el informe LNCS

- **Descripción:** redactar título, autores, resumen, palabras clave,
  introducción, antecedentes, desarrollo, arquitectura, implementación, pruebas,
  conclusiones y referencias reales.
- **Prioridad:** Crítica.
- **Sprint asignado:** 6.
- **Dependencias:** TL-025, TL-027.
- **Criterios de aceptación:** compila en formato LNCS; cada referencia se cita,
  figuras/tablas/código tienen epígrafe y referencia previa, y los resultados
  coinciden con ejecuciones reales.
- **Estado:** Pendiente.

<a id="tl-029"></a>
### TL-029 — Preparar demostración y defensa

- **Descripción:** seleccionar caso válido y errores, preparar guion y ensayar
  problema, frontend, semántica, backend, pruebas y conclusiones.
- **Prioridad:** Crítica.
- **Sprint asignado:** 6.
- **Dependencias:** TL-025, TL-028.
- **Criterios de aceptación:** la demo se ejecuta en el entorno de presentación y
  la exposición ensayada no supera 15 minutos.
- **Estado:** Pendiente.

<a id="tl-030"></a>
### TL-030 — Ejecutar revisión final de trazabilidad

- **Descripción:** contrastar requisitos, código, pruebas, roadmap, guía,
  backlog, informe y demo; corregir estados o contradicciones.
- **Prioridad:** Crítica.
- **Sprint asignado:** 6.
- **Dependencias:** TL-028, TL-029.
- **Criterios de aceptación:** cada requisito tiene evidencia accesible, no hay
  funcionalidades pendientes declaradas como terminadas y el alcance sigue
  limitado a una agenda, un recurso y un día.
- **Estado:** Pendiente.
