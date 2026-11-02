# Seguimiento de TurnoLang

## Tablero actual

| Campo | Estado basado en evidencia |
|---|---|
| Sprint actual | Sprint 6 — Entrega y defensa, en progreso |
| Estado general | Informe LNCS compilado, defensa preparada y trazabilidad revisada; faltan datos de autoría y ensayo humano. |
| Progreso del backlog | 28 tareas completadas, 0 pendientes, 2 en progreso, 0 bloqueadas. |
| Próximo objetivo | Confirmar metadatos del informe y registrar un ensayo menor o igual a 15 minutos. |

## Cierre de sprints

| Sprint | Estado | Evidencia de cierre |
|---|---|---|
| Sprint 0 — Definición y preparación | Completado | Diseño, guía, trazabilidad y herramientas verificadas. |
| Sprint 1 — Compilación | Completado | Construcción reproducible y 5 pruebas smoke. |
| Sprint 2 — Análisis léxico y sintáctico | Completado | Frontend, diagnósticos y 23 pruebas. |
| Sprint 3 — Estructuras internas y semántica | Completado | AST, agenda, reglas y 21 pruebas. |
| Sprint 4 — Intérprete completo | Completado | Backend y 15 escenarios funcionales. |
| Sprint 5 — Pruebas y reproducibilidad | Completado | 68 comprobaciones, runner integral, análisis de memoria y documentación. |
| Sprint 6 — Entrega y defensa | En progreso | PDF LNCS, demo y matriz disponibles; autoría y ensayo humano pendientes. |

## Actividades completadas

