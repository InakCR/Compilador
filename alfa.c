#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include "alfa.h"
#include "y.tab.h"

extern FILE *yyin, *yyout;
extern int yyparse();

int main(int argc, char* argv[]){
	int salida_parser;
	
	yyin = fopen(argv[1], "r");
	yyout = fopen(argv[2], "w");

	salida_parser = yyparse();

	fclose(yyin);
	fclose(yyout);

	return salida_parser;
}
