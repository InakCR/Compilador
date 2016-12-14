
%{
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include "alfa.h"

extern int column,fila,error_morfo;
extern FILE *yyin, *yyout;
extern char *yytext;
extern int yylex();
extern int yyleng;

int yyerror(char* s);
int salida_parser;

INFO_SIMBOLO * sim = NULL;
TABLA_HASH* global = NULL, *local = NULL;
char err[200];

int categoria,tipo_actual;
int clase_actual,tamanio_vector_actual;
int pos_variable_local_actual=1;
int num_variables_locales_actual=0;
int pos_parametro_actual=0;
int num_parametros_actual=0;
%}

%union{
	tipo_atributos atributos;
}

%token <atributos> TOK_OPCION
%token <atributos> TOK_SIGUIENTE
%token <atributos> TOK_MAIN
%token <atributos> TOK_INT
%token <atributos> TOK_BOOLEAN
%token <atributos> TOK_ARRAY
%token <atributos> TOK_FUNCTION
%token <atributos> TOK_IF
%token <atributos> TOK_ELSE
%token <atributos> TOK_WHILE
%token <atributos> TOK_SCANF
%token <atributos> TOK_PRINTF
%token <atributos> TOK_RETURN

%token <atributos> TOK_PUNTOYCOMA
%token <atributos> TOK_COMA
%token <atributos> TOK_PARENTESISIZQUIERDO
%token <atributos> TOK_PARENTESISDERECHO
%token <atributos> TOK_CORCHETEIZQUIERDO
%token <atributos> TOK_CORCHETEDERECHO
%token <atributos> TOK_LLAVEIZQUIERDA
%token <atributos> TOK_LLAVEDERECHA
%token <atributos> TOK_ASIGNACION
%token <atributos> TOK_MAS
%token <atributos> TOK_MENOS
%token <atributos> TOK_DIVISION
%token <atributos> TOK_ASTERISCO
%token <atributos> TOK_AND
%token <atributos> TOK_OR
%token <atributos> TOK_NOT
%token <atributos> TOK_IGUAL
%token <atributos> TOK_DISTINTO
%token <atributos> TOK_MENORIGUAL
%token <atributos> TOK_MAYORIGUAL
%token <atributos> TOK_MENOR
%token <atributos> TOK_MAYOR

%token <atributos> TOK_IDENTIFICADOR

%token <atributos> TOK_CONSTANTE_ENTERA
%token <atributos> TOK_TRUE
%token <atributos> TOK_FALSE

%type <atributos> programa
%type <atributos> declaraciones
%type <atributos> declaracion
%type <atributos> clase
%type <atributos> identificadores
%type <atributos> clase_escalar
%type <atributos> tipo
%type <atributos> clase_vector
%type <atributos> constante_entera
%type <atributos> identificador
%type <atributos> funciones
%type <atributos> funcion
%type <atributos> parametros_funcion
%type <atributos> parametro_funcion
%type <atributos> declaraciones_funcion
%type <atributos> resto_parametros_funcion
%type <atributos> sentencias
%type <atributos> sentencia
%type <atributos> sentencia_simple
%type <atributos> asignacion
%type <atributos> lectura
%type <atributos> escritura
%type <atributos> retorno_funcion
%type <atributos> exp
%type <atributos> idpf


%left TOK_MAS TOK_MENOS TOK_OR
%left TOK_ASTERISCO TOK_DIVISION TOK_AND
%left TOK_NOT

%right SIG

%%

programa: inicioTabla TOK_MAIN TOK_LLAVEIZQUIERDA declaraciones escritura_TS funciones escritura_main sentencias TOK_LLAVEDERECHA finTabla
		{
				fprintf(yyout, ";R1:\t<programa> ::= main { <declaraciones> <funciones> <sentencias> }\n");
		}
		;
inicioTabla:
			{
				global = crear_tabla(HASHSIZE);
			}
			;
escritura_TS:
			{
				escribirSegmentos(yyout,global);
			}
			;
escritura_main:
			{
				escribirImain(yyout);
			}
			;
finTabla:
		{
			liberar_tabla(global);
			escribirFmain(yyout);
		}
