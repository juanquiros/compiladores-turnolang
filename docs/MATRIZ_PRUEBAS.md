# Matriz integral de pruebas de TurnoLang

Esta matriz relaciona los requisitos del lenguaje con evidencia automatizada.
Los estados corresponden a la ejecución integral del 2 de noviembre de 2026.
Los casos se agregaron por cobertura; no se duplicaron comportamientos ya
representados por una prueba equivalente.

## Análisis léxico

| Requisito | Componente | Comportamiento esperado | Evidencia | Resultado |
|---|---|---|---|---|
| Palabras reservadas | Flex | Reconoce las siete reservadas en mayúsculas. | `frontend/ok_todas_instrucciones.tl` | Aprobado |
| Identificadores válidos | Flex | Acepta letras, dígitos posteriores y `_`. | `frontend/ok_multiples_reservas.tl` | Aprobado |
| Identificador iniciado con número | Flex | Error léxico, línea 3, código 1. | `frontend/error_ident_inicia_numero.tl` | Aprobado |
| Identificador con guion | Flex | Error léxico, línea 3, código 1. | `frontend/error_ident_guion.tl` | Aprobado |
| Hora con forma `HH:MM` | Flex | Produce `TOK_HORA`, incluso si el valor queda fuera de rango. | `frontend/ok_hora_fuera_rango.tl` | Aprobado |
| Horas mal formadas | Flex | Rechaza cero faltante, separador y cantidad de minutos. | `frontend/error_hora_*.tl` | Aprobado |
| Cadena válida y sin cierre | Flex | Conserva contenido válido y rechaza comilla sin cierre. | `frontend/ok_cabecera.tl`, `frontend/error_cadena_sin_cierre.tl` | Aprobado |
| Carácter desconocido y ubicación | Flex | Informa etapa, lexema y línea sin añadir error sintáctico. | `frontend/error_simbolo.tl`, `interprete/error_lexico_tardio.tl` | Aprobado |

## Análisis sintáctico

| Requisito | Componente | Comportamiento esperado | Evidencia | Resultado |
|---|---|---|---|---|
| Cabecera obligatoria | Bison | Un programa sin `AGENDA` falla. | `frontend/error_sin_cabecera.tl` | Aprobado |
| Cabecera duplicada | Bison | La segunda cabecera se rechaza. | `frontend/error_cabecera_duplicada.tl` | Aprobado |
| Programa con solo cabecera | Bison/AST | La lista vacía de instrucciones es válida. | `smoke_agenda.tl`, `frontend/ok_cabecera.tl` | Aprobado |
| Todas las instrucciones | Bison | Reconoce reserva, consulta, cancelación y listado. | `frontend/ok_todas_instrucciones.tl` | Aprobado |
| Orden incorrecto | Bison | Rechaza tokens válidos en secuencia inválida. | `frontend/error_orden.tl` | Aprobado |
| Falta de `;` | Bison | Error sintáctico con código 1. | `frontend/error_sin_punto_y_coma.tl` | Aprobado |
| Instrucción incompleta | Bison | Rechaza una reserva sin todos sus elementos. | `frontend/error_reserva_incompleta.tl` | Aprobado |
| Archivo completamente vacío | Bison | Error sintáctico en línea 1, sin `stdout`. | Caso temporal de `test_calidad.sh` + `calidad/esperados/archivo_vacio.err` | Aprobado |
| Error posterior a nodos válidos | Bison/AST | No interpreta y libera el AST parcial. | `frontend/error_sintactico_despues_sentencia.tl`, `interprete/error_sintactico_tardio.tl` | Aprobado |

## Análisis semántico

| Requisito | Componente | Comportamiento esperado | Evidencia | Resultado |
|---|---|---|---|---|
| Nombre vacío | Semántica | Error en la línea de `AGENDA`. | `semantica/error_nombre_vacio.tl` | Aprobado |
| Hora fuera de rango | Semántica | Rechaza componentes fuera de `00:00-23:59`. | `semantica/error_hora_fuera_rango.tl` | Aprobado |
| Límites horarios | Semántica | Acepta `00:00` y `23:59`. | `semantica/ok_limites_horarios.tl` | Aprobado |
| Intervalo vacío | Semántica | Rechaza inicio igual a fin. | `semantica/error_intervalo_vacio.tl` | Aprobado |
| Intervalo invertido | Semántica | Rechaza inicio posterior al fin. | `semantica/error_intervalo_invertido.tl` | Aprobado |
| ID activo duplicado | Semántica/agenda | Rechaza la segunda reserva. | `semantica/error_identificador_duplicado.tl` | Aprobado |
| Cancelación inexistente | Semántica/agenda | Requiere una reserva activa. | `semantica/error_cancelacion_inexistente.tl` | Aprobado |
| Doble cancelación | Semántica/agenda | La segunda cancelación falla. | `semantica/error_doble_cancelacion.tl` | Aprobado |
| Superposición parcial | Agenda | Detecta cruce parcial. | `semantica/error_superposicion_parcial.tl` | Aprobado |
| Contención | Agenda | Detecta intervalo contenido y contenedor. | `semantica/error_superposicion_contenida.tl`, `error_superposicion_contiene.tl` | Aprobado |
| Intervalos consecutivos | Agenda | Compartir un extremo no es superposición. | `semantica/ok_consecutivas.tl` | Aprobado |
| Reutilización de ID | Semántica/agenda | Un ID cancelado puede reservarse otra vez. | `semantica/ok_reutilizacion_identificador.tl` | Aprobado |
| Consulta ocupada | Semántica | Es válida y no detiene el recorrido. | `semantica/ok_consulta_ocupada.tl` | Aprobado |
| Intervalo liberado | Semántica/agenda | Cancelar permite reutilizar la franja. | `semantica/ok_intervalo_liberado.tl` | Aprobado |

