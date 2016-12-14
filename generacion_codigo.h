/**
 *
 * Descripcion:
 *
 * Fichero: generacion_codigo.h
 * Autor: Daniel Cuesta, Iñaki Cadalso
 * Version: 1.0
 * Fecha: 28-09-2016
 *
 */

void escribirSegmentos(FILE *f,int op1,int op2);

void escribirData(FILE* f);
void escribirBss(FILE* f);
void escribirText(FILE* f);
void escribirImain(FILE* f,int op1,int op2);
void escribirFmain(FILE* f);


void suma(FILE* f);
void resta(FILE* f);
void multiplicacion(FILE* f);
void division(FILE* f);

