
#include <stdlib.h>
#include <stdio.h>
#include "alfa.h"

void escribirSegmentos(FILE* f,TABLA_HASH* hash);

void escribirData(FILE* f);
void escribirBss(FILE* f,TABLA_HASH* hash);
void escribirText(FILE* f);
void escribirImain(FILE* f);
void escribirFmain(FILE* f);
/*Operaciones Aritmeticas*/
void gc_suma_enteros(FILE* f, es_direccion_op1, es_direccion_op2);
void gc_resta_enteros(FILE* f, es_direccion_op1, es_direccion_op2);
void gc_mult_enteros(FILE* f, es_direccion_op1, es_direccion_op2);
void gc_div_enteros(FILE* f, es_direccion_op1, es_direccion_op2);
/*Operaciones Logicas*/
void gc_and_enteros(FILE* f, int es_direccion_op1, int es_direccion_op2);
void gc_or_enteros(FILE* f, int es_direccion_op1, int es_direccion_op2);
void gc_not_enteros(FILE* f, int es_direccion_op1, int etiqueta);
/*Operaciones Comparacion*/
void gc_comp_igual_enteros(FILE* f, int es_direccion_op1, int es_direccion_op2,int etiqueta);
void gc_comp_distinto_enteros(FILE* f, int es_direccion_op1, int es_direccion_op2,int etiqueta);
void gc_comp_menorigual_enteros(FILE* f, int es_direccion_op1, int es_direccion_op2,int etiqueta);
void gc_comp_mayorigual_enteros(FILE* f, int es_direccion_op1, int es_direccion_op2,int etiqueta);
void gc_comp_menor_enteros(FILE* f, int es_direccion_op1, int es_direccion_op2,int etiqueta);
void gc_comp_mayor_enteros(FILE* f, int es_direccion_op1, int es_direccion_op2,int etiqueta);

void gc_constante(FILE*, int nlinea,int valor);
/*Asignacion*/
void gc_asignacion_iden(FILE* f,int es_direccion_op1,char* lex);
void gc_asignacion_vector(FILE* f,int es_direccion_op1);