declaraciones: declaracion
			 {
				fprintf(yyout, ";R2:\t<declaraciones> ::= <declaracion>\n");
			 }
			 | declaracion declaraciones
			 {
				fprintf(yyout, ";R3:\t<declaraciones> ::= <declaracion> <declaraciones>\n");
			 }
			 ;

declaracion: clase identificadores TOK_PUNTOYCOMA
		   {
				fprintf(yyout, ";R4:\t<declaracion> ::= <clase> <identificadores> ;\n");
		   }
		   ;

clase: clase_escalar
	 {
	  clase_actual=ESCALAR;
		fprintf(yyout, ";R5:\t<clase> ::= <clase_escalar>\n");
	 }
	 | clase_vector
	 {
	  clase_actual=VECTOR;
		fprintf(yyout, ";R7:\t<clase> ::= <clase_vector>\n");
	 }
	 ;

clase_escalar: tipo
			 {
				fprintf(yyout, ";R9:\t<clase_escalar> ::= <tipo>\n");
			 }
			 ;
tipo: TOK_INT
	{
		tipo_actual=INT;
		fprintf(yyout, ";R10:\t<tipo> ::= int\n");
	}
	| TOK_BOOLEAN
	{
		tipo_actual=BOOLEAN;
		fprintf(yyout, ";R11:\t<tipo> ::= <boolean>\n");
	}
	;

clase_vector: TOK_ARRAY tipo TOK_CORCHETEIZQUIERDO TOK_CONSTANTE_ENTERA TOK_CORCHETEDERECHO
			{
				tamanio_vector_actual = $4.valor_entero;
				if ((tamanio_vector_actual < 1 ) ||
						(tamanio_vector_actual > MAX_TAMANIO_VECTOR))
				{
					sprintf(err,"****Error semantico en lin %d: El tamanyo del vector %s excede los limites permitidos (1,64).",fila,$4.lexema);
					yyerror(err);
				}
				fprintf(yyout, ";R15:\t<clase_vector> ::= array <tipo> [ <constante_entera> ]\n");
			}
			;

identificadores: identificador
			   {
					fprintf(yyout, ";R18:\t<identificadores> ::= <identificador>\n");
			   }
			   | identificador TOK_COMA identificadores
			   {
					fprintf(yyout, ";R19:\t<identificadores> ::= <identificador> , <identificadores>\n");
			   }
			   ;

funciones: funcion funciones
		 {
			fprintf(yyout, ";R20:\t<funciones> ::= <funcion> <funciones>\n");
		 }
		 |
		 {
			fprintf(yyout, ";R21:\t<funciones> ::=\n");
		 }
		 ;

funcion: fn_declaracion sentencias TOK_LLAVEDERECHA
	   {
			liberar_tabla(local);
			sim = buscar($1.lexema);
			if(sim==NULL){
				sprintf(err,"****Error semantico en lin %d: Acceso a variable no declarada (%s).",fila, $1.lexema);
				yyerror(err);
			}
			sim.adicional1 = num_parametros_actual;

			fprintf(yyout, ";R22:\t<funcion> ::= function <tipo> <identificador> ( <parametros_funcion> ) { <declaraciones_funcion> <sentencias> }\n");
	   }
	   ;
fn_name : TOK_FUNCTION tipo TOK_IDENTIFICADOR
		{
			sim = buscar($3.lexema);

			if(sim!=NULL){
				sprintf(err,"****Error semantico en lin %d: Declaracion duplicada.",fila);
				yyerror(err);
			}

			insertar_simbolo(global,$3.lexema,FUNCION,tipo_actual,clase_actual,0,0);
			local = crear_tabla(HASHSIZE);
			insertar_simbolo(local,$3.lexema,FUNCION,tipo_actual,clase_actual,0,0);

			num_variables_locales_actual = 0;
			pos_variable_local_actual = 1;
 			num_parametros_actual = 0;
 			pos_parametro_actual = 0;

			strcpy($$.lexema,$3.lexema);
		}
		;
