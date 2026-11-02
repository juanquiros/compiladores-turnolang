# Trazabilidad final de TurnoLang

Revisión ejecutada el 2 de noviembre de 2026. “Cubierto” indica evidencia
versionada y comprobada; “Pendiente humano” identifica una condición que no
puede cerrarse sin datos o ejecución de los integrantes.

| Requisito | Componente principal | Prueba o evidencia | Sección del informe | Paso de demo | Estado |
|---|---|---|---|---|---|
| Cabecera única `AGENDA` | `lexer.l`, `parser.y`, `ast.c` | Frontend: cabecera válida, ausente y duplicada | Lenguaje y gramática | Programa válido | Cubierto |
| Reserva con ID e intervalo | `parser.y`, `ast.c`, `agenda.c` | Frontend, semántica e intérprete: reserva válida | Lenguaje; implementación | Programa válido | Cubierto |
| Horario con forma `HH:MM` | `lexer.l` | Frontend: variantes mal formadas | Fundamentos; implementación | Error léxico | Cubierto |
| Rango `00:00–23:59` | `semantica.c` | Semántica: fuera de rango y límites | Semántica | Explicación posterior al error léxico | Cubierto |
| Intervalo creciente y no vacío | `semantica.c` | Semántica: vacío e invertido | Semántica | Preguntas de defensa | Cubierto |
| Identificador activo único | `semantica.c`, `agenda.c` | Semántica: duplicado y reutilización | Semántica | Programa válido | Cubierto |
| No superposición | `agenda.c`, `semantica.c` | Parcial, contenido, contenedor y consecutivas | Semántica; evaluación | Error semántico | Cubierto |
| Cancelación existente | `semantica.c`, `agenda.c` | Cancelación válida, inexistente y doble | Semántica; evaluación | Programa válido | Cubierto |
| Consulta `LIBRE` sin mutación | `semantica.c`, `interprete.c` | Disponible, ocupado y continuidad | Implementación; evaluación | Programa válido | Cubierto |
| `LISTAR` activos ordenados | `agenda.c`, `interprete.c` | Listado ordenado, vacío y múltiple | Arquitectura; evaluación | Programa válido | Cubierto |
| Frontend bloquea backend | `main.c`, `parser.y` | Error léxico y sintáctico tardío | Implementación; evaluación | Errores léxico y sintáctico | Cubierto |
| Acciones Bison construyen representación | `parser.y`, `ast.c` | Casos válidos y errores tardíos con liberación | Implementación: frontend | Diagrama AST | Cubierto |
| Diagnósticos con etapa y línea | `lexer.l`, `parser.y`, `semantica.c` | Oráculos completos de `stderr` | Implementación; evaluación | Tres errores | Cubierto |
| AST tipado y liberable | `ast.h`, `ast.c`, destructores de Bison | Construcción en todos los casos; revisión estática | Arquitectura; implementación | Diagrama AST | Cubierto con limitación dinámica |
| Construcción reproducible | `Makefile`, `.gitattributes` | Limpia, incremental, paralela y 68/68 | Construcción reproducible | `make test` | Cubierto en Windows/Git Bash |
| Informe LNCS auténtico | `informe/main.tex`, clase y estilo oficiales | Compilación y revisión visual del PDF | Documento completo | Referencia al informe | Cubierto técnicamente |
| Bibliografía verificable | `informe/referencias.bib` | Todas las citas resueltas y fuentes oficiales/editoriales | Referencias | Preguntas de defensa | Cubierto |
| Autoría y afiliación definitivas | Encabezado de `main.tex` | Autores, universidad, carrera, asignatura y docente confirmados | Portada | No aplica | Cubierto |
| Defensa menor o igual a 15 min | `docs/defensa/GUION_15_MIN.md` | Plan de 14:30; tabla de ensayo vacía | Limitaciones | Demo completa | Pendiente humano |
| Alcance sin funcionalidades ficticias | README, backlog, seguimiento, informe | Revisión cruzada de documentos y código | Limitaciones | Cierre | Cubierto |

## Resultado de la revisión

- No se detectaron funcionalidades documentadas como implementadas sin código o
  prueba asociada.
- El alcance sigue limitado a una agenda, un recurso, un día y memoria volátil.
- La ausencia de Valgrind/ASan ejecutable se mantiene como limitación, no como
  prueba aprobada.
- El Sprint 6 mantiene una única condición pendiente: ejecutar y registrar el
  ensayo humano cronometrado de la defensa.