- [x] TL-001 a TL-023 — definición, frontend, semántica e intérprete.
- [x] [TL-024 — Completar el corpus de escenarios](BACKLOG.md#tl-024).
- [x] [TL-025 — Implementar runner y `make test`](BACKLOG.md#tl-025).
- [x] [TL-026 — Verificar memoria y compilación limpia](BACKLOG.md#tl-026).
- [x] [TL-027 — Documentar instalación y uso reproducible](BACKLOG.md#tl-027).
- [x] [TL-030 — Ejecutar revisión final de trazabilidad](BACKLOG.md#tl-030).

## Actividades en progreso

- [ ] [TL-028 — Elaborar el informe LNCS](BACKLOG.md#tl-028): falta
  completar autoría, afiliación y contacto confirmados.
- [ ] [TL-029 — Preparar demostración y defensa](BACKLOG.md#tl-029): falta
  cronometrar y registrar el ensayo humano en el entorno de presentación.

Sprint 6 fue ejecutado hasta el límite verificable sin intervención de los
integrantes. El informe compiló en LNCS y fue revisado visualmente; la demo se
ejecutó con los casos seleccionados; y la trazabilidad quedó consolidada. No se
cierra el sprint porque no se inventan datos de autoría ni un ensayo humano.

## Entorno verificado

| Componente | Versión real | Procedencia |
|---|---|---|
| Sistema operativo | Windows 11, NT 10.0.26200.0 | Entorno local. |
| Shell | GNU Bash 5.3.15 | Git for Windows. |
| Flex | 2.6.4 | `winflexbison` 2.5.25 mediante Scoop. |
| Bison | GNU Bison 3.8.2 | `winflexbison` 2.5.25 mediante Scoop. |
| GCC | 15.2.0 | Scoop / MinGW-w64. |
| GNU Make | 4.4.1 | Scoop. |

No se verificó otro sistema operativo. WSL solo contiene la distribución
interna `docker-desktop`; no existe Ubuntu instalado. El cliente Docker está
presente, pero su motor no estaba iniciado.

## Evidencia del Sprint 5

| Comando o comprobación | Resultado real |
|---|---|
| Línea base previa | `make clean && make && make test`: 64/64, sin advertencias normales. |
| Suite final normal | 68 aprobadas, 0 fallidas. |
| Construcción incremental | Segunda invocación de `make`: sin trabajo pendiente. |
| Construcción paralela | `make clean && make -j2 && make test`: 68/68. |
| Limpieza | Eliminó `build/` y `bin/`; fuentes, scripts y documentación preservados. |
| Modo intérprete | Salida completa igual al oráculo; código 0. |
| `--solo-sintaxis` | Salida académica exacta; código 0. |
| `--solo-semantica` | Salida académica exacta; código 0. |
| Falla inducida | Una copia temporal del oráculo con una línea extra fue rechazada por `cmp`. |
| Scripts | Los seis scripts aprobaron `bash -n`. |

Resumen integral real:

```text
Sprint 1: 5
Sprint 2: 23
Sprint 3: 21
Sprint 4: 15
Sprint 5: 4
TOTAL: 68
APROBADAS: 68
FALLIDAS: 0
```

## Cobertura agregada

Antes de sumar casos se contrastó el corpus con los bordes requeridos. Ya
existían límites `00:00`/`23:59`, espacios, cabecera sola, reservas consecutivas,
listados intercalados, consulta ocupada con continuación y errores tardíos.

Solo se incorporaron cuatro comprobaciones no redundantes:

1. archivo completamente vacío;
2. archivo válido sin salto final;
3. ruta de entrada con espacios; y
4. detección de una diferencia inducida en el oráculo.

La relación requisito–componente–caso–resultado está en
[`../MATRIZ_PRUEBAS.md`](../MATRIZ_PRUEBAS.md).

## Consolidación del runner

`make test` invoca `scripts/test_all.sh`. Este conserva y ejecuta las suites de
los Sprints 1 a 4 y agrega `test_calidad.sh`. El runner muestra toda la evidencia,
cuenta las líneas `[OK]`, contrasta cada cantidad con su total declarado y
devuelve código no cero si una suite falla o queda incompleta.

Frontend y semántica ahora comparan las salidas académicas completas contra
oráculos versionados. Los errores exigen código `1`, cantidad exacta de líneas,
etapa única, línea, motivo y ausencia de resultados funcionales. El intérprete
mantiene comparación completa de ambos flujos y códigos.

## Verificación de memoria

### Herramientas

- **Valgrind:** no instalado.
- **ASan/UBSan:** el compilador aceptó los flags, pero el enlazador informó
  `cannot find -lasan` y `cannot find -lubsan`.
- **GCC `-fanalyzer`:** ejecutado con código de salida cero.

Los módulos propios no produjeron advertencias de `-fanalyzer`. El código
generado produjo cinco avisos, cuatro clases distintas, en caminos de pila de
Bison y asignación/fallo de Flex. Se inspeccionaron las rutas generadas: Bison
libera su pila en el retorno común y Flex llama a `YY_FATAL_ERROR` ante fallos de
asignación. No se modificó ni silenció código generado.

También se revisaron propiedad de cadenas Flex/Bison, destructores, símbolo
inicial, AST, copias de agenda, nodos cancelados, vistas temporales, scanner,
archivo y finalización semántica anticipada. Las pruebas ejercitan esas rutas.

### Limitación

No hubo verificación dinámica con Valgrind o sanitizers. La revisión está
completada según las herramientas disponibles, pero esa incertidumbre debe
mencionarse en el informe y, si se dispone de Linux durante Sprint 6, puede
repetirse allí como evidencia adicional.

La redirección `/dev/full` de Git Bash no transmite de forma confiable un error
al ejecutable nativo Windows; no se presentó como prueba de fallo de escritura.

El detalle se conserva en
[`../RESULTADOS_PRUEBAS.md`](../RESULTADOS_PRUEBAS.md).

## Problemas encontrados y correcciones

1. Las suites de frontend y semántica podían aceptar el texto esperado junto
   con líneas adicionales. Se reemplazaron búsquedas parciales por comparación
   completa en los caminos válidos y por forma estricta en los diagnósticos.
2. `make test` no mostraba un resumen global. Se incorporó un runner coordinador
   sin eliminar los scripts existentes.
3. Faltaban archivo vacío, ausencia de salto final y ruta con espacios. Se
   agregaron como casos temporales reproducibles, sin duplicar fixtures.
4. MinGW no incluye las bibliotecas sanitizer. Se registró el fallo real y se
   utilizó `-fanalyzer` como evidencia estática alternativa.
5. `/dev/full` parecía ofrecer una prueba de escritura, pero el comportamiento
   de traducción de Git Bash no era verificable para el binario nativo. Se
   descartó el cambio especulativo y se documentó la limitación.
6. Una clonación con conversión automática podía cambiar a `CRLF` los oráculos
   y códigos esperados. Se agregó `.gitattributes` para fijar `LF` en los
   archivos ejecutables y comparables.

No se detectaron defectos funcionales que requirieran cambiar el lenguaje o el
intérprete.

## Decisiones relevantes

| Decisión | Justificación | Consecuencia |
|---|---|---|
| Mantener las cuatro suites existentes. | Conserva trazabilidad por sprint. | `test_all.sh` solo coordina y resume. |
| Agregar únicamente bordes faltantes. | Evita inflar métricas con duplicados. | El total aumenta de 64 a 68. |
| Versionar códigos y salidas académicas comunes. | Reduce falsos positivos. | Todos los modos tienen oráculo explícito. |
| Generar en temporal los casos especiales. | Garantiza archivo realmente vacío, sin `\n` y ruta con espacios. | No se necesitan fixtures artificiales. |
| No editar código Flex/Bison generado. | Se regenera desde sus fuentes. | Los avisos estáticos se documentan, no se ocultan. |
| Fijar `LF` mediante `.gitattributes`. | Los scripts y oráculos se comparan desde Git Bash. | Clonaciones Windows conservan bytes reproducibles. |

## Registro breve de avances

| Fecha | Avance | Evidencia / resultado |
|---|---|---|
| 2026-10-09 | Definición académica inicial. | Roadmap y guía. |
| 2026-10-29 | Sprints 1 a 3 completados. | Frontend, AST, semántica y 49 pruebas. |
| 2026-11-02 | Sprint 4 completado. | Intérprete y 64 pruebas acumuladas. |
| 2026-11-02 | Corpus y runner consolidados. | 68/68 y falla inducida detectada. |
| 2026-11-02 | Calidad y reproducibilidad verificadas. | Builds normal/incremental/paralelo y evidencia de memoria. |
| 2026-11-02 | Sprint 6 ejecutado parcialmente. | PDF LNCS revisado, demo preparada, 68/68 y trazabilidad final; pendientes humanos registrados. |

## Retrospectiva — Sprint 5

- **Qué funcionó:** revisar primero la matriz evitó agregar pruebas redundantes;
  reutilizar las suites conservó la trazabilidad.
- **Qué dificultades aparecieron:** el entorno MinGW carece de runtimes
  sanitizer y el código generado produce avisos estáticos que requieren
  distinguir fuente propia de salida de herramientas.
- **Qué debe mejorarse:** si se dispone de Linux, ejecutar Valgrind o ASan antes
  de la entrega para reducir la incertidumbre dinámica.
- **Qué continuaba al cierre del Sprint 5:** TL-028 a TL-030: informe LNCS,
  referencias reales, demo, defensa y revisión final. En ese momento el Sprint
  6 todavía no se había iniciado.

## Revisión — Sprint 6

- **Qué se completó:** TL-030, fuentes y PDF LNCS, referencias verificables,
  figuras técnicas, demo y material de preguntas.
- **Qué se verificó:** compilación del informe por dos vías, revisión visual de
  ocho páginas, ejecución de los cuatro pasos de demo y nueva corrida 68/68.
- **Qué impide el cierre:** faltan autores, institución, correos y ORCID
  confirmados, además del ensayo humano cronometrado en el equipo de exposición.
