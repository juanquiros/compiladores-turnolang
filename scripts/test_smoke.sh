#!/usr/bin/env bash

set -u

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EXECUTABLE="$ROOT_DIR/bin/turnolang"
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

run_and_capture() {
    local output_file="$1"
    shift

    "$@" >"$output_file" 2>&1
}

if [[ ! -x "$EXECUTABLE" ]]; then
    printf 'No se encontró el ejecutable: %s\n' "$EXECUTABLE" >&2
    exit 1
fi

TEMP_DIR="$(mktemp -d)"
VALID_OUTPUT="$TEMP_DIR/valid.out"
INVALID_OUTPUT="$TEMP_DIR/invalid.out"
MISSING_OUTPUT="$TEMP_DIR/missing.out"
LEXICAL_OUTPUT="$TEMP_DIR/lexical.out"
USAGE_OUTPUT="$TEMP_DIR/usage.out"
INVALID_SOURCE="$TEMP_DIR/sin_punto_y_coma.tl"
LEXICAL_SOURCE="$TEMP_DIR/caracter_desconocido.tl"

printf 'AGENDA "Consultorio A"\n' >"$INVALID_SOURCE"
printf 'AGENDA "Consultorio A"@;\n' >"$LEXICAL_SOURCE"

if run_and_capture "$VALID_OUTPUT" "$EXECUTABLE" "$ROOT_DIR/examples/smoke_agenda.tl"; then
    if grep -Fq 'Análisis sintáctico mínimo: correcto.' "$VALID_OUTPUT"; then
        pass 'La cabecera mínima válida es aceptada.'
    else
        fail 'La entrada válida terminó con código cero, pero no emitió la confirmación esperada.'
    fi
else
    fail 'La cabecera mínima válida fue rechazada.'
fi

if run_and_capture "$INVALID_OUTPUT" "$EXECUTABLE" "$INVALID_SOURCE"; then
    fail 'La cabecera sin punto y coma fue aceptada.'
else
    if grep -Fq 'Error sintáctico mínimo' "$INVALID_OUTPUT"; then
        pass 'La cabecera sin punto y coma es rechazada con código no cero.'
    else
        fail 'La entrada inválida falló, pero no informó el error sintáctico esperado.'
    fi
fi

if run_and_capture "$LEXICAL_OUTPUT" "$EXECUTABLE" "$LEXICAL_SOURCE"; then
    fail 'El carácter desconocido fue ignorado.'
else
    if grep -Fq 'Error léxico mínimo' "$LEXICAL_OUTPUT"; then
        pass 'El carácter desconocido se informa como error léxico mínimo.'
    else
        fail 'El carácter desconocido falló sin el diagnóstico léxico esperado.'
    fi
fi

if run_and_capture "$MISSING_OUTPUT" "$EXECUTABLE" "$ROOT_DIR/examples/no_existe.tl"; then
    fail 'El archivo inexistente produjo código cero.'
else
    if grep -Fq 'no se pudo abrir el archivo' "$MISSING_OUTPUT"; then
        pass 'El archivo inexistente se informa con código no cero.'
    else
        fail 'El archivo inexistente falló sin el diagnóstico esperado.'
    fi
fi

if run_and_capture "$USAGE_OUTPUT" "$EXECUTABLE"; then
    fail 'La ejecución sin ruta produjo código cero.'
else
    if grep -Fq 'Uso:' "$USAGE_OUTPUT"; then
        pass 'La ejecución sin ruta informa el uso y devuelve código no cero.'
    else
        fail 'La ejecución sin ruta falló sin mostrar el uso esperado.'
    fi
fi

if (( FAILURES > 0 )); then
    printf '%d prueba(s) mínima(s) fallaron.\n' "$FAILURES" >&2
    exit 1
fi

printf 'Todas las pruebas mínimas aprobaron.\n'
