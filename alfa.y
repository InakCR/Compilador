
%{
#include <stdio.h>
#include <stdlib.h>
#include <time.h>


extern int column,fila,error_morfo;
extern FILE *yyin, *yyout;
extern char *yytext;
extern int yylex();

int yyerror(char* s);
int salida_parser;

%}

%token TOK_OPCION
%token TOK_SIGUIENTE
%token TOK_MAIN
%token TOK_INT
%token TOK_BOOLEAN
%token TOK_ARRAY
%token TOK_FUNCTION
%token TOK_IF
%token TOK_ELSE
%token TOK_WHILE
%token TOK_SCANF
%token TOK_PRINTF
%token TOK_RETURN

%token TOK_PUNTOYCOMA
%token TOK_COMA
%token TOK_PARENTESISIZQUIERDO
%token TOK_PARENTESISDERECHO
%token TOK_CORCHETEIZQUIERDO
%token TOK_CORCHETEDERECHO
%token TOK_LLAVEIZQUIERDA
%token TOK_LLAVEDERECHA
%token TOK_ASIGNACION
%token TOK_MAS
%token TOK_MENOS
%token TOK_DIVISION
%token TOK_ASTERISCO
%token TOK_AND
%token TOK_OR
%token TOK_NOT
%token TOK_IGUAL
%token TOK_DISTINTO
%token TOK_MENORIGUAL
%token TOK_MAYORIGUAL
%token TOK_MENOR
%token TOK_MAYOR

%token TOK_IDENTIFICADOR

%token TOK_CONSTANTE_ENTERA
%token TOK_TRUE
%token TOK_FALSE

%left TOK_MAS TOK_MENOS TOK_OR
%left TOK_ASTERISCO TOK_DIVISION TOK_AND
%left TOK_NOT

%%

programa: TOK_MAIN TOK_LLAVEIZQUIERDA declaraciones funciones sentencias TOK_LLAVEDERECHA
		{
			fprintf(yyout, ";R1:\t main {<declaraciones> <fuciones> <sentencias>}\n");
		}
		;

declaraciones: declaracion
			 {
				fprintf(yyout, ";R2:\t <declaracion>");
			 }
			 | declaracion declaraciones
			 {
				fprintf(yyout, ";R3:\t <declaracion> <declaraciones>");
			 }
			 ;

declaracion: clase identificadores TOK_PUNTOYCOMA
		   {
				fprintf(yyout, ";R4:\t <clase> <identificadores>;");
		   }
		   ;

clase: clase_escalar
	 {
		fprintf(yyout, ";R5:\t<clase> ::= <clase_escalar>\n");
	 }
	 | clase_vector
	 {
		fprintf(yyout, ";R7:\t <clase_vector>");
	 }
	 ;

clase_escalar: tipo
			 {
				fprintf(yyout, ";R9:\t<clase_escalar> ::= <tipo>\n");
			 }
			 ;
tipo: TOK_INT
	{
		fprintf(yyout, ";R10:\t<tipo> ::=  int\n");
	}
	| TOK_BOOLEAN
	{
		fprintf(yyout, ";R11:\t <boolean>");
	}
	;

clase_vector: TOK_ARRAY tipo TOK_CORCHETEIZQUIERDO constante_entera TOK_CORCHETEDERECHO
			{
				fprintf(yyout, ";R15:\t array <tipo> [<constante_entera>]");
			}
			;

identificadores: identificador
			   {
					fprintf(yyout, ";R18:\t <identificador>");
			   }
			   | identificador TOK_COMA identificadores
			   {
					fprintf(yyout, ";R19:\t <identificador>, <identificadores>");
			   }
			   ;

funciones: funcion funciones
		 {
			fprintf(yyout, ";R20:\t <funcion> <funciones>");
		 }
		 |
		 {
			fprintf(yyout, ";R21:\t");
		 }
		 ;

funcion: TOK_FUNCTION tipo identificador TOK_PARENTESISIZQUIERDO parametros_funcion TOK_PARENTESISDERECHO TOK_LLAVEIZQUIERDA declaraciones_funcion sentencia TOK_LLAVEDERECHA
	   {
			fprintf(yyout, ";R22:\t function <tipo> <identificador> (<parametros_funcion) {<declaraciones_funcion> <sentencias>}");
	   }
	   ;

