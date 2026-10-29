# Plan de sprints de TurnoLang

Los sprints se cierran por evidencia, no por una fecha inventada. La definición
y el estado de cada tarea se mantienen únicamente en
[`BACKLOG.md`](BACKLOG.md).

## Sprint 0 — Definición y preparación

- **Objetivo:** contar con un diseño coherente, trazable y realizable, y confirmar
  que el entorno elegido dispone de todas las herramientas.
- **Tareas:** [TL-001](BACKLOG.md#tl-001),
  [TL-002](BACKLOG.md#tl-002), [TL-003](BACKLOG.md#tl-003),
  [TL-004](BACKLOG.md#tl-004) y [TL-005](BACKLOG.md#tl-005).
- **Entregables:** propuesta/roadmap revisado, guía de estudio, documentación
  Scrum y registro de versiones/instalación del entorno.
- **Criterios de aceptación:** decisiones léxicas, sintácticas y semánticas sin
  contradicciones; arquitectura limitada a C, Flex, Bison, Make y shell; todos
  los requisitos tienen trabajo y prueba planificados; las herramientas
  responden en el entorno objetivo.
- **Evidencia requerida:** revisión de los seis documentos Markdown y salida real
  de los comandos de versión de Flex, Bison, Make y GCC. La documentación por sí
  sola no demuestra que el entorno esté listo.

## Sprint 1 — Compilación

- **Objetivo:** obtener la primera construcción reproducible del ejecutable.
- **Tareas:** [TL-006](BACKLOG.md#tl-006),
  [TL-007](BACKLOG.md#tl-007) y [TL-008](BACKLOG.md#tl-008).
- **Entregables:** estructura fuente mínima, Makefile y ejecutable integrado con
  scanner/parser mínimos.
- **Criterios de aceptación:** desde una limpieza, `make` genera y enlaza todo en
  el orden correcto; el ejecutable abre una entrada mínima; `make clean` no borra
  fuentes ni ejemplos.
- **Evidencia requerida:** transcripción o registro de `make clean`, `make`,
  ejecución mínima y segunda invocación de `make` sin reconstrucciones
  innecesarias.

## Sprint 2 — Análisis léxico y sintáctico

- **Objetivo:** reconocer por completo la forma del lenguaje y clasificar los
  errores del frontend.
- **Tareas:** [TL-009](BACKLOG.md#tl-009),
  [TL-010](BACKLOG.md#tl-010), [TL-011](BACKLOG.md#tl-011) y
  [TL-012](BACKLOG.md#tl-012).
- **Entregables:** `lexer.l`, `parser.y`, diagnósticos de frontend y primeros
  escenarios automatizados.
- **Criterios de aceptación:** cada construcción de la EBNF tiene una producción;
  un programa válido se acepta; símbolo/hora mal formada se reportan como
  léxicos; falta de `;` como sintáctico; no quedan conflictos Bison sin explicar.
- **Evidencia requerida:** salida de generación, ejecución de casos válidos e
  inválidos y códigos de retorno comparados automáticamente.

## Sprint 3 — Estructuras internas y semántica

- **Objetivo:** representar el programa y rechazar operaciones que contradigan
  las reglas de la agenda antes de modificar su estado.
- **Tareas:** [TL-013](BACKLOG.md#tl-013),
  [TL-014](BACKLOG.md#tl-014), [TL-015](BACKLOG.md#tl-015),
  [TL-016](BACKLOG.md#tl-016), [TL-017](BACKLOG.md#tl-017) y
  [TL-018](BACKLOG.md#tl-018).
- **Entregables:** AST mínimo, modelo de reservas y validadores con diagnósticos.
- **Criterios de aceptación:** se conserva el orden y línea de los nodos; horas,
  intervalos, duplicados, cancelaciones y cruces siguen el contrato; las reservas
  consecutivas y la reutilización posterior a cancelación se aceptan; el estado
  no cambia ante error.
- **Evidencia requerida:** casos de borde ejecutables, revisión de la función
  única de intersección y verificación de liberación de estructuras en rutas de
  éxito y fallo.

## Sprint 4 — Intérprete completo

- **Objetivo:** ejecutar en orden las operaciones válidas y producir resultados
  deterministas por consola.
- **Tareas:** [TL-019](BACKLOG.md#tl-019),
  [TL-020](BACKLOG.md#tl-020), [TL-021](BACKLOG.md#tl-021),
  [TL-022](BACKLOG.md#tl-022) y [TL-023](BACKLOG.md#tl-023).
- **Entregables:** backend con reserva, cancelación, disponibilidad, listado y
  contrato de salida/códigos.
- **Criterios de aceptación:** las instrucciones respetan el orden fuente;
  `LIBRE` no muta; `LISTAR` ordena solo activas; el primer error semántico detiene
  el recorrido; salidas y códigos son estables.
- **Evidencia requerida:** demostración de punta a punta que combine las cuatro
  sentencias, más resultados repetidos idénticos.

## Sprint 5 — Pruebas y reproducibilidad

- **Objetivo:** convertir los comportamientos especificados en evidencia
  automática y permitir que otra persona los reproduzca.
- **Tareas:** [TL-024](BACKLOG.md#tl-024),
  [TL-025](BACKLOG.md#tl-025), [TL-026](BACKLOG.md#tl-026) y
  [TL-027](BACKLOG.md#tl-027).
- **Entregables:** corpus completo, oráculos, runner, `make test`, revisión de
  memoria y README de uso.
- **Criterios de aceptación:** todos los casos mínimos y bordes esenciales se
  comparan en salida/código; una diferencia falla el objetivo; compilación sin
  advertencias relevantes; construcción y pruebas reproducibles desde limpio.
- **Evidencia requerida:** resumen completo de `make test`, una falla inducida
  que demuestre que el runner detecta diferencias, resultado de la herramienta
  de memoria disponible y reproducción siguiendo el README.

## Sprint 6 — Entrega y defensa

- **Objetivo:** presentar el proyecto con evidencia técnica, informe académico y
  una explicación de hasta 15 minutos.
- **Tareas:** [TL-028](BACKLOG.md#tl-028),
  [TL-029](BACKLOG.md#tl-029) y [TL-030](BACKLOG.md#tl-030).
- **Entregables:** informe LNCS compilado, guion y demo, matriz final revisada.
- **Criterios de aceptación:** el informe solo cita referencias y resultados
  reales; figuras, tablas y código están introducidos y titulados; la demo corre
  en el entorno de presentación; el ensayo no supera el máximo; cada requisito
  apunta a evidencia concreta.
- **Evidencia requerida:** PDF LNCS compilado, salida de la demo seleccionada,
  registro del ensayo cronometrado y lista final de trazabilidad revisada.

## Regla de transición

Un sprint no se considera finalizado porque sus archivos existan. Se cierra
cuando todas sus tareas están `Completado`, sus criterios se verificaron y la
evidencia requerida puede mostrarse. Si se adelanta trabajo de otro sprint, su
estado se actualiza en el backlog, pero no se oculta una dependencia pendiente.
