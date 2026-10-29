#include "ast.h"

#include <stdlib.h>

static Instruccion *ast_instruccion_base_crear(
    TipoInstruccion tipo,
    int linea
)
{
    Instruccion *instruccion = calloc(1, sizeof(*instruccion));

    if (instruccion == NULL) {
        return NULL;
    }

    instruccion->tipo = tipo;
    instruccion->linea = linea;
    return instruccion;
}

ListaInstrucciones ast_lista_vacia(void)
{
    ListaInstrucciones lista = {NULL, NULL};
    return lista;
}

void ast_lista_agregar(ListaInstrucciones *lista, Instruccion *instruccion)
{
    instruccion->siguiente = NULL;

    if (lista->ultima == NULL) {
        lista->primera = instruccion;
    } else {
        lista->ultima->siguiente = instruccion;
    }

    lista->ultima = instruccion;
}

Programa *ast_programa_crear(
    char *nombre_agenda,
    int linea_agenda,
    ListaInstrucciones instrucciones
)
{
    Programa *programa = malloc(sizeof(*programa));

    if (programa == NULL) {
        return NULL;
    }

    programa->nombre_agenda = nombre_agenda;
    programa->linea_agenda = linea_agenda;
    programa->instrucciones = instrucciones;
    return programa;
}

Instruccion *ast_reserva_crear(
    char *identificador,
    char *inicio,
    char *fin,
    int linea
)
{
    Instruccion *instruccion = ast_instruccion_base_crear(
        INSTRUCCION_RESERVA,
        linea
    );

    if (instruccion == NULL) {
        return NULL;
    }

    instruccion->datos.reserva.identificador = identificador;
    instruccion->datos.reserva.inicio = inicio;
    instruccion->datos.reserva.fin = fin;
    return instruccion;
}

Instruccion *ast_cancelacion_crear(char *identificador, int linea)
{
    Instruccion *instruccion = ast_instruccion_base_crear(
        INSTRUCCION_CANCELACION,
        linea
    );

    if (instruccion == NULL) {
        return NULL;
    }

    instruccion->datos.cancelacion.identificador = identificador;
    return instruccion;
}

Instruccion *ast_disponibilidad_crear(char *inicio, char *fin, int linea)
{
    Instruccion *instruccion = ast_instruccion_base_crear(
        INSTRUCCION_DISPONIBILIDAD,
        linea
    );

    if (instruccion == NULL) {
        return NULL;
    }

    instruccion->datos.disponibilidad.inicio = inicio;
    instruccion->datos.disponibilidad.fin = fin;
    return instruccion;
}

Instruccion *ast_listado_crear(int linea)
{
    return ast_instruccion_base_crear(INSTRUCCION_LISTADO, linea);
}

void ast_instruccion_liberar(Instruccion *instruccion)
{
    if (instruccion == NULL) {
        return;
    }

    switch (instruccion->tipo) {
        case INSTRUCCION_RESERVA:
            free(instruccion->datos.reserva.identificador);
            free(instruccion->datos.reserva.inicio);
            free(instruccion->datos.reserva.fin);
            break;
        case INSTRUCCION_CANCELACION:
            free(instruccion->datos.cancelacion.identificador);
            break;
        case INSTRUCCION_DISPONIBILIDAD:
            free(instruccion->datos.disponibilidad.inicio);
            free(instruccion->datos.disponibilidad.fin);
            break;
        case INSTRUCCION_LISTADO:
            break;
    }

    free(instruccion);
}

void ast_lista_liberar(ListaInstrucciones *lista)
{
    Instruccion *actual = lista->primera;

    while (actual != NULL) {
        Instruccion *siguiente = actual->siguiente;
        ast_instruccion_liberar(actual);
        actual = siguiente;
    }

    lista->primera = NULL;
    lista->ultima = NULL;
}

void ast_programa_liberar(Programa *programa)
{
    if (programa == NULL) {
        return;
    }

    free(programa->nombre_agenda);
    ast_lista_liberar(&programa->instrucciones);
    free(programa);
}
