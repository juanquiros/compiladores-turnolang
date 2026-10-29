%{
#include <stdio.h>
#include <stdlib.h>

int yylex(void);
void yyerror(const char *mensaje);

extern int lexer_had_error;
extern int yylineno;
%}

%define parse.error verbose

%union {
    char *texto;
}

%token TOK_AGENDA
%token <texto> TOK_CADENA
%token TOK_PUNTO_Y_COMA
%token TOK_ERROR_LEXICO

%destructor { free($$); } <texto>

%start programa

%%

programa:
    cabecera
;

cabecera:
    TOK_AGENDA TOK_CADENA TOK_PUNTO_Y_COMA
    {
        free($2);
    }
;

%%

void yyerror(const char *mensaje)
{
    if (!lexer_had_error) {
        fprintf(stderr,
                "Error sintáctico mínimo en línea %d: %s.\n",
                yylineno,
                mensaje);
    }
}
