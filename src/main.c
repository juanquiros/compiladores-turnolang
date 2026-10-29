#include <stdio.h>
#include <stdlib.h>

int yyparse(void);
int yylex_destroy(void);

extern FILE *yyin;
extern int lexer_had_error;
extern int yylineno;

static void mostrar_uso(const char *programa)
{
    fprintf(stderr, "Uso: %s <archivo.tl>\n", programa);
}

int main(int argc, char *argv[])
{
    FILE *entrada;
    int resultado_parser;

    if (argc != 2) {
        mostrar_uso(argv[0]);
        return EXIT_FAILURE;
    }

    entrada = fopen(argv[1], "r");
    if (entrada == NULL) {
        fprintf(stderr, "Error: no se pudo abrir el archivo '%s'.\n", argv[1]);
        return EXIT_FAILURE;
    }

    yyin = entrada;
    yylineno = 1;
    lexer_had_error = 0;

    puts("TurnoLang");
    resultado_parser = yyparse();

    if (yylex_destroy() != 0) {
        fprintf(stderr, "Error interno: no se pudo liberar el scanner.\n");
        fclose(entrada);
        return EXIT_FAILURE;
    }

    if (fclose(entrada) != 0) {
        fprintf(stderr, "Error: no se pudo cerrar el archivo '%s'.\n", argv[1]);
        return EXIT_FAILURE;
    }

    if (resultado_parser != 0 || lexer_had_error) {
        fprintf(stderr, "Análisis léxico y sintáctico: fallido.\n");
        return EXIT_FAILURE;
    }

    puts("Análisis léxico y sintáctico: correcto.");
    puts("Semántica e interpretación: pendientes.");
    return EXIT_SUCCESS;
}
