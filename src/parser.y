%code requires {
#include "ast.h"
}

%code provides {
extern Programa *programa_analizado;
}

%{
#include <stdio.h>
#include <stdlib.h>

#include "ast.h"

int yylex(void);
void yyerror(const char *mensaje);

extern int lexer_had_error;

Programa *programa_analizado = NULL;
%}

%define parse.error verbose
%locations

%union {
    char *texto;
    Instruccion *instruccion;
    ListaInstrucciones lista;
    Programa *programa;
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

%type <programa> programa
%type <texto> cabecera
%type <lista> lista_sentencias
%type <instruccion> sentencia reserva cancelacion disponibilidad listado

%destructor { free($$); } <texto>
%destructor { ast_instruccion_liberar($$); } <instruccion>
%destructor { ast_lista_liberar(&$$); } <lista>

%start programa

%%

programa:
    cabecera lista_sentencias
    {
        $$ = ast_programa_crear($1, @1.first_line, $2);
        if ($$ == NULL) {
            fprintf(stderr, "Error interno: no se pudo crear el programa.\n");
            YYABORT;
        }
        programa_analizado = $$;
    }
;

cabecera:
    TOK_AGENDA TOK_CADENA TOK_PUNTO_Y_COMA
    {
        $$ = $2;
    }
;

lista_sentencias:
    %empty
    {
        $$ = ast_lista_vacia();
    }
  | lista_sentencias sentencia
    {
        $$ = $1;
        ast_lista_agregar(&$$, $2);
    }
;

sentencia:
    reserva
    {
        $$ = $1;
    }
  | cancelacion
    {
        $$ = $1;
    }
  | disponibilidad
    {
        $$ = $1;
    }
  | listado
    {
        $$ = $1;
    }
;

reserva:
    TOK_RESERVAR TOK_IDENT TOK_DESDE TOK_HORA TOK_HASTA TOK_HORA
    TOK_PUNTO_Y_COMA
    {
        $$ = ast_reserva_crear($2, $4, $6, @1.first_line);
        if ($$ == NULL) {
            fprintf(stderr, "Error interno: no se pudo crear una reserva.\n");
            YYABORT;
        }
    }
;

cancelacion:
    TOK_CANCELAR TOK_IDENT TOK_PUNTO_Y_COMA
    {
        $$ = ast_cancelacion_crear($2, @1.first_line);
        if ($$ == NULL) {
            fprintf(stderr, "Error interno: no se pudo crear una cancelación.\n");
            YYABORT;
        }
    }
;

disponibilidad:
    TOK_LIBRE TOK_DESDE TOK_HORA TOK_HASTA TOK_HORA TOK_PUNTO_Y_COMA
    {
        $$ = ast_disponibilidad_crear($3, $5, @1.first_line);
        if ($$ == NULL) {
            fprintf(stderr, "Error interno: no se pudo crear una consulta.\n");
            YYABORT;
        }
    }
;

listado:
    TOK_LISTAR TOK_PUNTO_Y_COMA
    {
        $$ = ast_listado_crear(@1.first_line);
        if ($$ == NULL) {
            fprintf(stderr, "Error interno: no se pudo crear un listado.\n");
            YYABORT;
        }
    }
;

%%

void yyerror(const char *mensaje)
{
    if (!lexer_had_error) {
        fprintf(stderr,
                "Error sintáctico en línea %d:\n"
                "La entrada no respeta la gramática (%s).\n",
                yylloc.first_line,
                mensaje);
    }
}
