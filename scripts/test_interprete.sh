#!/usr/bin/env bash

set -u

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EXECUTABLE="$ROOT_DIR/bin/turnolang"
CASES_DIR="$ROOT_DIR/examples/interprete"
EXPECTED_DIR="$CASES_DIR/esperados"
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

compare_stream() {
    local label="$1"
    local stream_name="$2"
    local actual_file="$3"
    local expected_file="$4"

    if [[ "$expected_file" == "-" ]]; then
        if [[ -s "$actual_file" ]]; then
            fail "$label: ${stream_name} debía estar vacío"
            sed 's/^/  /' "$actual_file" >&2
            return 1
        fi
        return 0
    fi

    if ! cmp -s "$expected_file" "$actual_file"; then
        fail "$label: ${stream_name} no coincide exactamente"
        diff -u "$expected_file" "$actual_file" >&2 || true
        return 1
    fi

    return 0
}

normalize_line_endings() {
    local file="$1"
    local normalized="${file}.normalized"

    sed 's/\r$//' "$file" >"$normalized"
    mv -- "$normalized" "$file"
}

run_case() {
    local label="$1"
    local source_name="$2"
    local expected_status="$3"
    local expected_stdout="$4"
    local expected_stderr="$5"
    local stdout_file
    local stderr_file
    local status
    local correct=1

    CASE_NUMBER=$((CASE_NUMBER + 1))
    stdout_file="$TEMP_DIR/case_${CASE_NUMBER}.out"
    stderr_file="$TEMP_DIR/case_${CASE_NUMBER}.err"

    if "$EXECUTABLE" "$CASES_DIR/$source_name" \
        >"$stdout_file" 2>"$stderr_file"; then
        status=0
    else
        status=$?
    fi

    normalize_line_endings "$stdout_file"
    normalize_line_endings "$stderr_file"

    if (( status != expected_status )); then
        fail "$label: código ${status}, se esperaba ${expected_status}"
        correct=0
    fi

    if ! compare_stream \
        "$label" stdout "$stdout_file" "$expected_stdout"; then
        correct=0
    fi
    if ! compare_stream \
        "$label" stderr "$stderr_file" "$expected_stderr"; then
        correct=0
    fi

    if (( correct == 1 )); then
        pass "$label"
    fi
}

verify_repeatability() {
    local first_out="$TEMP_DIR/repeat_first.out"
    local first_err="$TEMP_DIR/repeat_first.err"
    local second_out="$TEMP_DIR/repeat_second.out"
    local second_err="$TEMP_DIR/repeat_second.err"
    local first_status
    local second_status

    "$EXECUTABLE" "$CASES_DIR/ok_completo.tl" \
        >"$first_out" 2>"$first_err"
    first_status=$?
    "$EXECUTABLE" "$CASES_DIR/ok_completo.tl" \
        >"$second_out" 2>"$second_err"
    second_status=$?

    if (( first_status == 0 && second_status == 0 )) &&
       cmp -s "$first_out" "$second_out" &&
       cmp -s "$first_err" "$second_err"; then
        pass 'Programa completo repetible'
    else
        fail 'Programa completo: dos ejecuciones no fueron idénticas'
    fi
}

if [[ ! -x "$EXECUTABLE" ]]; then
    printf 'No se encontró el ejecutable: %s\n' "$EXECUTABLE" >&2
    exit 1
fi

TEMP_DIR="$(mktemp -d)"

printf '\nSprint 4:\n'

run_case 'Reserva y listado' 'ok_reserva_listado.tl' 0 \
    "$EXPECTED_DIR/ok_reserva_listado.out" -
run_case 'Listado ordenado' 'ok_listado_ordenado.tl' 0 \
    "$EXPECTED_DIR/ok_listado_ordenado.out" -
run_case 'Cancelación' 'ok_cancelacion.tl' 0 \
    "$EXPECTED_DIR/ok_cancelacion.out" -
run_case 'Reutilización de identificador' 'ok_reutilizacion_id.tl' 0 \
    "$EXPECTED_DIR/ok_reutilizacion_id.out" -
run_case 'Disponibilidad libre' 'ok_disponible.tl' 0 \
    "$EXPECTED_DIR/ok_disponible.out" -
run_case 'Disponibilidad ocupada' 'ok_ocupado.tl' 0 \
    "$EXPECTED_DIR/ok_ocupado.out" -
run_case 'Reservas consecutivas' 'ok_consecutivas.tl' 0 \
    "$EXPECTED_DIR/ok_consecutivas.out" -
run_case 'Agenda vacía' 'ok_agenda_vacia.tl' 0 \
    "$EXPECTED_DIR/ok_agenda_vacia.out" -
run_case 'Múltiples listados' 'ok_multiples_listados.tl' 0 \
    "$EXPECTED_DIR/ok_multiples_listados.out" -
run_case 'Error semántico detiene ejecución' 'error_superposicion.tl' 1 \
    - "$EXPECTED_DIR/error_superposicion.err"
run_case 'Salida anterior conservada ante error' 'error_despues_salida.tl' 1 \
    "$EXPECTED_DIR/error_despues_salida.out" \
    "$EXPECTED_DIR/error_despues_salida.err"
run_case 'Programa completo' 'ok_completo.tl' 0 \
    "$EXPECTED_DIR/ok_completo.out" -
run_case 'Consulta ocupada permite continuar' 'ok_ocupado_continua.tl' 0 \
    "$EXPECTED_DIR/ok_ocupado_continua.out" -
run_case 'Error léxico impide interpretación' 'error_lexico_tardio.tl' 1 \
    - "$EXPECTED_DIR/error_lexico_tardio.err"
run_case 'Error sintáctico impide interpretación' \
    'error_sintactico_tardio.tl' 1 - \
    "$EXPECTED_DIR/error_sintactico_tardio.err"

verify_repeatability

if (( FAILURES > 0 )); then
    printf '\nRESULTADO: %d comprobación(es) del intérprete fallaron.\n' \
        "$FAILURES" >&2
    exit 1
fi

printf '\nRESULTADO: Los 15 escenarios del intérprete aprobaron.\n'
