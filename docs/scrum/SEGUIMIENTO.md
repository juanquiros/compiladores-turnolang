# Seguimiento de TurnoLang

## Tablero actual

| Campo | Estado basado en evidencia |
|---|---|
| Sprint actual | Sprint 0 — Definición y preparación |
| Estado general | Documentación de diseño lista; preparación del entorno pendiente. No existe implementación. |
| Progreso del backlog | 4 tareas completadas, 26 pendientes, 0 en progreso, 0 bloqueadas. |
| Próximo objetivo | Verificar Flex, Bison, GNU Make, GCC y shell en el entorno elegido. |

## Actividades completadas

- [x] [TL-001 — Revisar requisitos y delimitar el alcance](BACKLOG.md#tl-001)
- [x] [TL-002 — Cerrar la especificación del lenguaje](BACKLOG.md#tl-002)
- [x] [TL-003 — Definir arquitectura, semántica y pruebas](BACKLOG.md#tl-003)
- [x] [TL-004 — Preparar guía y seguimiento académico](BACKLOG.md#tl-004)

La evidencia es `docs/PROPUESTA_ROADMAP.md`, `docs/GUIA_ESTUDIO.md` y los cuatro
documentos de esta carpeta. Estos completados acreditan planificación, no código
ni pruebas del intérprete.

## Actividades pendientes inmediatas

- [ ] [TL-005 — Verificar el entorno de herramientas](BACKLOG.md#tl-005)
- [ ] [TL-006 — Crear la estructura técnica mínima](BACKLOG.md#tl-006)
- [ ] [TL-007 — Automatizar generación y compilación](BACKLOG.md#tl-007)
- [ ] [TL-008 — Integrar un ejecutable mínimo](BACKLOG.md#tl-008)

El resto del trabajo permanece priorizado en
[`BACKLOG.md`](BACKLOG.md); no se reproduce aquí para evitar dos fuentes de
estado.

## Actividades bloqueadas

No hay tareas bloqueadas. TL-006 y las siguientes están **pendientes** por su
dependencia con TL-005; esto no constituye un bloqueo mientras la verificación
del entorno pueda realizarse normalmente.

## Riesgos identificados

| Riesgo | Impacto | Mitigación / señal de control |
|---|---|---|
| Las herramientas GNU no están disponibles juntas en el entorno elegido. | Impide una construcción reproducible. | Resolver TL-005 antes de crear el Makefile y documentar un único entorno probado. |
| Flex divide una hora mal formada en varios lexemas. | Clasifica mal un error léxico como sintáctico. | Agregar reglas de captura específicas y el caso `error_hora_formato.tl`. |
| Las acciones de Bison incorporan reglas de agenda. | Mezcla fases y duplica lógica. | Limitar acciones a construir AST y revisar la interfaz del módulo semántico. |
| El estado cambia antes de completar la validación. | Una instrucción fallida deja efectos parciales. | Contrato validar-sin-mutar y ejecutar-después. |
| Los mensajes cambian después de crear oráculos. | Pruebas frágiles o falsos fallos. | Cerrar TL-023 antes de completar el corpus. |
| Se redacta el informe con resultados previstos. | Incumple honestidad académica. | TL-028 depende de pruebas ejecutadas TL-025. |

## Decisiones relevantes

| Decisión | Justificación | Consecuencia |
|---|---|---|
| Interpretar en lugar de generar código. | El dominio pide efectos y consultas inmediatas; mantiene un backend demostrable y acotado. | La salida de consola es resultado, no lenguaje destino. |
| Usar Flex y Bison. | Son requisitos explícitos y hacen visibles lexer, parser y acciones. | El Makefile debe declarar correctamente sus archivos generados. |
| Mantener un AST mínimo. | Separa frontend/backend y conserva el orden sin una jerarquía compleja. | Lista tipada con unión, línea y liberación explícita. |
| Validar por sentencia antes de ejecutar. | Las reglas dependen del estado secuencial y no deben duplicarse. | El validador no muta; el ejecutor solo recibe operaciones válidas. |
| Usar intervalos `[inicio, fin)`. | Permite reservas consecutivas sin un caso especial. | La intersección usa dos desigualdades estrictas. |
| Permitir reutilizar un ID cancelado. | La unicidad aplica a reservas activas y simplifica el estado observable. | Cancelar dos veces falla por ausencia de reserva activa. |
| Tratar `25:00` como semántico y `9:00` como léxico. | Separa forma de token y validez del valor. | Flex reconoce cuatro dígitos con `:`; C valida rangos. |

## Registro breve de avances

| Fecha | Avance | Evidencia / resultado |
|---|---|---|
| 2026-10-09 | Revisión de la propuesta inicial y cierre de decisiones de diseño. | `PROPUESTA_ROADMAP.md` amplía alcance, gramática, arquitectura, pruebas y trazabilidad. |
| 2026-10-09 | Preparación de material de estudio. | `GUIA_ESTUDIO.md` explica el flujo completo y la defensa. |
| 2026-10-09 | Creación del seguimiento simplificado. | Backlog único, siete sprints y este tablero. |

## Plantilla de retrospectiva

Completar al finalizar cada sprint, reemplazando los textos guía con evidencia
breve.

### Retrospectiva — Sprint N

- **Qué funcionó:** prácticas o decisiones que ayudaron a producir el incremento.
- **Qué dificultades aparecieron:** problemas técnicos observados, no supuestos.
- **Qué debe mejorarse:** una acción concreta y verificable para el sprint
  siguiente.
- **Qué continúa en el próximo sprint:** IDs no completados o trabajo derivado,
  con su estado actualizado en el backlog.
