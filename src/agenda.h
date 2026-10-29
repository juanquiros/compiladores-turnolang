#ifndef TURNOLANG_AGENDA_H
#define TURNOLANG_AGENDA_H

typedef struct ReservaAgenda ReservaAgenda;

typedef struct {
    ReservaAgenda *primera;
} Agenda;

void agenda_inicializar(Agenda *agenda);
void agenda_liberar(Agenda *agenda);

const ReservaAgenda *agenda_buscar_activa(
    const Agenda *agenda,
    const char *identificador
);
const ReservaAgenda *agenda_buscar_superposicion(
    const Agenda *agenda,
    int inicio,
    int fin
);
const char *agenda_reserva_identificador(const ReservaAgenda *reserva);

int agenda_intervalos_se_superponen(
    int inicio_a,
    int fin_a,
    int inicio_b,
    int fin_b
);
int agenda_agregar_reserva(
    Agenda *agenda,
    const char *identificador,
    int inicio,
    int fin
);
int agenda_cancelar_reserva(Agenda *agenda, const char *identificador);

#endif
