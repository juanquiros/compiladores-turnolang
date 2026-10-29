# Seguimiento Scrum de TurnoLang

## Propósito

Scrum es un marco de trabajo iterativo que organiza un producto en avances
pequeños e inspeccionables. En TurnoLang se usa una versión simplificada para un
proyecto académico: no se simulan cargos empresariales ni ceremonias sin valor.
El objetivo es saber qué se intenta construir, qué evidencia existe y cuál es el
siguiente incremento verificable.

## Conceptos utilizados

- **Sprint:** ciclo de trabajo con un objetivo concreto. Termina cuando existe
  un entregable que se puede inspeccionar; aquí no se le asignan fechas
  ficticias.
- **Product Backlog:** lista priorizada de todo el trabajo necesario para
  completar TurnoLang. [`BACKLOG.md`](BACKLOG.md) es la fuente principal del
  estado de cada tarea.
- **Sprint Backlog:** subconjunto del Product Backlog elegido para cumplir el
  objetivo de un sprint. [`SPRINTS.md`](SPRINTS.md) agrupa las tareas por sprint
  sin redefinirlas.
- **Historia de usuario:** necesidad expresada desde quien obtiene valor. Por
  ejemplo: «Como estudiante, quiero ejecutar un archivo `.tl` y recibir errores
  con etapa y línea para demostrar el procesamiento del lenguaje».
- **Tarea:** unidad concreta de trabajo técnico o documental necesaria para una
  historia o entregable. Cada tarea TurnoLang tiene ID, prioridad, sprint,
  dependencias, criterio de aceptación y estado.
- **Criterio de aceptación:** condición observable que permite decidir si una
  tarea cumple su propósito. «El archivo existe» no alcanza cuando el resultado
  debe compilar o ejecutar.
- **Definition of Done (DoD):** condiciones comunes que debe cumplir cualquier
  tarea antes de marcarse `Completado`.
- **Retrospectiva:** revisión breve al cerrar un sprint para conservar lo que
  funcionó, identificar dificultades y acordar una mejora concreta.

## Cómo se aplicará

El proyecto tiene siete sprints, desde definición hasta defensa. Cada sprint
técnico debe dejar evidencia ejecutable: primero una construcción mínima, luego
un frontend, después reglas semánticas, el intérprete y finalmente pruebas
reproducibles. El informe y la demo se preparan sobre resultados reales, no
sobre funcionalidades proyectadas.

No se exige una persona por rol. Quien trabaje en el proyecto prioriza el
backlog, implementa, verifica y registra la evidencia. Si participan varias
personas, pueden repartirse tareas, pero comparten la misma DoD.

## Definition of Done

Una tarea puede marcarse `Completado` únicamente cuando:

- satisface todos sus criterios de aceptación;
- no amplía el alcance definido sin una decisión registrada;
- la documentación y los nombres relacionados son consistentes;
- las comprobaciones aplicables se ejecutaron y su resultado quedó registrado;
- no se presentan advertencias conocidas como éxitos; y
- el cambio está listo para ser revisado en Git.

Para tareas de código también se requiere compilación limpia y pruebas
pertinentes. Para una tarea puramente documental se requiere revisión de
estructura, enlaces, terminología y concordancia con el repositorio. «En
progreso» significa que hay trabajo iniciado; «Bloqueado» exige anotar la causa
y la condición de desbloqueo.

## Cómo actualizar el seguimiento

1. Seleccionar el siguiente ID de [`BACKLOG.md`](BACKLOG.md) respetando
   dependencias y prioridad.
2. Cambiar su estado a `En progreso`; no copiar la tarea a otro archivo.
3. Actualizar el sprint actual y las casillas de
   [`SEGUIMIENTO.md`](SEGUIMIENTO.md) con enlaces al ID.
4. Registrar decisiones que cambien un contrato del lenguaje antes de modificar
   casos esperados.
5. Ejecutar la verificación indicada en el criterio de aceptación.
6. Cambiar a `Completado` solo con evidencia. Si no puede continuar, usar
   `Bloqueado` y registrar el motivo.
7. Al cerrar el sprint, completar la retrospectiva y comprobar las evidencias
   pedidas en [`SPRINTS.md`](SPRINTS.md).

Los estados permitidos son exactamente: `Pendiente`, `En progreso`, `Bloqueado`
y `Completado`. La evidencia real tiene prioridad sobre una estimación o una
declaración previa.
