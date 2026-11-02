# Guion de defensa de TurnoLang — máximo 15 minutos

## Condiciones

- Duración planificada: **14 min 30 s**; margen: 30 s.
- Participantes: `Integrante 1` e `Integrante 2` hasta confirmar nombres.
- No leer código completo: mostrar decisiones, flujo y evidencia.
- Si una ejecución se demora, pasar a la salida esperada versionada y explicar
  el concepto sin exceder el tiempo.

## Guion cronometrado

| Tiempo | Responsable | Contenido y apoyo |
|---|---|---|
| 0:00–1:10 | Integrante 1 | Problema, objetivo académico y alcance: una agenda, un recurso, un día, sin persistencia. |
| 1:10–2:20 | Integrante 1 | Sintaxis del DSL: `AGENDA`, `RESERVAR`, `CANCELAR`, `LIBRE`, `LISTAR`; intervalos `[inicio, fin)`. |
| 2:20–4:00 | Integrante 1 | Frontend: Flex reconoce lexemas; Bison valida gramática y construye el AST. Mostrar la arquitectura. |
| 4:00–5:20 | Integrante 2 | AST mínimo: tipo, datos, línea y orden. Explicar propiedad de textos y liberación. |
| 5:20–7:00 | Integrante 2 | Semántica con estado: rango horario, intervalo, duplicado, superposición y cancelación. Secuencia `validar → aplicar → observar`. |
| 7:00–8:10 | Integrante 2 | Backend: mismo motor para modo semántico e interpretación; `LIBRE` y `LISTAR` producen salida. |
| 8:10–11:30 | Ambos | Demostración: caso válido, error léxico, sintáctico y semántico. Alternar ejecución y explicación. |
| 11:30–12:50 | Integrante 1 | Calidad: `make test`, oráculos completos y resumen 68/68. |
| 12:50–13:50 | Integrante 2 | Limitaciones reales: alcance acotado y falta de validación dinámica de memoria en Linux. |
| 13:50–14:30 | Integrante 1 | Conclusión: cadena completa, separación de responsabilidades y trazabilidad. |

## Frases de transición

- **Integrante 1 → Integrante 2:** “El frontend ya reconoció el programa; ahora
  mostramos qué representación entrega al backend y cómo se valida su sentido.”
- **Integrante 2 → demo:** “Estas reglas se observan mejor ejecutando un caso
  correcto y tres fallas ubicadas en etapas distintas.”
- **Demo → pruebas:** “Los cuatro ejemplos son visibles, pero no son la única
  evidencia: el runner repite 68 comprobaciones deterministas.”

## Ensayo obligatorio pendiente

El guion está dimensionado a 14:30, pero la aceptación requiere un ensayo humano
real. Registrar fecha, participantes, duración y ajustes después de ensayarlo:

| Fecha | Participantes | Duración | Ajustes |
|---|---|---:|---|
| [PENDIENTE] | [PENDIENTE] | [PENDIENTE] | [PENDIENTE] |
