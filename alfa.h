#ifndef _ALFA_H
#define _ALFA_H
#define MAX_LONG_ID 100
#define MAX_TAMANIO_VECTOR 64

typedef struct {
	char * lexema;
	int tipo; //INT,BOOL
	int valor_entero; //valor de INT
	int es_direccion; //escalar o vector
	int etiqueta;
}tipo_atributos;


#endif
