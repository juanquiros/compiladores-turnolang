#include "semantica.h"

#include "agenda.h"

#include <stdio.h>
#include <string.h>

typedef enum {
    SEMANTICA_OK,
    SEMANTICA_HORA_INICIO_FUERA_RANGO,
    SEMANTICA_HORA_FIN_FUERA_RANGO,
    SEMANTICA_INTERVALO_VACIO,
    SEMANTICA_INTERVALO_INVERTIDO,
    SEMANTICA_IDENTIFICADOR_DUPLICADO,
    SEMANTICA_SUPERPOSICION,
    SEMANTICA_CANCELACION_INEXISTENTE
} CodigoSemantico;

typedef struct {
    CodigoSemantico codigo;
    int inicio_minutos;
    int fin_minutos;
    const ReservaAgenda *reserva_relacionada;
} ResultadoSemantico;

static int convertir_hora(const char *hora, int *minutos)
{
    int componente_hora;
    int componente_minutos;

    if (strlen(hora) != 5 || hora[2] != ':') {
        return 0;
    }

    componente_hora = (hora[0] - '0') * 10 + (hora[1] - '0');
    componente_minutos = (hora[3] - '0') * 10 + (hora[4] - '0');

    if (componente_hora < 0 || componente_hora > 23 ||
        componente_minutos < 0 || componente_minutos > 59) {
        return 0;
    }

    *minutos = componente_hora * 60 + componente_minutos;
    return 1;
}

static ResultadoSemantico resultado_correcto(void)
{
    ResultadoSemantico resultado = {
        SEMANTICA_OK,
        0,
        0,
        NULL
    };
    return resultado;
}

static ResultadoSemantico validar_intervalo(
    const char *inicio,
    const char *fin
)
{
    ResultadoSemantico resultado = resultado_correcto();

    if (!convertir_hora(inicio, &resultado.inicio_minutos)) {
        resultado.codigo = SEMANTICA_HORA_INICIO_FUERA_RANGO;
        return resultado;
    }

    if (!convertir_hora(fin, &resultado.fin_minutos)) {
        resultado.codigo = SEMANTICA_HORA_FIN_FUERA_RANGO;
        return resultado;
    }

    if (resultado.inicio_minutos == resultado.fin_minutos) {
        resultado.codigo = SEMANTICA_INTERVALO_VACIO;
    } else if (resultado.inicio_minutos > resultado.fin_minutos) {
        resultado.codigo = SEMANTICA_INTERVALO_INVERTIDO;
    }

    return resultado;
}

static ResultadoSemantico validar_sentencia(
    const Instruccion *instruccion,
    const Agenda *agenda
)
{
    ResultadoSemantico resultado = resultado_correcto();

    switch (instruccion->tipo) {
        case INSTRUCCION_RESERVA:
            resultado = validar_intervalo(
                instruccion->datos.reserva.inicio,
                instruccion->datos.reserva.fin
            );
            if (resultado.codigo != SEMANTICA_OK) {
                return resultado;
            }

            if (agenda_buscar_activa(
                    agenda,
                    instruccion->datos.reserva.identificador
                ) != NULL) {
                resultado.codigo = SEMANTICA_IDENTIFICADOR_DUPLICADO;
                return resultado;
            }

            resultado.reserva_relacionada = agenda_buscar_superposicion(
                agenda,
                resultado.inicio_minutos,
                resultado.fin_minutos
            );
            if (resultado.reserva_relacionada != NULL) {
                resultado.codigo = SEMANTICA_SUPERPOSICION;
            }
            return resultado;

        case INSTRUCCION_CANCELACION:
            if (agenda_buscar_activa(
                    agenda,
                    instruccion->datos.cancelacion.identificador
                ) == NULL) {
                resultado.codigo = SEMANTICA_CANCELACION_INEXISTENTE;
            }
            return resultado;

        case INSTRUCCION_DISPONIBILIDAD:
            resultado = validar_intervalo(
                instruccion->datos.disponibilidad.inicio,
                instruccion->datos.disponibilidad.fin
            );
            if (resultado.codigo == SEMANTICA_OK) {
                (void)agenda_buscar_superposicion(
                    agenda,
                    resultado.inicio_minutos,
                    resultado.fin_minutos
                );
            }
            return resultado;

        case INSTRUCCION_LISTADO:
            return resultado;
    }

    return resultado;
}

