
#include <stdlib.h>
#include <stdio.h>
#include "alfa.h"

/*Cabeceras*/
void escribirSegmentos(FILE* f,TABLA_HASH* hash);
void escribirData(FILE* f);
void escribirBss(FILE* f,TABLA_HASH* hash);
void escribirText(FILE* f);
void escribirImain(FILE* f);
void escribirFmain(FILE* f);
/*Operaciones Aritmeticas*/
void gc_suma_enteros(FILE* f, int es_direccion_op1, int es_direccion_op2);
void gc_resta_enteros(FILE* f, int es_direccion_op1,int es_direccion_op2);
void gc_mult_enteros(FILE* f, int es_direccion_op1,int es_direccion_op2);
void gc_div_enteros(FILE* f, int es_direccion_op1,int es_direccion_op2);
void gc_neg_enteros(FILE* f,int es_direccion_op1);
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
/*Constantes*/
void gc_constante(FILE*, int nlinea,int valor);
/*Asignacion*/
void gc_asignacion_iden(FILE* f,int es_direccion_op1,char* lex);
void gc_asignacion_funcion(FILE* f,int es_direccion,CATEGORIA cat,int pos,int nParLoc);
void gc_asignacion_vector(FILE* f,int es_direccion_op1);
void gc_asignacion_elemento_vector(FILE* f,int es_direccion_op1,char* lex);
/*Entrada Salida*/
void gc_lectura(FILE* f,char* lex,TIPO tipo);
void gc_escritura(FILE* f,int es_direccion,TIPO tipo);
/*Bucles*/
void gc_if_exp(FILE* f,int es_direccion,int etiqueta);
void gc_if_exp_sentencias(FILE* f,int etiqueta);
void gc_condicional(FILE* f,int etiqueta);
void gc_while_exp(FILE* f,int es_direccion,int etiqueta);
void gc_while(FILE* f,int etiqueta);
void gc_bucle(FILE* f,int etiqueta);
/*Funciones*/
void gc_idf_llamada_funcion(FILE* f,char* lex,int gNumPar);
void gc_fn_declaration(FILE* f,char* lex,int gNumVar);
void gc_retorno_funcion(FILE* f,int es_direccion);
void gc_exp_iden_param(FILE* f,int gNumPar,int posPar);
void gc_exp_iden_var_local(FILE* f,int posVar);
void gc_direccion(FILE* f,char* lex);
void gc_contenido(FILE* f,char* lex);
