#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "parser.h"
#include "semantica.h"

int yylex_destroy(void);

extern FILE *yyin;
extern int lexer_had_error;
extern int yylineno;

static void mostrar_uso(const char *programa)
{
    fprintf(
        stderr,
        "Uso: %s [--solo-sintaxis] <archivo.tl>\n",
        programa
    );
}

int main(int argc, char *argv[])
{
    const char *ruta;
    FILE *entrada;
    int resultado_parser;
    int solo_sintaxis = 0;

    if (argc == 2) {
        ruta = argv[1];
    } else if (argc == 3 && strcmp(argv[1], "--solo-sintaxis") == 0) {
        solo_sintaxis = 1;
        ruta = argv[2];
    } else {
        mostrar_uso(argv[0]);
        return EXIT_FAILURE;
    }

    entrada = fopen(ruta, "r");
    if (entrada == NULL) {
        fprintf(stderr, "Error: no se pudo abrir el archivo '%s'.\n", ruta);
        return EXIT_FAILURE;
    }

    yyin = entrada;
    yylineno = 1;
    yylloc.first_line = 1;
    yylloc.last_line = 1;
    yylloc.first_column = 0;
    yylloc.last_column = 0;
    lexer_had_error = 0;
    programa_analizado = NULL;

    puts("TurnoLang");
    resultado_parser = yyparse();

    if (yylex_destroy() != 0) {
        fprintf(stderr, "Error interno: no se pudo liberar el scanner.\n");
        ast_programa_liberar(programa_analizado);
        fclose(entrada);
        return EXIT_FAILURE;
    }

    if (fclose(entrada) != 0) {
        fprintf(stderr, "Error: no se pudo cerrar el archivo '%s'.\n", ruta);
        ast_programa_liberar(programa_analizado);
        return EXIT_FAILURE;
    }

    if (resultado_parser != 0 || lexer_had_error) {
        fprintf(stderr, "Análisis léxico y sintáctico: fallido.\n");
        ast_programa_liberar(programa_analizado);
        return EXIT_FAILURE;
    }

    if (programa_analizado == NULL) {
        fprintf(stderr, "Error interno: el parser no construyó el AST.\n");
        return EXIT_FAILURE;
    }

    puts("Análisis léxico y sintáctico: correcto.");

    if (solo_sintaxis) {
        puts("Modo solo sintaxis: análisis semántico omitido.");
        ast_programa_liberar(programa_analizado);
        programa_analizado = NULL;
        return EXIT_SUCCESS;
    }

    if (!semantica_validar_programa(programa_analizado)) {
        fprintf(stderr, "Análisis semántico: fallido.\n");
        ast_programa_liberar(programa_analizado);
        programa_analizado = NULL;
        return EXIT_FAILURE;
    }

    puts("Análisis semántico: correcto.");
    puts("Interpretación: pendiente.");

    ast_programa_liberar(programa_analizado);
    programa_analizado = NULL;
    return EXIT_SUCCESS;
}
