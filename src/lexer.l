%option noyywrap yylineno nounput noinput

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "parser.h"

int lexer_had_error = 0;

static char *copiar_contenido_cadena(const char *lexema, size_t longitud)
{
    size_t contenido_longitud = longitud - 2;
    char *contenido = malloc(contenido_longitud + 1);

    if (contenido == NULL) {
        fprintf(stderr, "Error interno: no se pudo reservar memoria.\n");
        exit(EXIT_FAILURE);
    }

    memcpy(contenido, lexema + 1, contenido_longitud);
    contenido[contenido_longitud] = '\0';
    return contenido;
}
%}

CADENA  \"[^\"\r\n]*\"

%%

"AGENDA"        { return TOK_AGENDA; }
{CADENA}         {
                    yylval.texto = copiar_contenido_cadena(yytext, (size_t)yyleng);
                    return TOK_CADENA;
                 }
";"             { return TOK_PUNTO_Y_COMA; }
[ \t\r]+        { /* Separadores sin significado sintáctico. */ }
\n              { /* yylineno se actualiza mediante la opción yylineno. */ }
.                {
                    fprintf(stderr,
                            "Error léxico mínimo en línea %d: carácter no reconocido '%s'.\n",
                            yylineno,
                            yytext);
                    lexer_had_error = 1;
                    return TOK_ERROR_LEXICO;
                 }

%%