parametros_funcion: parametro_funcion resto_parametros_funcion
				  {
					fprintf(yyout, ";R23:\t <parametro_funcion> <resto_parametros_funcion>");
				  }
				  |
				  {
					fprintf(yyout, ";R24:\t");
				  }
				  ;

resto_parametros_funcion: TOK_PUNTOYCOMA parametro_funcion resto_parametros_funcion
						{
							fprintf(yyout, ";R25:\t ; <parametro_funcion> <resto_parametros_funcion>");
						}
						|
						{
							fprintf(yyout, ";R26:\t");
						}
						;

parametro_funcion: tipo identificador
				 {
					fprintf(yyout, ";R27:\t <tipo> <identificador>");
				 }
				 ;

declaraciones_funcion: declaraciones
					 {
						fprintf(yyout, ";R28:\t <declaraciones>");
					 }
					 |
					 {
						fprintf(yyout, ";R29:\t");
					 }
					 ;

sentencias: sentencia
		  {
			fprintf(yyout, ";R30:\t <sentencia>");
		  }
		  | sentencia sentencias
		  {
			fprintf(yyout, ";R31:\t <sentencia> <sentencias>");
		  }
		  ;

sentencia: sentencia_simple TOK_PUNTOYCOMA
		 {
			fprintf(yyout, ";R32:\t <sentencia_simple> ;");
		 }
		 | bloque
		 {
			fprintf(yyout, ";R33:\t <bloque>");
		 }
		 ;

sentencia_simple: asignacion
				{
					fprintf(yyout, ";R34:\t <asignacion>");
				}
				| lectura
				{
					fprintf(yyout, ";R35:\t <lectura>");
				}
				| escritura
				{
					fprintf(yyout, ";R36:\t <escritura>");
				}
				| retorno_funcion
				{
					fprintf(yyout, ";R38:\t <retorno_funcion>");
				}
				;

bloque: condicional
	  {
		fprintf(yyout, ";R40:\t <condicional>");
	  }
	  | bucle
	  {
		fprintf(yyout, ";R41:\t <bucle>");
	  }
	  ;

asignacion: identificador TOK_ASIGNACION exp
		  {
			fprintf(yyout, ";R43:\t <identificador> = <exp>");
		  }
		  | elemento_vector TOK_ASIGNACION exp
		  {
			fprintf(yyout, ";R44:\t <elemento_vector> = <exp>");
		  }
		  ;

elemento_vector: identificador TOK_CORCHETEIZQUIERDO exp TOK_CORCHETEDERECHO
			   {
					fprintf(yyout, ";R48:\t <identificador> [<exp>]");
			   }
			   ;

condicional: TOK_IF TOK_PARENTESISIZQUIERDO exp TOK_PARENTESISDERECHO TOK_LLAVEIZQUIERDA sentencias TOK_LLAVEDERECHA
		   {
				fprintf(yyout, ";R50:\t if(<exp>){<sentencias>}");
		   }
		   | TOK_IF TOK_PARENTESISIZQUIERDO exp TOK_PARENTESISDERECHO TOK_LLAVEIZQUIERDA sentencias TOK_LLAVEDERECHA TOK_ELSE TOK_LLAVEIZQUIERDA sentencias TOK_LLAVEDERECHA
		   {
				fprintf(yyout, ";R51:\t if(<exp>){<sentencias>} else{<sentencias>}");
		   }
		   ;

bucle: TOK_WHILE TOK_PARENTESISIZQUIERDO exp TOK_PARENTESISDERECHO TOK_LLAVEIZQUIERDA sentencias TOK_LLAVEDERECHA
	 {
		fprintf(yyout, ";R52:\t while(<exp>){<sentencias>}");
	 }
	 ;

lectura: TOK_SCANF identificador
	   {
			fprintf(yyout, ";R54:\t scanf <identificador>");
	   }
	   ;

escritura: TOK_PRINTF exp
		 {
			fprintf(yyout, ";R56:\t printf <exp>");
		 }
		 ;

retorno_funcion: TOK_RETURN exp
			   {
					fprintf(yyout, ";R61:\t return <exp>");
			   }
			   ;

