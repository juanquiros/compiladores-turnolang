%{
#include <stdio.h>
#include <stdlib.h>

int yylex(void);
void yyerror(const char *mensaje);

extern int lexer_had_error;
extern int lexer_token_line;
%}

%define parse.error verbose

%union {
    char *texto;
}

%token TOK_AGENDA "AGENDA"
%token TOK_RESERVAR "RESERVAR"
%token TOK_CANCELAR "CANCELAR"
%token TOK_DESDE "DESDE"
%token TOK_HASTA "HASTA"
%token TOK_LIBRE "LIBRE"
%token TOK_LISTAR "LISTAR"
%token <texto> TOK_IDENT "identificador"
%token <texto> TOK_CADENA "cadena"
%token <texto> TOK_HORA "horario"
%token TOK_PUNTO_Y_COMA ";"
%token TOK_ERROR_LEXICO "error léxico"

%destructor { free($$); } <texto>

%start programa

%%

programa:
    cabecera lista_sentencias
;

cabecera:
    TOK_AGENDA TOK_CADENA TOK_PUNTO_Y_COMA
    {
        free($2);
    }
;

lista_sentencias:
    %empty
  | lista_sentencias sentencia
;

sentencia:
    reserva
  | cancelacion
  | disponibilidad
  | listado
;

reserva:
    TOK_RESERVAR TOK_IDENT TOK_DESDE TOK_HORA TOK_HASTA TOK_HORA
    TOK_PUNTO_Y_COMA
    {
        free($2);
        free($4);
        free($6);
    }
;

cancelacion:
    TOK_CANCELAR TOK_IDENT TOK_PUNTO_Y_COMA
    {
        free($2);
    }
;

disponibilidad:
    TOK_LIBRE TOK_DESDE TOK_HORA TOK_HASTA TOK_HORA TOK_PUNTO_Y_COMA
    {
        free($3);
        free($5);
    }
;

listado:
    TOK_LISTAR TOK_PUNTO_Y_COMA
;

%%

void yyerror(const char *mensaje)
{
    if (!lexer_had_error) {
        fprintf(stderr,
                "Error sintáctico en línea %d:\nLa entrada no respeta la gramática (%s).\n",
                lexer_token_line,
                mensaje);
    }
}
