#ifndef TURNOLANG_INTERPRETE_H
#define TURNOLANG_INTERPRETE_H

#include <stdio.h>

#include "ast.h"

int interprete_ejecutar_programa(const Programa *programa, FILE *salida);

#endif
