#!/usr/bin/env bash

set -u

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EXECUTABLE="$ROOT_DIR/bin/turnolang"
CASES_DIR="$ROOT_DIR/examples/frontend"
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
       [[ ! -s "$stderr_file" ]]; then
        pass "$label"
    else
        fail "$label (se esperaba aceptación con código 0)"
        show_evidence "$stdout_file" "$stderr_file"
    fi
}

run_error() {
    local label="$1"
    local stage="$2"
    local line="$3"
    local source_file="$4"
    local stdout_file
    local stderr_file
    local status
    local expected
    local unexpected

    CASE_NUMBER=$((CASE_NUMBER + 1))
    stdout_file="$TEMP_DIR/case_${CASE_NUMBER}.out"
    stderr_file="$TEMP_DIR/case_${CASE_NUMBER}.err"

    if "$EXECUTABLE" "$source_file" >"$stdout_file" 2>"$stderr_file"; then
        status=0
    else
        status=$?
    fi

    expected="Error ${stage} en línea ${line}:"
    if [[ "$stage" == "léxico" ]]; then
        unexpected='Error sintáctico en línea'
    else
        unexpected='Error léxico en línea'
    fi

    if (( status != 0 )) &&
       grep -Fq "$expected" "$stderr_file" &&
       ! grep -Fq "$unexpected" "$stderr_file" &&
       ! grep -Fq 'Análisis léxico y sintáctico: correcto.' "$stdout_file"; then
        pass "$label"
    else
        fail "$label (clasificación, línea o código incorrectos)"
        show_evidence "$stdout_file" "$stderr_file"
    fi
}

if [[ ! -x "$EXECUTABLE" ]]; then
    printf 'No se encontró el ejecutable: %s\n' "$EXECUTABLE" >&2
    exit 1
fi

TEMP_DIR="$(mktemp -d)"

printf '\nSprint 2:\n'

run_valid 'Cabecera válida' "$CASES_DIR/ok_cabecera.tl"
run_valid 'Reserva válida' "$CASES_DIR/ok_reserva.tl"
run_valid 'Todas las instrucciones' "$CASES_DIR/ok_todas_instrucciones.tl"
run_valid 'Múltiples reservas' "$CASES_DIR/ok_multiples_reservas.tl"
run_valid 'Hora fuera de rango aceptada sintácticamente' "$CASES_DIR/ok_hora_fuera_rango.tl"
run_valid 'Nombre de agenda vacío aceptado sintácticamente' "$CASES_DIR/ok_agenda_vacia.tl"
run_valid 'Intervalo invertido aceptado sintácticamente' "$CASES_DIR/ok_intervalo_invertido.tl"

run_error 'Hora sin cero inicial' 'léxico' 3 "$CASES_DIR/error_hora_sin_cero.tl"
run_error 'Separador horario incorrecto' 'léxico' 3 "$CASES_DIR/error_hora_separador.tl"
run_error 'Minutos con un dígito' 'léxico' 3 "$CASES_DIR/error_hora_minuto_corto.tl"
run_error 'Minutos con tres dígitos' 'léxico' 3 "$CASES_DIR/error_hora_minuto_largo.tl"
run_error 'Símbolo desconocido' 'léxico' 3 "$CASES_DIR/error_simbolo.tl"
run_error 'Cadena sin cierre' 'léxico' 1 "$CASES_DIR/error_cadena_sin_cierre.tl"
run_error 'Identificador iniciado con número' 'léxico' 3 "$CASES_DIR/error_ident_inicia_numero.tl"
run_error 'Identificador con guion' 'léxico' 3 "$CASES_DIR/error_ident_guion.tl"

run_error 'Falta de punto y coma' 'sintáctico' 3 "$CASES_DIR/error_sin_punto_y_coma.tl"
run_error 'Falta de cabecera' 'sintáctico' 1 "$CASES_DIR/error_sin_cabecera.tl"
run_error 'Reserva incompleta' 'sintáctico' 3 "$CASES_DIR/error_reserva_incompleta.tl"
run_error 'Cabecera duplicada' 'sintáctico' 3 "$CASES_DIR/error_cabecera_duplicada.tl"
run_error 'Orden incorrecto' 'sintáctico' 3 "$CASES_DIR/error_orden.tl"
run_error 'Palabra reservada en minúsculas' 'sintáctico' 3 "$CASES_DIR/error_palabra_minuscula.tl"

if (( FAILURES > 0 )); then
    printf '\nRESULTADO: %d prueba(s) del frontend fallaron.\n' "$FAILURES" >&2
    exit 1
fi

printf '\nRESULTADO: Todas las pruebas aprobaron.\n'