fn_declaration : fn_name TOK_PARENTESISIZQUIERDO parametros_funcion TOK_PARENTESISDERECHO TOK_LLAVEIZQUIERDA declaraciones_funcion
				{
					sim = buscar($1.lexema);
					if(sim!=NULL){
						sprintf(err,"****Error semantico en lin %d: Declaracion duplicada.",fila);
						yyerror(err);
					}
					sim.adicional1 = num_parametros_actual;
					strcpy($$.lexema,$1.lexema);
				}
				;
parametros_funcion: parametro_funcion resto_parametros_funcion
				  {
					fprintf(yyout, ";R23:\t<parametros_funcion> ::= <parametro_funcion> <resto_parametros_funcion>\n");
				  }
				  |
				  {
					fprintf(yyout, ";R24:\t<parametros_funcion> ::=\n");
				  }
				  ;

resto_parametros_funcion: TOK_PUNTOYCOMA parametro_funcion resto_parametros_funcion
						{
							fprintf(yyout, ";R25:\t<resto_parametros_funcion> ::= ; <parametro_funcion> <resto_parametros_funcion>\n");
						}
						|
						{
							fprintf(yyout, ";R26:\tt<resto_parametros_funcion> ::=\n");
						}
						;

parametro_funcion: tipo idpf
				 {
					fprintf(yyout, ";R27:\t<parametro_funcion> ::= <tipo> <identificador>\n");
				 }
				 ;

declaraciones_funcion: declaraciones
					 {
						fprintf(yyout, ";R28:\t<declaraciones_funcion> ::= <declaraciones>\n");
					 }
					 |
					 {
						fprintf(yyout, ";R29:\t<declaraciones_funcion> ::=\n");
					 }
					 ;

sentencias: sentencia
		  {
			fprintf(yyout, ";R30:\t<sentencias> ::= <sentencia>\n");
		  }
		  | sentencia sentencias
		  {
			fprintf(yyout, ";R31:\t<sentencias> ::= <sentencia> <sentencias>\n");
		  }
		  ;

sentencia: sentencia_simple TOK_PUNTOYCOMA
		 {
			fprintf(yyout, ";R32:\t<sentencia> ::= <sentencia_simple> ;\n");
		 }
		 | bloque
		 {
			fprintf(yyout, ";R33:\t<sentencia> ::= <bloque>\n");
		 }
		 ;

sentencia_simple: asignacion
				{
					fprintf(yyout, ";R34:\t<sentencia_simple> ::= <asignacion>\n");
				}
				| lectura
				{
					fprintf(yyout, ";R35:\t<sentencia_simple> ::= <lectura>\n");
				}
				| escritura
				{
					fprintf(yyout, ";R36:\t<sentencia_simple> ::= <escritura>\n");
				}
				| retorno_funcion
				{
					fprintf(yyout, ";R38:\t<sentencia_simple> ::= <retorno_funcion>\n");
				}
				;

bloque: condicional
	  {
		fprintf(yyout, ";R40:\t<bloque> ::= <condicional>\n");
	  }
	  | bucle
	  {
		fprintf(yyout, ";R41:\t<bloque> ::= <bucle>\n");
	  }
	  ;

asignacion: TOK_IDENTIFICADOR TOK_ASIGNACION exp
		  {
			fprintf(yyout, ";R43:\t<asignacion> ::= <identificador> = <exp>\n");
		  }
		  | elemento_vector TOK_ASIGNACION exp
		  {
			fprintf(yyout, ";R44:\t<asignacion> ::= <elemento_vector> = <exp>\n");
		  }
		  ;

elemento_vector: TOK_IDENTIFICADOR TOK_CORCHETEIZQUIERDO exp TOK_CORCHETEDERECHO
			   {
					fprintf(yyout, ";R48:\t<elemento_vector> ::= <identificador> [ <exp> ]\n");
			   }
			   ;

condicional: TOK_IF TOK_PARENTESISIZQUIERDO exp TOK_PARENTESISDERECHO TOK_LLAVEIZQUIERDA sentencias TOK_LLAVEDERECHA
		   {
				fprintf(yyout, ";R50:\t<condicional> ::= if( <exp> ){ <sentencias> }\n");
		   }
		   | TOK_IF TOK_PARENTESISIZQUIERDO exp TOK_PARENTESISDERECHO TOK_LLAVEIZQUIERDA sentencias TOK_LLAVEDERECHA TOK_ELSE TOK_LLAVEIZQUIERDA sentencias TOK_LLAVEDERECHA
		   {
				fprintf(yyout, ";R51:\t<condicional> ::= if( <exp> ){ <sentencias> } else { <sentencias> }\n");
		   }
		   ;

