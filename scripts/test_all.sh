#!/usr/bin/env bash

set -u

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMP_DIR=""
TOTAL=0
APPROVED=0
FAILED=0

SUITE_SCRIPTS=(
    test_smoke.sh
    test_frontend.sh
    test_semantica.sh
    test_interprete.sh
    test_calidad.sh
)

SUITE_LABELS=(
    "Sprint 1"
    "Sprint 2"
    "Sprint 3"
    "Sprint 4"
    "Sprint 5"
)

SUITE_TOTALS=(5 23 21 15 4)

cleanup() {
    if [[ -n "$TEMP_DIR" && -d "$TEMP_DIR" ]]; then
        rm -rf -- "$TEMP_DIR"
    fi
}

trap cleanup EXIT

TEMP_DIR="$(mktemp -d)"

printf 'TURNOLANG - PRUEBAS INTEGRALES\n'

for index in "${!SUITE_SCRIPTS[@]}"; do
    output_file="$TEMP_DIR/suite_${index}.log"
    expected="${SUITE_TOTALS[$index]}"

    if bash "$ROOT_DIR/scripts/${SUITE_SCRIPTS[$index]}" \
        >"$output_file" 2>&1; then
        status=0
    else
        status=$?
    fi

    sed 's/\r$//' "$output_file"
    approved="$(grep -c '^\[OK\]' "$output_file" || true)"
    TOTAL=$((TOTAL + expected))
    APPROVED=$((APPROVED + approved))

    if (( status != 0 || approved != expected )); then
        suite_failed=$((expected - approved))
        if (( suite_failed < 1 )); then
            suite_failed=1
        fi
        FAILED=$((FAILED + suite_failed))
    fi
done

printf '\nRESUMEN INTEGRAL\n'
for index in "${!SUITE_LABELS[@]}"; do
    printf '%s: %d escenario(s)\n' \
        "${SUITE_LABELS[$index]}" "${SUITE_TOTALS[$index]}"
done
printf 'TOTAL: %d\n' "$TOTAL"
printf 'APROBADAS: %d\n' "$APPROVED"
printf 'FALLIDAS: %d\n' "$FAILED"

if (( FAILED > 0 || APPROVED != TOTAL )); then
    exit 1
fi
