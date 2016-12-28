#include <stdio.h>
#include <stdlib.h>
#include "alfa.h"
#include "generacion_codigo.h"

extern FILE *yyin, *yyout;
extern int yyparse();

int main(int argc, char* argv[]){
	
	if(argc != 3 ){
		printf("Erro de parametros.\n");
		return 0;
	}
	yyin = fopen(argv[1], "r");
	yyout = fopen(argv[2], "w");

	yyparse();

	fclose(yyin);
	fclose(yyout);

	return 1;
}
