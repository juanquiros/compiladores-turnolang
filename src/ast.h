#ifndef TURNOLANG_AST_H
#define TURNOLANG_AST_H

typedef enum {
    INSTRUCCION_RESERVA,
    INSTRUCCION_CANCELACION,
    INSTRUCCION_DISPONIBILIDAD,
    INSTRUCCION_LISTADO
} TipoInstruccion;

typedef struct {
    char *identificador;
    char *inicio;
    char *fin;
} DatosReserva;

typedef struct {
    char *identificador;
} DatosCancelacion;

typedef struct {
    char *inicio;
    char *fin;
} DatosDisponibilidad;

typedef struct Instruccion {
    TipoInstruccion tipo;
    int linea;
    union {
        DatosReserva reserva;
        DatosCancelacion cancelacion;
        DatosDisponibilidad disponibilidad;
    } datos;
    struct Instruccion *siguiente;
} Instruccion;

typedef struct {
    Instruccion *primera;
    Instruccion *ultima;
} ListaInstrucciones;

typedef struct {
    char *nombre_agenda;
    int linea_agenda;
    ListaInstrucciones instrucciones;
} Programa;

ListaInstrucciones ast_lista_vacia(void);
void ast_lista_agregar(ListaInstrucciones *lista, Instruccion *instruccion);
void ast_lista_liberar(ListaInstrucciones *lista);

Programa *ast_programa_crear(
    char *nombre_agenda,
    int linea_agenda,
    ListaInstrucciones instrucciones
);

Instruccion *ast_reserva_crear(
    char *identificador,
    char *inicio,
    char *fin,
    int linea
);
Instruccion *ast_cancelacion_crear(char *identificador, int linea);
Instruccion *ast_disponibilidad_crear(char *inicio, char *fin, int linea);
Instruccion *ast_listado_crear(int linea);

void ast_instruccion_liberar(Instruccion *instruccion);
void ast_programa_liberar(Programa *programa);

#endif