bucle: TOK_WHILE TOK_PARENTESISIZQUIERDO exp TOK_PARENTESISDERECHO TOK_LLAVEIZQUIERDA sentencias TOK_LLAVEDERECHA
	 {
		fprintf(yyout, ";R52:\t<bucle> ::= while ( <exp> ){ <sentencias> }\n");
	 }
	 ;

lectura: TOK_SCANF TOK_IDENTIFICADOR
	   {
			sim = buscar_simbolo(local, $2.lexema);
			if(sim==NULL){
				sprintf(err,"****Error semantico en lin %d: Acceso a variable no declarada (%s).",fila, $1.lexema);
				yyerror(err);
			}
			else{
				if(sim->CATEGORIA==FUNCION){
					sprintf(err,"****Error semantico en lin %d: Acceso a variable no declarada (%s).",fila, $1.lexema);
					yyerror(err);
				}
				if(sim->CLASE==VECTOR){
					sprintf(err,"****Error semantico en lin %d: Acceso a variable no declarada (%s).",fila, $1.lexema);
					yyerror(err);
				}
			}
			fprintf(yyout, ";R54:\t<lectura> ::= scanf <identificador>\n");
	   }
	   ;

escritura: TOK_PRINTF exp
		 {
			fprintf(yyout, ";R56:\t<escritura> ::= printf <exp>\n");
		 }
		 ;

retorno_funcion: TOK_RETURN exp
			   {
					fprintf(yyout, ";R61:\t<retorno_funcion> ::= return <exp>\n");
			   }
			   ;

exp: exp TOK_MAS exp
   {
		fprintf(yyout, ";R72:\t<exp> ::= <exp> + <exp>\n");
   }
   | exp TOK_MENOS exp
   {
		fprintf(yyout, ";R73:\t<exp> ::= <exp> - <exp>\n");
   }
   | exp TOK_DIVISION exp
   {
		fprintf(yyout, ";R74:\t<exp> ::= <exp> / <exp>\n");
   }
   | exp TOK_ASTERISCO exp
   {
		fprintf(yyout, ";R75:\t<exp> ::= <exp> * <exp>\n");
   }
   | TOK_MENOS exp %prec SIG
   {
		fprintf(yyout, ";R76:\t<exp> ::= - <exp>\n");
   }
   | exp TOK_AND exp
   {
		fprintf(yyout, ";R77:\t<exp> ::= <exp> && <exp>\n");
   }
   | exp TOK_OR exp
   {
		fprintf(yyout, ";R78:\t<exp> ::= <exp> || <exp>\n");
   }
   | TOK_NOT exp
   {
		fprintf(yyout, ";R79:\t<exp> ::= ! <exp>\n");
   }
   | TOK_IDENTIFICADOR
   {
		fprintf(yyout, ";R80:\t<exp> ::= <identificador>\n");
   }
   | constante
   {
		fprintf(yyout, ";R81:\t<exp> ::= <constante>\n");
   }
   | TOK_PARENTESISIZQUIERDO exp TOK_PARENTESISDERECHO
   {
		fprintf(yyout, ";R82:\t<exp> ::= ( <exp> )\n");
   }
   | TOK_PARENTESISIZQUIERDO comparacion TOK_PARENTESISDERECHO
   {
		fprintf(yyout, ";R83:\t<exp> ::= ( <comparacion> )\n");
   }
   | elemento_vector
   {
		fprintf(yyout, ";R85:\t<exp> ::= <elemento_vector>\n");
   }
   | TOK_IDENTIFICADOR TOK_PARENTESISIZQUIERDO lista_expresiones TOK_PARENTESISDERECHO
   {
		fprintf(yyout, ";R88:\t<exp> ::= <identificador> ( <lista_expresiones> )\n");
   }
   ;

