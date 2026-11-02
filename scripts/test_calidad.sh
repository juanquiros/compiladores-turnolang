#!/usr/bin/env bash

set -u

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EXECUTABLE="$ROOT_DIR/bin/turnolang"
EXPECTED_ROOT="$ROOT_DIR/examples/esperados"
EXPECTED_INTERPRETER="$ROOT_DIR/examples/interprete/esperados"
EXPECTED_QUALITY="$ROOT_DIR/examples/calidad/esperados"
SUCCESS_STATUS="$(<"$EXPECTED_ROOT/codigo_exito.txt")"
ERROR_STATUS="$(<"$EXPECTED_ROOT/codigo_error.txt")"
FAILURES=0
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

normalize_line_endings() {
    local file="$1"
    local normalized="${file}.normalized"

    sed 's/\r$//' "$file" >"$normalized"
    mv -- "$normalized" "$file"
}

run_empty_file() {
    local source="$TEMP_DIR/archivo_vacio.tl"
    local stdout_file="$TEMP_DIR/archivo_vacio.out"
    local stderr_file="$TEMP_DIR/archivo_vacio.err"
    local status

    : >"$source"
    if "$EXECUTABLE" "$source" >"$stdout_file" 2>"$stderr_file"; then
        status=0
    else
        status=$?
    fi
    normalize_line_endings "$stdout_file"
    normalize_line_endings "$stderr_file"

    if (( status == ERROR_STATUS )) &&
       [[ ! -s "$stdout_file" ]] &&
       cmp -s "$EXPECTED_QUALITY/archivo_vacio.err" "$stderr_file"; then
        pass 'Archivo completamente vacío'
    else
        fail 'Archivo completamente vacío: código o flujos incorrectos'
    fi
}

run_without_final_newline() {
    local source="$TEMP_DIR/sin_salto_final.tl"
    local stdout_file="$TEMP_DIR/sin_salto_final.out"
    local stderr_file="$TEMP_DIR/sin_salto_final.err"
    local status

    printf 'AGENDA "Sin salto final";' >"$source"
    if "$EXECUTABLE" "$source" >"$stdout_file" 2>"$stderr_file"; then
        status=0
    else
        status=$?
    fi

    if (( status == SUCCESS_STATUS )) &&
       [[ ! -s "$stdout_file" ]] &&
       [[ ! -s "$stderr_file" ]]; then
        pass 'Archivo válido sin salto de línea final'
    else
        fail 'Archivo sin salto final: código o flujos incorrectos'
    fi
}

run_path_with_spaces() {
    local directory="$TEMP_DIR/ruta con espacios"
    local source="$directory/programa completo.tl"
    local stdout_file="$TEMP_DIR/ruta_espacios.out"
    local stderr_file="$TEMP_DIR/ruta_espacios.err"
    local status

    mkdir -p -- "$directory"
    cp -- "$ROOT_DIR/examples/interprete/ok_completo.tl" "$source"

    if "$EXECUTABLE" "$source" >"$stdout_file" 2>"$stderr_file"; then
        status=0
    else
        status=$?
    fi
    normalize_line_endings "$stdout_file"
    normalize_line_endings "$stderr_file"

    if (( status == SUCCESS_STATUS )) &&
       cmp -s "$EXPECTED_INTERPRETER/ok_completo.out" "$stdout_file" &&
       [[ ! -s "$stderr_file" ]]; then
        pass 'Ruta de archivo con espacios'
    else
        fail 'Ruta con espacios: código o flujos incorrectos'
    fi
}

verify_induced_failure() {
    local actual="$TEMP_DIR/oraculo_actual.out"
    local stderr_file="$TEMP_DIR/oraculo_actual.err"
    local altered="$TEMP_DIR/oraculo_alterado.out"
    local status

    if "$EXECUTABLE" "$ROOT_DIR/examples/interprete/ok_completo.tl" \
        >"$actual" 2>"$stderr_file"; then
        status=0
    else
        status=$?
    fi
    normalize_line_endings "$actual"
    cp -- "$EXPECTED_INTERPRETER/ok_completo.out" "$altered"
    printf 'línea alterada intencionalmente\n' >>"$altered"

    if (( status == SUCCESS_STATUS )) &&
       [[ ! -s "$stderr_file" ]] &&
       ! cmp -s "$altered" "$actual"; then
        pass 'El comparador detecta un oráculo alterado'
    else
        fail 'La falla inducida no fue detectada correctamente'
    fi
}

if [[ ! -x "$EXECUTABLE" ]]; then
    printf 'No se encontró el ejecutable: %s\n' "$EXECUTABLE" >&2
    exit 1
fi

TEMP_DIR="$(mktemp -d)"

printf '\nSprint 5:\n'

run_empty_file
run_without_final_newline
run_path_with_spaces
verify_induced_failure

if (( FAILURES > 0 )); then
    printf '\nRESULTADO: %d comprobación(es) de calidad fallaron.\n' \
        "$FAILURES" >&2
    exit 1
fi

printf '\nRESULTADO: Las 4 comprobaciones de calidad aprobaron.\n'
