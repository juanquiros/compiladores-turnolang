#include "agenda.h"

#include <stdlib.h>
#include <string.h>

struct ReservaAgenda {
    char *identificador;
    int inicio;
    int fin;
    int activa;
    ReservaAgenda *siguiente;
};

static char *agenda_copiar_texto(const char *texto)
{
    size_t longitud = strlen(texto);
    char *copia = malloc(longitud + 1);

    if (copia != NULL) {
        memcpy(copia, texto, longitud + 1);
    }

    return copia;
}

static ReservaAgenda *agenda_buscar_activa_mutable(
    Agenda *agenda,
    const char *identificador
)
{
    ReservaAgenda *actual = agenda->primera;

    while (actual != NULL) {
        if (actual->activa &&
            strcmp(actual->identificador, identificador) == 0) {
            return actual;
        }
        actual = actual->siguiente;
    }

    return NULL;
}

void agenda_inicializar(Agenda *agenda)
{
    agenda->primera = NULL;
}

void agenda_liberar(Agenda *agenda)
{
    ReservaAgenda *actual = agenda->primera;

    while (actual != NULL) {
        ReservaAgenda *siguiente = actual->siguiente;
        free(actual->identificador);
        free(actual);
        actual = siguiente;
    }

    agenda->primera = NULL;
}

const ReservaAgenda *agenda_buscar_activa(
    const Agenda *agenda,
    const char *identificador
)
{
    const ReservaAgenda *actual = agenda->primera;

    while (actual != NULL) {
        if (actual->activa &&
            strcmp(actual->identificador, identificador) == 0) {
            return actual;
        }
        actual = actual->siguiente;
    }

    return NULL;
}

int agenda_intervalos_se_superponen(
    int inicio_a,
    int fin_a,
    int inicio_b,
    int fin_b
)
{
    return inicio_a < fin_b && fin_a > inicio_b;
}

const ReservaAgenda *agenda_buscar_superposicion(
    const Agenda *agenda,
    int inicio,
    int fin
)
{
    const ReservaAgenda *actual = agenda->primera;

    while (actual != NULL) {
        if (actual->activa && agenda_intervalos_se_superponen(
                inicio,
                fin,
                actual->inicio,
                actual->fin
            )) {
            return actual;
        }
        actual = actual->siguiente;
    }

    return NULL;
}

const char *agenda_reserva_identificador(const ReservaAgenda *reserva)
{
    return reserva->identificador;
}

int agenda_agregar_reserva(
    Agenda *agenda,
    const char *identificador,
    int inicio,
    int fin
)
{
    ReservaAgenda *reserva = malloc(sizeof(*reserva));

    if (reserva == NULL) {
        return 0;
    }

    reserva->identificador = agenda_copiar_texto(identificador);
    if (reserva->identificador == NULL) {
        free(reserva);
        return 0;
    }

    reserva->inicio = inicio;
    reserva->fin = fin;
    reserva->activa = 1;
    reserva->siguiente = agenda->primera;
    agenda->primera = reserva;
    return 1;
}

int agenda_cancelar_reserva(Agenda *agenda, const char *identificador)
{
    ReservaAgenda *reserva = agenda_buscar_activa_mutable(
        agenda,
        identificador
    );

    if (reserva == NULL) {
        return 0;
    }

    reserva->activa = 0;
    return 1;
}
