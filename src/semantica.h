#ifndef TURNOLANG_SEMANTICA_H
#define TURNOLANG_SEMANTICA_H

#include "agenda.h"
#include "ast.h"

typedef struct {
    int inicio_minutos;
    int fin_minutos;
    int intervalo_ocupado;
} SemanticaContextoInstruccion;

typedef int (*SemanticaObservador)(
    const Programa *programa,
    const Instruccion *instruccion,
    const Agenda *agenda,
    const SemanticaContextoInstruccion *contexto,
    void *datos
);

int semantica_procesar_programa(
    const Programa *programa,
    SemanticaObservador observador,
    void *datos_observador
);
int semantica_validar_programa(const Programa *programa);

#endif