## Intérprete

| Requisito | Componente | Comportamiento esperado | Evidencia | Resultado |
|---|---|---|---|---|
| Reserva y listado | Intérprete | Muestra la reserva activa. | `interprete/ok_reserva_listado.tl` + oráculo | Aprobado |
| Listado ordenado | Agenda/intérprete | Ordena por hora, no por inserción. | `interprete/ok_listado_ordenado.tl` + oráculo | Aprobado |
| Cancelación | Agenda/intérprete | La reserva cancelada no aparece. | `interprete/ok_cancelacion.tl` + oráculo | Aprobado |
| Reutilización | Agenda/intérprete | Lista la nueva reserva del mismo ID. | `interprete/ok_reutilizacion_id.tl` + oráculo | Aprobado |
| Disponible | Intérprete | Informa `DISPONIBLE`. | `interprete/ok_disponible.tl` + oráculo | Aprobado |
| Ocupado | Intérprete | Informa `OCUPADO` con código 0. | `interprete/ok_ocupado.tl` + oráculo | Aprobado |
| Consecutivas | Intérprete | Lista ambos intervalos. | `interprete/ok_consecutivas.tl` + oráculo | Aprobado |
| Agenda vacía | Intérprete | Informa `(sin reservas)`. | `interprete/ok_agenda_vacia.tl` + oráculo | Aprobado |
| Múltiples listados | Intérprete | Cada salida refleja el estado de ese momento. | `interprete/ok_multiples_listados.tl` + oráculo | Aprobado |
| Detención semántica | Motor compartido | Código 1 y sin instrucciones posteriores. | `interprete/error_superposicion.tl` + oráculo | Aprobado |
| Salida previa a error | Motor compartido | Conserva resultado anterior y detiene después. | `interprete/error_despues_salida.tl` + oráculos | Aprobado |
| Frontend tardío | Main/frontend | Ninguna salida funcional si falla el archivo completo. | `interprete/error_lexico_tardio.tl`, `error_sintactico_tardio.tl` | Aprobado |
| Repetibilidad | Intérprete | Dos ejecuciones tienen código y flujos idénticos. | `verify_repeatability` en `test_interprete.sh` | Aprobado |

## Calidad y reproducibilidad

| Requisito | Comportamiento esperado | Evidencia | Resultado |
|---|---|---|---|
| Archivo sin salto final | EOF no requiere `\n`; código 0 y flujos vacíos. | Caso temporal de `test_calidad.sh` | Aprobado |
| Ruta con espacios | La ruta completa se abre y ejecuta. | Copia temporal de `ok_completo.tl` bajo una ruta con espacios | Aprobado |
| Oráculo alterado | Una línea extra debe hacer fallar `cmp`. | `verify_induced_failure` en `test_calidad.sh` | Aprobado |
| Separación de modos | Sintaxis y semántica tienen salidas completas versionadas. | `examples/esperados/solo_*.out` | Aprobado |
| Códigos de proceso | Éxito `0`, error `1`. | `examples/esperados/codigo_*.txt` usados por los runners | Aprobado |

## Bordes evaluados sin agregar duplicados

- Espacios y líneas en blanco ya aparecen en casi todos los ejemplos.
- `00:00` y `23:59` ya estaban cubiertos por `ok_limites_horarios.tl`.
- Los extremos compartidos ya estaban cubiertos en semántica e intérprete.
- Consulta ocupada seguida de operaciones válidas ya estaba cubierta por
  `ok_ocupado_continua.tl`.
- Listados antes y después de cancelar ya estaban cubiertos por
  `ok_multiples_listados.tl`.
- Los errores tardíos de frontend y el error semántico después de una salida ya
  tenían casos completos en Sprint 4.