exp: exp TOK_MAS exp
   {
		fprintf(yyout, ";R72:\t <exp> + <exp>");
   }
   | exp TOK_MENOS exp
   {
		fprintf(yyout, ";R73:\t <exp> - <exp>");
   }
   | exp TOK_DIVISION exp
   {
		fprintf(yyout, ";R74:\t <exp> / <exp>");
   }
   | exp TOK_ASTERISCO exp
   {
		fprintf(yyout, ";R75:\t <exp> * <exp>");
   }
   | TOK_MENOS exp
   {
		fprintf(yyout, ";R76:\t - <exp>");
   }
   | exp TOK_AND exp
   {
		fprintf(yyout, ";R77:\t <exp> && <exp>");
   }
   | exp TOK_OR exp
   {
		fprintf(yyout, ";R78:\t <exp> || <exp>");
   }
   | TOK_NOT exp
   {
		fprintf(yyout, ";R79:\t ! <exp>");
   }
   | identificador
   {
		fprintf(yyout, ";R80:\t <identificador>");
   }
   | constante
   {
		fprintf(yyout, ";R81:\t <constante>");
   }
   | TOK_PARENTESISIZQUIERDO exp TOK_PARENTESISDERECHO
   {
		fprintf(yyout, ";R82:\t (<exp>)");
   }
   | TOK_PARENTESISIZQUIERDO comparacion TOK_PARENTESISDERECHO
   {
		fprintf(yyout, ";R83:\t (<comparacion>)");
   }
   | elemento_vector
   {
		fprintf(yyout, ";R85:\t <elemento_vector>");
   }
   | identificador TOK_PARENTESISIZQUIERDO lista_expresiones TOK_PARENTESISDERECHO
   {
		fprintf(yyout, ";R88:\t <identificador> (<lista_expresiones>)");
   }
   ;

lista_expresiones: exp resto_lista_expresiones
				 {
					fprintf(yyout, ";R89:\t <exp> <resto_lista_expresiones>");
				 }
				 |
				 {
					fprintf(yyout, ";R90:\t");
				 }
				 ;

resto_lista_expresiones: TOK_COMA exp resto_lista_expresiones
					   {
							fprintf(yyout, ";R91:\t , <exp> <resto_lista_expresiones>");
					   }
					   |
					   {
							fprintf(yyout, ";R92\t");
					   }
					   ;

comparacion: exp TOK_IGUAL exp
		   {
				fprintf(yyout, ";R93\t <exp> == <exp>");
		   }
		   | exp TOK_DISTINTO exp
		   {
				fprintf(yyout, ";R94\t <exp> != <exp>");
		   }
		   | exp TOK_MENORIGUAL exp
		   {
				fprintf(yyout, ";R95\t <exp> <= <exp>");
		   }
		   | exp TOK_MAYORIGUAL exp
		   {
				fprintf(yyout, ";R96\t <exp> >= <exp>");
		   }
		   | exp TOK_MENOR exp
		   {
				fprintf(yyout, ";R97\t <exp> < <exp>");
		   }
		   | exp TOK_MAYOR exp
		   {
				fprintf(yyout, ";R98\t <exp> > <exp>");
		   }
		   ;

constante: constante_logica
		 {
			fprintf(yyout, ";R99\t <constante_logica>");
		 }
		 | constante_entera
		 {
			fprintf(yyout, ";R100\t <constante_entera>");
		 }
		 ;

constante_logica: TOK_TRUE
				{
					fprintf(yyout, ";R102\t true");
				}
				| TOK_FALSE
				{
					fprintf(yyout, ";R103\t false");
				}
				;

constante_entera: TOK_CONSTANTE_ENTERA
				{
					fprintf(yyout, ";R104\t <>");
				}
				;

identificador: TOK_IDENTIFICADOR
			 {
				fprintf(yyout, ";R108\t identificador");
			 }
			 ;

%%


int main(int argc, char* argv[])
{
yyin = fopen(argv[1], "r");
yyout = fopen(argv[2], "w");

salida_parser =yyparse();

fclose(yyin);
fclose(yyout);
return salida_parser;
}

int yyerror (char* s)
{

	if (error_morfo == 0)
		printf("****Error sintactico en [lin %d, col %d]\n", fila, column);
	return 1;
}
