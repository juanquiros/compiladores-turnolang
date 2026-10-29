# TurnoLang

TurnoLang es un lenguaje específico de dominio para describir operaciones sobre
la agenda diaria de un único recurso. El proyecto es un Trabajo Práctico
Integrador de Compiladores y busca mostrar de forma clara las etapas de
procesamiento de un lenguaje.

Esta versión corresponde al Sprint 1. Solo reconoce la cabecera mínima:

```text
AGENDA "Consultorio A";
```

Todavía no interpreta reservas ni implementa el lenguaje completo.

## Tecnologías

- **C:** implementa el programa principal y, en sprints posteriores, el resto
  del intérprete.
- **Flex:** genera el scanner que transforma caracteres en tokens.
- **Bison:** genera el parser que comprueba la gramática mínima.
- **GCC:** compila el código C propio y el generado.
- **GNU Make:** declara dependencias y automatiza generación, compilación,
  pruebas y limpieza.

## Arquitectura implementada

```text
Archivo .tl
    |
    v
Flex (src/lexer.l)
    |
    v
Tokens TOK_AGENDA, TOK_CADENA y TOK_PUNTO_Y_COMA
    |
    v
Bison (src/parser.y)
    |
    v
Resultado del análisis sintáctico mínimo
```

`src/main.c` abre el archivo y configura `yyin`. Luego llama a `yyparse`, la
función generada por Bison. Mientras analiza, `yyparse` solicita tokens a
`yylex`, la función generada por Flex. Si la entrada coincide con
`AGENDA CADENA PUNTO_Y_COMA`, el parser devuelve éxito. El programa principal
cierra el archivo y transforma ese resultado en el código de salida del proceso.

No se construye todavía un AST ni se ejecutan instrucciones de agenda.

## Entorno verificado

La compilación y las pruebas de este sprint se verificaron en Windows 11 con
Git Bash y las siguientes versiones:

- Flex 2.6.4, provisto por winflexbison 2.5.25;
- GNU Bison 3.8.2;
- GCC 15.2.0;
- GNU Make 4.4.1; y
- GNU Bash 5.3.15.

No se declara compatibilidad con otros entornos hasta verificarlos.

### Instalación en el entorno verificado

1. Instalar [Git for Windows](https://gitforwindows.org/) para disponer de Git
   Bash.
2. Instalar [Scoop](https://scoop.sh/) siguiendo su documentación oficial.
3. Desde PowerShell, instalar las herramientas:

```powershell
scoop install gcc make winflexbison
```

4. Cerrar y volver a abrir Git Bash para que reciba el `PATH` actualizado.

Los comandos siguientes se ejecutan desde Git Bash, en la raíz del repositorio.

## Compilación

```bash
make
```

Make crea `build/` y `bin/` cuando son necesarios. Bison genera
`build/parser.c` y `build/parser.h`; Flex genera `build/lexer.c`; GCC compila
esos archivos y `src/main.c`, y enlaza `bin/turnolang.exe`. En Git Bash puede
invocarse el ejecutable sin escribir la extensión `.exe`.

La dependencia de `build/lexer.c` respecto de `build/parser.h` garantiza que
Bison defina los tokens antes de que se genere y compile el scanner. Una segunda
ejecución de `make` sin cambios no reconstruye archivos.

## Ejecución

```bash
./bin/turnolang examples/smoke_agenda.tl
```

Salida esperada:

```text
TurnoLang
Análisis sintáctico mínimo: correcto.
Nota: el intérprete completo todavía no está implementado.
```

## Pruebas

```bash
make test
```

El objetivo construye el ejecutable si hace falta y ejecuta
`scripts/test_smoke.sh`. El script comprueba una cabecera válida, una cabecera
sin punto y coma, un carácter desconocido, un archivo inexistente y la ejecución
sin argumentos. Verifica tanto los códigos de salida como mensajes observables;
no es todavía la batería integral del proyecto.

## Limpieza

```bash
make clean
```

Elimina únicamente `build/` y `bin/`, que contienen generados, objetos y el
ejecutable. No elimina fuentes, ejemplos, scripts ni documentación.

## Recorrido de la entrada mínima

Para `AGENDA "Consultorio A";`:

1. `main` abre el archivo y llama a `yyparse`.
2. `yylex` reconoce `AGENDA`, la cadena y `;`, y entrega sus tokens a Bison.
3. `yyparse` reduce esos tokens mediante la regla `cabecera` y acepta el
   programa.
4. `main` informa que el análisis mínimo fue correcto y finaliza con código 0.

Un carácter desconocido se informa como error léxico mínimo; una estructura que
no coincide con la cabecera se informa como error sintáctico mínimo.

## Estado

Implementado y verificado en Sprint 1:

- estructura técnica mínima;
- scanner Flex para la cabecera;
- parser Bison para la cabecera;
- ejecutable coordinado por `main.c`;
- compilación reproducible con Make; y
- pruebas mínimas de integración.

Pendiente para sprints posteriores:

- scanner y gramática completos;
- diagnósticos avanzados del frontend;
- AST mínimo del programa;
- análisis semántico;
- estado de reservas e intérprete; y
- batería integral de pruebas e informe LNCS.