static int aplicar_sentencia(
    const Instruccion *instruccion,
    Agenda *agenda,
    const ResultadoSemantico *resultado
)
{
    switch (instruccion->tipo) {
        case INSTRUCCION_RESERVA:
            return agenda_agregar_reserva(
                agenda,
                instruccion->datos.reserva.identificador,
                resultado->inicio_minutos,
                resultado->fin_minutos
            );
        case INSTRUCCION_CANCELACION:
            return agenda_cancelar_reserva(
                agenda,
                instruccion->datos.cancelacion.identificador
            );
        case INSTRUCCION_DISPONIBILIDAD:
        case INSTRUCCION_LISTADO:
            return 1;
    }

    return 0;
}

static void informar_error_semantico(
    const Instruccion *instruccion,
    const ResultadoSemantico *resultado
)
{
    fprintf(stderr, "Error semántico en línea %d:\n", instruccion->linea);

    switch (resultado->codigo) {
        case SEMANTICA_HORA_INICIO_FUERA_RANGO:
            fprintf(
                stderr,
                "La hora '%s' está fuera del rango permitido 00:00-23:59.\n",
                instruccion->tipo == INSTRUCCION_RESERVA
                    ? instruccion->datos.reserva.inicio
                    : instruccion->datos.disponibilidad.inicio
            );
            break;
        case SEMANTICA_HORA_FIN_FUERA_RANGO:
            fprintf(
                stderr,
                "La hora '%s' está fuera del rango permitido 00:00-23:59.\n",
                instruccion->tipo == INSTRUCCION_RESERVA
                    ? instruccion->datos.reserva.fin
                    : instruccion->datos.disponibilidad.fin
            );
            break;
        case SEMANTICA_INTERVALO_VACIO:
            fprintf(
                stderr,
                "El intervalo %s-%s está vacío; inicio y fin deben ser diferentes.\n",
                instruccion->tipo == INSTRUCCION_RESERVA
                    ? instruccion->datos.reserva.inicio
                    : instruccion->datos.disponibilidad.inicio,
                instruccion->tipo == INSTRUCCION_RESERVA
                    ? instruccion->datos.reserva.fin
                    : instruccion->datos.disponibilidad.fin
            );
            break;
        case SEMANTICA_INTERVALO_INVERTIDO:
            fprintf(
                stderr,
                "El intervalo %s-%s es inválido; el inicio debe ser anterior al fin.\n",
                instruccion->tipo == INSTRUCCION_RESERVA
                    ? instruccion->datos.reserva.inicio
                    : instruccion->datos.disponibilidad.inicio,
                instruccion->tipo == INSTRUCCION_RESERVA
                    ? instruccion->datos.reserva.fin
                    : instruccion->datos.disponibilidad.fin
            );
            break;
        case SEMANTICA_IDENTIFICADOR_DUPLICADO:
            fprintf(
                stderr,
                "El identificador '%s' ya tiene una reserva activa.\n",
                instruccion->datos.reserva.identificador
            );
            break;
        case SEMANTICA_SUPERPOSICION:
            fprintf(
                stderr,
                "La reserva '%s' se superpone con '%s'.\n",
                instruccion->datos.reserva.identificador,
                agenda_reserva_identificador(resultado->reserva_relacionada)
            );
            break;
        case SEMANTICA_CANCELACION_INEXISTENTE:
            fprintf(
                stderr,
                "No existe una reserva activa con el identificador '%s'.\n",
                instruccion->datos.cancelacion.identificador
            );
            break;
        case SEMANTICA_OK:
            break;
    }
}

int semantica_validar_programa(const Programa *programa)
{
    Agenda agenda;
    const Instruccion *instruccion;

    if (programa->nombre_agenda[0] == '\0') {
        fprintf(
            stderr,
            "Error semántico en línea %d:\n"
            "El nombre de la agenda no puede estar vacío.\n",
            programa->linea_agenda
        );
        return 0;
    }

    agenda_inicializar(&agenda);
    instruccion = programa->instrucciones.primera;

    while (instruccion != NULL) {
        ResultadoSemantico resultado = validar_sentencia(instruccion, &agenda);

        if (resultado.codigo != SEMANTICA_OK) {
            informar_error_semantico(instruccion, &resultado);
            agenda_liberar(&agenda);
            return 0;
        }

        if (!aplicar_sentencia(instruccion, &agenda, &resultado)) {
            fprintf(
                stderr,
                "Error interno: no se pudo actualizar el estado de validación.\n"
            );
            agenda_liberar(&agenda);
            return 0;
        }

        instruccion = instruccion->siguiente;
    }

    agenda_liberar(&agenda);
    return 1;
}
