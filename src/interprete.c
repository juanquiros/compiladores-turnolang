#include "interprete.h"

#include "agenda.h"
#include "semantica.h"

#include <stddef.h>

static int imprimir_hora(FILE *salida, int minutos)
{
    return fprintf(salida, "%02d:%02d", minutos / 60, minutos % 60) >= 0;
}

static int imprimir_disponibilidad(
    FILE *salida,
    const SemanticaContextoInstruccion *contexto
)
{
    if (fprintf(salida, "Franja ") < 0 ||
        !imprimir_hora(salida, contexto->inicio_minutos) ||
        fprintf(salida, "-") < 0 ||
        !imprimir_hora(salida, contexto->fin_minutos) ||
        fprintf(
            salida,
            ": %s\n",
            contexto->intervalo_ocupado ? "OCUPADO" : "DISPONIBLE"
        ) < 0) {
        return 0;
    }

    return 1;
}

static int imprimir_listado(
    FILE *salida,
    const Programa *programa,
    const Agenda *agenda
)
{
    ReservaAgendaVista *reservas = NULL;
    size_t cantidad = 0;
    size_t indice;
    int correcto = 1;

    if (!agenda_obtener_activas_ordenadas(agenda, &reservas, &cantidad)) {
        fprintf(stderr, "Error interno: no se pudo ordenar el listado.\n");
        return 0;
    }

    if (fprintf(salida, "Agenda: %s\n", programa->nombre_agenda) < 0) {
        correcto = 0;
    } else if (cantidad == 0) {
        correcto = fprintf(salida, "(sin reservas)\n") >= 0;
    } else {
        for (indice = 0; indice < cantidad && correcto; indice++) {
            correcto = imprimir_hora(salida, reservas[indice].inicio) &&
                fprintf(salida, "-") >= 0 &&
                imprimir_hora(salida, reservas[indice].fin) &&
                fprintf(
                    salida,
                    "  %s\n",
                    reservas[indice].identificador
                ) >= 0;
        }
    }

    agenda_liberar_vistas(reservas);
    return correcto;
}

static int ejecutar_salida(
    const Programa *programa,
    const Instruccion *instruccion,
    const Agenda *agenda,
    const SemanticaContextoInstruccion *contexto,
    void *datos
)
{
    FILE *salida = datos;
    int correcto = 1;

    switch (instruccion->tipo) {
        case INSTRUCCION_RESERVA:
        case INSTRUCCION_CANCELACION:
            break;
        case INSTRUCCION_DISPONIBILIDAD:
            correcto = imprimir_disponibilidad(salida, contexto);
            break;
        case INSTRUCCION_LISTADO:
            correcto = imprimir_listado(salida, programa, agenda);
            break;
    }

    if (!correcto && ferror(salida)) {
        fprintf(stderr, "Error interno: no se pudo escribir la salida.\n");
    }

    return correcto;
}

int interprete_ejecutar_programa(const Programa *programa, FILE *salida)
{
    return semantica_procesar_programa(
        programa,
        ejecutar_salida,
        salida
    );
}