lista_expresiones: exp resto_lista_expresiones
				 {
					fprintf(yyout, ";R89:\t<lista_expresiones> ::= <exp> <resto_lista_expresiones>\n");
				 }
				 |
				 {
					fprintf(yyout, ";R90:\t<lista_expresiones> ::=\n");
				 }
				 ;

resto_lista_expresiones: TOK_COMA exp resto_lista_expresiones
					   {
							fprintf(yyout, ";R91:\t<resto_lista_expresiones> ::= , <exp> <resto_lista_expresiones>\n");
					   }
					   |
					   {
							fprintf(yyout, ";R92:\t<resto_lista_expresiones> ::=\n");
					   }
					   ;

comparacion: exp TOK_IGUAL exp
		   {
				fprintf(yyout, ";R93:\t<comparacion> ::= <exp> == <exp>\n");
		   }
		   | exp TOK_DISTINTO exp
		   {
				fprintf(yyout, ";R94:\t<comparacion> ::= <exp> != <exp>\n");
		   }
		   | exp TOK_MENORIGUAL exp
		   {
				fprintf(yyout, ";R95:\t<comparacion> ::= <exp> <= <exp>\n");
		   }
		   | exp TOK_MAYORIGUAL exp
		   {
				fprintf(yyout, ";R96:\t<comparacion> ::= <exp> >= <exp>\n");
		   }
		   | exp TOK_MENOR exp
		   {
				fprintf(yyout, ";R97:\t<comparacion> ::= <exp> < <exp>\n");
		   }
		   | exp TOK_MAYOR exp
		   {
				fprintf(yyout, ";R98:\t<comparacion> ::= <exp> > <exp>\n");
		   }
		   ;

constante: constante_logica
		 {
			fprintf(yyout, ";R99:\t<constante> ::= <constante_logica>\n");
		 }
		 | constante_entera
		 {
			fprintf(yyout, ";R100:\t<constante> ::= <constante_entera>\n");
		 }
		 ;

constante_logica: TOK_TRUE
				{
					fprintf(yyout, ";R102:\t<constante_logica> ::= true\n");
				}
				| TOK_FALSE
				{
					fprintf(yyout, ";R103:\t<constante_logica> ::= false\n");
				}
				;

constante_entera: TOK_CONSTANTE_ENTERA
				{
					fprintf(yyout, ";R104:\t<constante_entera> ::= TOK_CONSTANTE_ENTERA\n");
				}
				;

identificador: TOK_IDENTIFICADOR
			{
			 sim = buscar($1.lexema);
			 if(sim!=NULL){
				 sprintf(err,"****Error semantico en lin %d: Declaracion duplicada.",fila);
				 yyerror(err);
			 }
			 if(local==NULL){
					insertar_simbolo(global,$1.lexema,VARIABLE,tipo_actual,clase_actual,tamanio_vector_actual,0);
					pos_variable_local_actual++:
			}else{
				if(clase_actual!=ESCALAR){
					sprintf(err,"****Error semantico en lin %d: Variable local de tipo no escalar.",fila);
					yyerror(err);
				}
				insertar_simbolo(local,$1.lexema,categoria,tipo,clase,tamanio_vector_actual,pos_variable_local_actual);
				pos_variable_local_actual++;
				num_variables_locales_actual++;
			}
			fprintf(yyout, ";R108:\t<identificador> ::= TOK_IDENTIFICADOR\n");
		 }
		 ;
idpf: TOK_IDENTIFICADOR
	{
		sim = buscar($1.lexema);

		if(sim!=NULL){
			sprintf(err,"****Error semantico en lin %d: Declaracion duplicada.",fila);
			yyerror(err);
		}

		insertar_simbolo(local,$1.lexema,categoria,tipo,clase,tamanio_vector_actual,pos_parametro_actual);
		pos_parametro_actual++;
		num_parametros_actual++;
	}
	;
%%

INFO_SIMBOLO *buscar(const char *lexema) {
	if(local==NULL){
		return buscar_simbolo(local,lexema);
	}
	return buscar_simbolo(global,lexema);
}

int yyerror (char* s){
	if (error_morfo == 0){
		column-=yyleng;
		fprintf(stdr,"****Error sintactico en [lin %d, col %d]\n", fila, column);
	}
	fprintf(stdr,"%s",s);
	return 1;
}
