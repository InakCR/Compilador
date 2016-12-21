#ifndef _ALFA_H

#include "tablaHash.h"

#define _ALFA_H
#define ESCALAR 1
#define VECTOR 2
#define INT 1
#define BOOLEAN 2
#define MAX_LONG_ID 100
#define MAX_TAMANIO_VECTOR 64
#define HASHSIZE 101

typedef struct {
	char * lexema;
	int tipo; //INT,BOOL
	int valor_entero; //valor de INT
	int es_direccion; //escalar o vector (direccion memoria)
	int etiqueta;
} tipo_atributos;

INFO_SIMBOLO *buscar(const char *lexema);
#endif
