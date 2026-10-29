#!/usr/bin/env bash

set -u

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EXECUTABLE="$ROOT_DIR/bin/turnolang"
CASES_DIR="$ROOT_DIR/examples/semantica"
FAILURES=0
CASE_NUMBER=0
TEMP_DIR=""

if [[ ! -x "$EXECUTABLE" && -x "${EXECUTABLE}.exe" ]]; then
    EXECUTABLE="${EXECUTABLE}.exe"
fi

cleanup() {
    if [[ -n "$TEMP_DIR" && -d "$TEMP_DIR" ]]; then
        rm -rf -- "$TEMP_DIR"
    fi
}

trap cleanup EXIT

pass() {
    printf '[OK] %s\n' "$1"
}

fail() {
    printf '[FALLO] %s\n' "$1" >&2
    FAILURES=$((FAILURES + 1))
}

show_evidence() {
    local stdout_file="$1"
    local stderr_file="$2"

    if [[ -s "$stdout_file" ]]; then
        printf '%s\n' '--- stdout ---' >&2
        sed 's/^/  /' "$stdout_file" >&2
    fi
    if [[ -s "$stderr_file" ]]; then
        printf '%s\n' '--- stderr ---' >&2
        sed 's/^/  /' "$stderr_file" >&2
    fi
}

run_valid() {
    local label="$1"
    local source_file="$2"
    local stdout_file
    local stderr_file
    local status

    CASE_NUMBER=$((CASE_NUMBER + 1))
    stdout_file="$TEMP_DIR/case_${CASE_NUMBER}.out"
    stderr_file="$TEMP_DIR/case_${CASE_NUMBER}.err"

    if "$EXECUTABLE" "$source_file" >"$stdout_file" 2>"$stderr_file"; then
        status=0
    else
        status=$?
    fi

    if (( status == 0 )) &&
       grep -Fq 'Análisis léxico y sintáctico: correcto.' "$stdout_file" &&
       grep -Fq 'Análisis semántico: correcto.' "$stdout_file" &&
       grep -Fq 'Interpretación: pendiente.' "$stdout_file" &&
       ! grep -Eq 'DISPONIBLE|OCUPADO|Agenda:' "$stdout_file" &&
       [[ ! -s "$stderr_file" ]]; then
        pass "$label"
    else
        fail "$label (se esperaba validación semántica con código 0)"
        show_evidence "$stdout_file" "$stderr_file"
    fi
}

run_error() {
    local label="$1"
    local line="$2"
    local reason="$3"
    local source_file="$4"
    local stdout_file
    local stderr_file
    local status

    CASE_NUMBER=$((CASE_NUMBER + 1))
    stdout_file="$TEMP_DIR/case_${CASE_NUMBER}.out"
    stderr_file="$TEMP_DIR/case_${CASE_NUMBER}.err"

    if "$EXECUTABLE" "$source_file" >"$stdout_file" 2>"$stderr_file"; then
        status=0
    else
        status=$?
    fi

    if (( status != 0 )) &&
       grep -Fq "Error semántico en línea ${line}:" "$stderr_file" &&
       grep -Fq "$reason" "$stderr_file" &&
       ! grep -Fq 'Error léxico en línea' "$stderr_file" &&
       ! grep -Fq 'Error sintáctico en línea' "$stderr_file" &&
       ! grep -Fq 'Análisis semántico: correcto.' "$stdout_file"; then
        pass "$label"
    else
        fail "$label (clasificación, línea, motivo o código incorrectos)"
        show_evidence "$stdout_file" "$stderr_file"
    fi
}

if [[ ! -x "$EXECUTABLE" ]]; then
    printf 'No se encontró el ejecutable: %s\n' "$EXECUTABLE" >&2
    exit 1
fi

TEMP_DIR="$(mktemp -d)"

printf '\nSprint 3:\n'

run_valid 'Programa semánticamente válido' "$CASES_DIR/ok_programa.tl"
run_error 'Nombre de agenda vacío' 1 'nombre de la agenda no puede estar vacío' "$CASES_DIR/error_nombre_vacio.tl"
run_error 'Hora fuera de rango' 3 'fuera del rango permitido' "$CASES_DIR/error_hora_fuera_rango.tl"
run_error 'Intervalo vacío' 3 'está vacío' "$CASES_DIR/error_intervalo_vacio.tl"
run_error 'Intervalo invertido' 3 'inicio debe ser anterior' "$CASES_DIR/error_intervalo_invertido.tl"
run_error 'Identificador duplicado' 5 'ya tiene una reserva activa' "$CASES_DIR/error_identificador_duplicado.tl"
run_error 'Superposición parcial' 5 'se superpone con' "$CASES_DIR/error_superposicion_parcial.tl"
run_valid 'Reservas consecutivas' "$CASES_DIR/ok_consecutivas.tl"
run_error 'Cancelación inexistente' 3 'No existe una reserva activa' "$CASES_DIR/error_cancelacion_inexistente.tl"
run_valid 'Cancelación válida' "$CASES_DIR/ok_cancelacion.tl"
run_valid 'Reutilización de identificador' "$CASES_DIR/ok_reutilizacion_identificador.tl"
run_valid 'Consulta de intervalo ocupado' "$CASES_DIR/ok_consulta_ocupada.tl"
run_error 'Consulta con intervalo inválido' 3 'inicio debe ser anterior' "$CASES_DIR/error_consulta_intervalo_invalido.tl"
run_error 'Doble cancelación' 7 'No existe una reserva activa' "$CASES_DIR/error_doble_cancelacion.tl"
run_error 'Superposición por intervalo contenido' 5 'se superpone con' "$CASES_DIR/error_superposicion_contenida.tl"
run_error 'Superposición por intervalo contenedor' 5 'se superpone con' "$CASES_DIR/error_superposicion_contiene.tl"
run_valid 'Límites horarios permitidos' "$CASES_DIR/ok_limites_horarios.tl"
run_valid 'Reserva posterior a cancelación libera intervalo' "$CASES_DIR/ok_intervalo_liberado.tl"
run_error 'Primera instrucción semánticamente inválida' 3 'fuera del rango permitido' "$CASES_DIR/error_primera_instruccion.tl"
run_error 'Error posterior a instrucciones válidas' 7 'se superpone con' "$CASES_DIR/error_instruccion_posterior.tl"
run_valid 'LISTAR reconocido sin salida funcional' "$CASES_DIR/ok_listar_sin_efecto.tl"

if (( FAILURES > 0 )); then
    printf '\nRESULTADO: %d prueba(s) semántica(s) fallaron.\n' "$FAILURES" >&2
    exit 1
fi

printf '\nRESULTADO: Todas las pruebas aprobaron.\n'
