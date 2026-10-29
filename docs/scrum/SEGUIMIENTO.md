# Seguimiento de TurnoLang

## Tablero actual

| Campo | Estado basado en evidencia |
|---|---|
| Sprint actual | Sprint 1 — Compilación, finalizado |
| Estado general | Base técnica mínima compilable y pruebas smoke aprobadas. El intérprete todavía no está implementado. |
| Progreso del backlog | 8 tareas completadas, 22 pendientes, 0 en progreso, 0 bloqueadas. |
| Próximo objetivo | Iniciar Sprint 2 con TL-009: completar tokens y scanner sin avanzar todavía sobre semántica. |

## Cierre de sprints

| Sprint | Estado | Evidencia de cierre |
|---|---|---|
| Sprint 0 — Definición y preparación | Completado | Documentación revisada y herramientas verificadas: Flex 2.6.4, Bison 3.8.2, GCC 15.2.0, Make 4.4.1 y Bash 5.3.15. |
| Sprint 1 — Compilación | Completado | Construcción limpia, incremental y paralela; ejecutable mínimo; casos válido, inválido y archivo inexistente aprobados. |

## Actividades completadas

- [x] [TL-001 — Revisar requisitos y delimitar el alcance](BACKLOG.md#tl-001)
- [x] [TL-002 — Cerrar la especificación del lenguaje](BACKLOG.md#tl-002)
- [x] [TL-003 — Definir arquitectura, semántica y pruebas](BACKLOG.md#tl-003)
- [x] [TL-004 — Preparar guía y seguimiento académico](BACKLOG.md#tl-004)
- [x] [TL-005 — Verificar el entorno de herramientas](BACKLOG.md#tl-005)
- [x] [TL-006 — Crear la estructura técnica mínima](BACKLOG.md#tl-006)
- [x] [TL-007 — Automatizar generación y compilación](BACKLOG.md#tl-007)
- [x] [TL-008 — Integrar un ejecutable mínimo](BACKLOG.md#tl-008)

Los completados de Sprint 1 acreditan únicamente la integración mínima de
Flex, Bison, GCC, Make y `main.c`. No acreditan la gramática completa, el AST,
la semántica ni el intérprete.

## Actividades pendientes inmediatas

- [ ] [TL-009 — Implementar tokens y scanner](BACKLOG.md#tl-009)
- [ ] [TL-010 — Implementar gramática y parser](BACKLOG.md#tl-010)
- [ ] [TL-011 — Implementar diagnósticos del frontend](BACKLOG.md#tl-011)
- [ ] [TL-012 — Automatizar pruebas del frontend](BACKLOG.md#tl-012)

El resto del trabajo permanece priorizado en
[`BACKLOG.md`](BACKLOG.md); no se reproduce aquí para evitar dos fuentes de
estado.

## Actividades bloqueadas

No hay tareas bloqueadas. Sprint 2 no fue iniciado.

## Entorno verificado

| Componente | Versión detectada | Procedencia |
|---|---|---|
| Sistema operativo | Windows 11, versión NT 10.0.26200.0 | Entorno de ejecución local. |
| Shell | GNU Bash 5.3.15 | Git for Windows. |
| Flex | 2.6.4 | `winflexbison` 2.5.25 instalado con Scoop. |
| Bison | GNU Bison 3.8.2 | `winflexbison` 2.5.25 instalado con Scoop. |
| GCC | 15.2.0 | Paquete `gcc` de Scoop. |
| GNU Make | 4.4.1 | Paquete `make` de Scoop. |

Instalación realizada:

```powershell
scoop install gcc make winflexbison
```

No se declara otro sistema como verificado.

## Evidencia del Sprint 1

| Comando o comprobación | Resultado real |
|---|---|
| `make clean && make` | Aprobado; Bison y Flex generaron sus fuentes, GCC compiló sin advertencias y enlazó `bin/turnolang.exe`. |
| `./bin/turnolang examples/smoke_agenda.tl` | Aprobado; mensaje de análisis mínimo correcto y código 0. |
| Cabecera temporal sin `;` | Aprobado; Bison la rechazó y el proceso devolvió código no cero. |
| `./bin/turnolang examples/no_existe.tl` | Aprobado; diagnóstico claro y código 1. |
| Dos ejecuciones consecutivas de `make` | Aprobado; ambas informaron que no había trabajo por realizar. |
| `make clean` y comprobación de rutas | Aprobado; eliminó `build/` y `bin/` y preservó fuentes, ejemplo y script. |
| `make -j2` desde limpio | Aprobado; construcción paralela finalizada con código 0. |
| `make test` después de recompilar | Aprobado; cinco pruebas mínimas y código final 0. |

## Problemas encontrados

GNU Make define `CC=cc` de forma predeterminada. La asignación inicial
`CC ?= gcc` no la reemplazó y la primera compilación falló porque `cc` no existe
en el entorno verificado. Se corrigió el Makefile a `CC = gcc`, que sigue
permitiendo una sobrescritura desde la línea de comandos y usa GCC por defecto.

No quedaron problemas abiertos para Sprint 1.

## Riesgos identificados

| Riesgo | Impacto | Mitigación / señal de control |
|---|---|---|
| Flex divide una hora mal formada en varios lexemas durante Sprint 2. | Clasificaría mal un error léxico como sintáctico. | Implementar captura específica y el caso `error_hora_formato.tl` en TL-009/TL-012. |
| Las acciones de Bison incorporan reglas de agenda. | Mezcla fases y duplica lógica. | En Sprint 2, limitar acciones al reconocimiento; AST y semántica pertenecen a Sprint 3. |
| Se asume compatibilidad fuera del entorno probado. | La construcción puede no ser reproducible. | Mantener el README limitado a Windows 11 + Git Bash + Scoop hasta verificar otro entorno. |
| El estado cambia antes de completar la validación futura. | Una instrucción fallida dejaría efectos parciales. | Mantener el contrato validar-sin-mutar y ejecutar-después en Sprint 3/4. |
| Se redacta el informe con resultados previstos. | Incumple honestidad académica. | TL-028 continúa dependiendo de las pruebas ejecutadas de TL-025. |

## Decisiones relevantes

| Decisión | Justificación | Consecuencia |
|---|---|---|
| Interpretar en lugar de generar código. | El dominio pide efectos y consultas inmediatas; mantiene un backend demostrable y acotado. | La salida de consola es resultado, no lenguaje destino. |
| Usar Flex y Bison. | Son requisitos explícitos y hacen visibles lexer, parser y acciones. | El Makefile genera primero `parser.h`, requerido por el scanner. |
| Mantener Sprint 1 como subconjunto temporal. | Su objetivo es demostrar integración, no adelantar el frontend completo. | Solo se reconocen `AGENDA`, cadena y `;`. |
| Generar artefactos en `build/` y ejecutable en `bin/`. | Separa fuentes de productos y permite limpieza segura. | Ambos directorios están ignorados por Git y se recrean con Make. |
| Mantener un AST mínimo en Sprint 3. | Separa frontend/backend y conserva el orden sin una jerarquía compleja. | Sprint 1 no construye AST. |
| Usar intervalos `[inicio, fin)`. | Permite reservas consecutivas sin un caso especial. | La intersección futura usará dos desigualdades estrictas. |

## Registro breve de avances

| Fecha | Avance | Evidencia / resultado |
|---|---|---|
| 2026-10-09 | Revisión de la propuesta inicial y cierre de decisiones de diseño. | Roadmap, guía de estudio y seguimiento Scrum creados. |
| 2026-10-29 | Verificación e instalación del entorno técnico. | Versiones reales registradas; TL-005 completada y Sprint 0 cerrado. |
| 2026-10-29 | Implementación de la base técnica. | Fuentes Flex/Bison/C, Makefile, ejemplo, script smoke y README creados. |
| 2026-10-29 | Verificación del Sprint 1. | Construcción limpia, incremental y paralela; pruebas mínimas aprobadas; TL-006 a TL-008 completadas. |

## Retrospectiva — Sprint 1

- **Qué funcionó:** cerrar primero el entorno y declarar dependencias explícitas
  permitió comprobar la cadena Flex → Bison → GCC de punta a punta.
- **Qué dificultades aparecieron:** la variable incorporada `CC=cc` prevaleció
  sobre una asignación condicional del Makefile.
- **Qué debe mejorarse:** mantener en los siguientes sprints una prueba pequeña
  por cada token o producción incorporada y ejecutar siempre desde limpio.
- **Qué continúa en el próximo sprint:** TL-009 a TL-012, sin iniciar todavía
  AST, reglas semánticas ni operaciones de agenda.

## Plantilla de retrospectiva

Completar al finalizar cada sprint posterior.

### Retrospectiva — Sprint N

- **Qué funcionó:** prácticas o decisiones que ayudaron a producir el incremento.
- **Qué dificultades aparecieron:** problemas técnicos observados, no supuestos.
- **Qué debe mejorarse:** una acción concreta y verificable para el sprint
  siguiente.
- **Qué continúa en el próximo sprint:** IDs no completados o trabajo derivado,
  con su estado actualizado en el backlog.
