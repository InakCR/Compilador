
#include <stdlib.h>
#include <stdio.h>
#include "alfa.h"

void escribirSegmentos(FILE* f,TABLA_HASH* hash);

void escribirData(FILE* f);
void escribirBss(FILE* f,TABLA_HASH* hash);
void escribirText(FILE* f);
void escribirImain(FILE* f);
void escribirFmain(FILE* f);


void suma(FILE* f);
void resta(FILE* f);
void multiplicacion(FILE* f);
void division(FILE* f);
