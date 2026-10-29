%option noyywrap yylineno nounput noinput

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "parser.h"

int lexer_had_error = 0;

static char *copiar_fragmento(const char *origen, size_t inicio, size_t longitud)
{
    char *copia = malloc(longitud + 1);

    if (copia == NULL) {
        fprintf(stderr, "Error interno: no se pudo reservar memoria.\n");
        exit(EXIT_FAILURE);
    }

    memcpy(copia, origen + inicio, longitud);
    copia[longitud] = '\0';
    return copia;
}

static int informar_error_lexico(const char *motivo)
{
    fprintf(stderr,
            "Error léxico en línea %d:\n%s: '%s'.\n",
            yylineno,
            motivo,
            yytext);
    lexer_had_error = 1;
    yylloc.first_line = yylineno;
    yylloc.last_line = yylineno;
    yylloc.first_column = 0;
    yylloc.last_column = 0;
    return TOK_ERROR_LEXICO;
}

#define DEVOLVER_TOKEN(token)          \
    do {                               \
        yylloc.first_line = yylineno;  \
        yylloc.last_line = yylineno;   \
        yylloc.first_column = 0;       \
        yylloc.last_column = 0;        \
        return (token);                \
    } while (0)
%}

CADENA                  \"[^\"\r\n]*\"
CADENA_SIN_CIERRE       \"[^\"\r\n]*
HORA                    [0-9]{2}:[0-9]{2}
CANDIDATO_NUMERICO      [0-9][^ \t\r\n;]*
IDENT                   [A-Za-z_][A-Za-z0-9_]*

%%

"AGENDA"               { DEVOLVER_TOKEN(TOK_AGENDA); }
"RESERVAR"             { DEVOLVER_TOKEN(TOK_RESERVAR); }
"CANCELAR"             { DEVOLVER_TOKEN(TOK_CANCELAR); }
"DESDE"                { DEVOLVER_TOKEN(TOK_DESDE); }
"HASTA"                { DEVOLVER_TOKEN(TOK_HASTA); }
"LIBRE"                { DEVOLVER_TOKEN(TOK_LIBRE); }
"LISTAR"               { DEVOLVER_TOKEN(TOK_LISTAR); }

{CADENA}                {
                            yylval.texto = copiar_fragmento(
                                yytext,
                                1,
                                (size_t)yyleng - 2
                            );
                            DEVOLVER_TOKEN(TOK_CADENA);
                        }

{CADENA_SIN_CIERRE}     { return informar_error_lexico("Cadena sin comilla de cierre"); }

{HORA}                  {
                            yylval.texto = copiar_fragmento(
                                yytext,
                                0,
                                (size_t)yyleng
                            );
                            DEVOLVER_TOKEN(TOK_HORA);
                        }

{CANDIDATO_NUMERICO}    {
                            if (strchr(yytext, ':') != NULL ||
                                strchr(yytext, '-') != NULL) {
                                return informar_error_lexico("Horario mal formado");
                            }
                            return informar_error_lexico("Lexema numérico no admitido");
                        }

{IDENT}                 {
                            yylval.texto = copiar_fragmento(
                                yytext,
                                0,
                                (size_t)yyleng
                            );
                            DEVOLVER_TOKEN(TOK_IDENT);
                        }

";"                     { DEVOLVER_TOKEN(TOK_PUNTO_Y_COMA); }
[ \t\r]+                { /* Separadores sin significado sintáctico. */ }
\n                      { /* yylineno se actualiza mediante la opción yylineno. */ }
.                       { return informar_error_lexico("Carácter no reconocido"); }

%%
