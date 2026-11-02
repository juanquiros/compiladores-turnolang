# Demostración reproducible de TurnoLang

Todos los comandos se ejecutan desde la raíz del repositorio en Git Bash. Antes
de exponer, usar una copia limpia y confirmar que las herramientas están en el
`PATH`.

## 1. Preparación

```bash
make clean
make
```

Concepto: Bison genera parser y encabezado; Flex genera scanner; GCC compila y
enlaza `bin/turnolang.exe`.

## 2. Programa válido completo

```bash
./bin/turnolang examples/interprete/ok_completo.tl
```

Salida esperada exacta, código 0:

```text
Franja 09:15-09:45: OCUPADO
Franja 09:00-09:30: DISPONIBLE
Agenda: Consultorio Integral
08:00-08:30  turno3
10:00-10:30  turno2
```

Conceptos: estado, consulta sin mutación, cancelación, liberación de intervalo y
listado ordenado.

## 3. Error léxico: horario mal formado

```bash
./bin/turnolang examples/frontend/error_hora_sin_cero.tl
```

Salida esperada en `stderr`, código 1:

```text
Error léxico en línea 3:
Horario mal formado: '9:30'.
Análisis léxico y sintáctico: fallido.
```

Concepto: el scanner exige la forma exacta `HH:MM`; el parser no agrega un
segundo diagnóstico.

## 4. Error sintáctico: punto y coma ausente

```bash
./bin/turnolang examples/frontend/error_sin_punto_y_coma.tl
```

Salida esperada en `stderr`, código 1:

```text
Error sintáctico en línea 3:
La entrada no respeta la gramática (syntax error, unexpected end of file, expecting ;).
Análisis léxico y sintáctico: fallido.
```

Concepto: todos los lexemas son reconocibles, pero la secuencia no satisface la
producción de `LISTAR`.

## 5. Error semántico: superposición

```bash
./bin/turnolang examples/interprete/error_superposicion.tl
```

Salida esperada en `stderr`, código 1:

```text
Error semántico en línea 5:
La reserva 'turno2' se superpone con 'turno1'.
```

Concepto: la forma es válida; el rechazo depende del estado creado por una
instrucción anterior.

## 6. Evidencia integral

```bash
make test
```

El cierre esperado es:

```text
TOTAL: 68
APROBADAS: 68
FALLIDAS: 0
```

Conceptos: cinco suites conservadas, oráculos versionados, comparación completa
de salida y falla del objetivo ante cualquier discrepancia.

## Lista de control previa

- [ ] Ejecutable reconstruido desde limpio.
- [ ] Los cuatro casos producen exactamente las salidas anteriores.
- [ ] `make test` termina en 68/68.
- [ ] Terminal con tamaño de fuente legible y ruta situada en la raíz.
- [ ] Ensayo completo cronometrado en el equipo de presentación.
