
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include "alfa.h"
#include "gceracion_codigo.h"

extern int column,fila,error_morfo;
extern FILE *yyin, *yyout;
extern char *yytext;
extern int yylex();
extern int yyleng;

int yyerror(char* s);


INFO_SIMBOLO* sim = NULL;
INFO_SIMBOLO* funcionA = NULL;
TABLA_HASH* global = NULL, *local = NULL;
char err[200];
int etiqueta=0;

int categoria_actual,tipo_actual;
int clase_actual,tamanio_vector_actual;
int pos_variable_local_actual = 1;
int num_variables_locales_actual = 0;
int pos_parametro_actual = 0;
int num_parametros_actual = 0;
int num_parametros_llamada_actual = 0;
int en_explist = 1;
int fn_return = 0;
%}

%union
{
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
%type <atributos> constante_logica
%type <atributos> constante_entera
%type <atributos> constante
%type <atributos> comparacion
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
%type <atributos> fn_name
%type <atributos> fn_declaration
%type <atributos> exp
%type <atributos> elemento_vector
%type <atributos> if_exp
%type <atributos> if_exp_sentencias
%type <atributos> while
%type <atributos> while_exp
%type <atributos> bucle
%type <atributos> idpf

%start programa
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

funcion: fn_declaration sentencias TOK_LLAVEDERECHA
	   {
			liberar_tabla(local);
			sim = buscar($1.lexema);
			if(sim==NULL){
				sprintf(err,"****Error semantico en lin %d: Acceso a variable no declarada (%s).",fila, $1.lexema);
				yyerror(err);
			}
			sim->adicional1 = num_parametros_actual;
			sim->adicional2 = num_variables_locales_actual;
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
			/*Guardamos el INFO_SIMBOLO de la funcion*/
			funcionA=sim;
		}
		;
fn_declaration : fn_name TOK_PARENTESISIZQUIERDO parametros_funcion TOK_PARENTESISDERECHO TOK_LLAVEIZQUIERDA declaraciones_funcion
				{
					sim = buscar($1.lexema);
					if(sim!=NULL){
						sprintf(err,"****Error semantico en lin %d: Declaracion duplicada.",fila);
						yyerror(err);
					}
					sim->adicional1 = num_parametros_actual;
					sim->adicional2 = num_variables_locales_actual;
					strcpy($$.lexema,$1.lexema);
					gc_fn_declaration(yyout,$1.lexema, num_parametros_actual);
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
			sim = buscar($1.lexema);

			if(sim == NULL){
				sprintf(err,"****Error semantico en lin %d: Acceso a variable no declarada (%s).",fila, $1.lexema);
				yyerror(err);
			}

			if(sim->categoria == FUNCION){
				sprintf(err,"****Error semantico en lin %d: Identificador de categoria Funcion ",fila);
				yyerror(err);
			}

			if(sim->clase != ESCALAR){
				sprintf(err,"****Error semantico en lin %d: Variable local de tipo no escalar.",fila);
				yyerror(err);
			}

			 if(sim->tipo != $3.tipo){
				sprintf(err,"****Error semantico en lin %d: Asignacion incompatible.",fila);
				yyerror(err);
			}
			/*Si la tabla local esta abierta se estara insertando en una funcion*/
			if(local==NULL){
				gc_asignacion_iden(yyout,$3.es_direccion,$1.lexema);
			}else{
				gc_asignacion_funcion(yyout,$3.es_direccion,sim->categoria,sim->adicional2,funcion->adicional1);
			}
			fprintf(yyout, ";R43:\t<asignacion> ::= <identificador> = <exp>\n");
		  }
		  | elemento_vector TOK_ASIGNACION exp
		  {
			if($1.tipo != $3.tipo){
				sprintf(err,"****Error semantico en lin %d: Asignacion incompatible.",fila);
				yyerror(err);
			}
			gc_asignacion_vector(yyout,$3.es_direccion);
			fprintf(yyout, ";R44:\t<asignacion> ::= <elemento_vector> = <exp>\n");
		  }
		  ;

elemento_vector: TOK_IDENTIFICADOR TOK_CORCHETEIZQUIERDO exp TOK_CORCHETEDERECHO
			   {
					sim = buscar($1.lexema);

		 			if(sim == NULL){
		 				sprintf(err,"****Error semantico en lin %d: Acceso a variable no declarada (%s).",fila, $1.lexema);
		 				yyerror(err);
		 			}
					if(sim->clase != VECTOR){
						sprintf(err,"****Error semantico en lin %d:Intento de indexacion de una variable que no es de tipo vector.",fila);
						yyerror(err);
					}
					if($3.tipo != INT){
						sprintf(err,"**** Error semantico en lin %d: El indice en una operacion de indexacion tiene que ser de tipo entero.\n", fila);
						yyerror(err);
					}
					if($3.es_direccion==0){
						if($3.valor_entero < 0 || $3.valor_entero > (MAX_TAMANIO_VECTOR-1)){
							sprintf(err,"**** Error semantico en lin %d: El tamanyo del vector <%s> excede los limites permitidos (1,64).\n", fila, $1.lexema);
							yyerror(err);
						}
					}
					$$.tipo = sim->tipo;
					$$.es_direccion = 1;
					gc_asignacion_elemento_vector(yyout,$3.es_direccion,$1.lexema);
					fprintf(yyout, ";R48:\t<elemento_vector> ::= <identificador> [ <exp> ]\n");
			   }
			   ;

condicional: if_exp sentencias TOK_LLAVEDERECHA
			 		{
						gc_condicional(yyout,$1.etiqueta);
			 		}
			 		| if_exp_sentencias TOK_ELSE TOK_LLAVEIZQUIERDA sentencias TOK_LLAVEDERECHA
			 		{
						gc_condicional(yyout,$1.etiqueta);
			 		}
			 		;
if_exp_sentencias: if_exp sentencias
							{
								$$.etiqueta = $1.etiqueta;
								gc_if_exp_sentencias(yyout,$1.etiqueta);
							}
							;
if_exp: TOK_IF TOK_PARENTESISIZQUIERDO exp TOK_PARENTESISDERECHO TOK_LLAVEIZQUIERDA
		   {
				if($3.tipo != BOOLEAN){
					sprintf(err,"****Error semantico en lin %d: Condicional con condicion de tipo int.",fila);
					yyerror(err);
				}
				$$.etiqueta = etiqueta++;
				gc_if_exp(yyout,$3.es_direccion,$$.etiqueta);
				fprintf(yyout, ";R50:\t<condicional> ::= if( <exp> ){ <sentencias> }\n");
		   }
		   ;
while: TOK_WHILE TOK_PARENTESISIZQUIERDO
		{
			$$.etiqueta = etiqueta++;
			gc_while(yyout,etiqueta);
		}
		;
while_exp: while exp TOK_PARENTESISDERECHO TOK_LLAVEIZQUIERDA
				{
					if($2.tipo != BOOLEAN){
						sprintf(err,"****Error semantico en lin %d: Condicional con condicion de tipo int.",fila);
						yyerror(err);
					}
					$$.etiqueta = $1.etiqueta;
					gc_while_exp(yyout,$2.es_direccion,$1.etiqueta);
				}
				;
bucle: while_exp sentencias TOK_LLAVEDERECHA
	 {
		gc_bucle(yyout,$1.etiqueta);
		fprintf(yyout, ";R52:\t<bucle> ::= while ( <exp> ){ <sentencias> }\n");
	 }
	 ;

lectura: TOK_SCANF TOK_IDENTIFICADOR
	   {
			sim = buscar($2.lexema);
			if(sim==NULL){
				sprintf(err,"****Error semantico en lin %d: Acceso a variable no declarada (%s).",fila, $1.lexema);
				yyerror(err);
			}
			else{
				if(sim->categoria==FUNCION){
					sprintf(err,"****Error semantico en lin %d: Identificador de categoria Funcion.",fila);
					yyerror(err);
				}
				if(sim->clase==VECTOR){
					sprintf(err,"****Error semantico en lin %d: Variable local de tipo no escalar.",fila);
					yyerror(err);
				}
			}
			gc_lectura(yyout,$2.lexema,$2.tipo);
			fprintf(yyout, ";R54:\t<lectura> ::= scanf <identificador>\n");
	   }
	   ;

escritura: TOK_PRINTF exp
		 {
			gc_escritura(yyout,$2.es_direccion,$2.tipo);
			fprintf(yyout, ";R56:\t<escritura> ::= printf <exp>\n");
		 }
		 ;

retorno_funcion: TOK_RETURN exp
			   {
					if(funcionA->tipo != $2.tipo){
						sprintf(err,"**** Error semantico en lin %d:Asignacion incompatible",linea);
						yyerror(err);
					}
					if($2.es_direccion != 1 && $2.es_direccion != 0){
						sprintf(err,"**** Error semantico en lin %d:Asignacion incompatible",linea);
						yyerror(err);
					}

					fn_return++;
					gc_retorno_funcion(yyout,$2.es_direccion);
					fprintf(yyout, ";R61:\t<retorno_funcion> ::= return <exp>\n");
			   }
			   ;

exp: exp TOK_MAS exp
   {
		if($1.tipo != INT || $3.tipo != INT){
			sprintf(err,"****Error semantico en lin %d: Operacion aritmetica con operandos boolean.",fila);
			yyerror(err);
		}
		$$.tipo = INT;
		$$.es_direccion = 0;
		gc_suma_enteros(yyout, $1.es_direccion, $3.es_direccion);

		fprintf(yyout, ";R72:\t<exp> ::= <exp> + <exp>\n");
   }
   | exp TOK_MENOS exp
   {
   		if($1.tipo != INT || $3.tipo != INT){
			sprintf(err,"****Error semantico en lin %d: Operacion aritmetica con operandos boolean.",fila);
			yyerror(err);
		}
		$$.tipo = INT;
		$$.es_direccion = 0;
		gc_resta_enteros(yyout, $1.es_direccion, $3.es_direccion);

		fprintf(yyout, ";R73:\t<exp> ::= <exp> - <exp>\n");
   }
   | exp TOK_DIVISION exp
   {
   		if($1.tipo != INT || $3.tipo != INT){
			sprintf(err,"****Error semantico en lin %d: Operacion aritmetica con operandos boolean.",fila);
			yyerror(err);
		}
		$$.tipo = INT;
		$$.es_direccion = 0;
		gc_div_enteros(yyout, $1.es_direccion, $3.es_direccion);

		fprintf(yyout, ";R74:\t<exp> ::= <exp> / <exp>\n");
   }
   | exp TOK_ASTERISCO exp
   {
   		if($1.tipo != INT || $3.tipo != INT){
			sprintf(err,"****Error semantico en lin %d: Operacion aritmetica con operandos boolean.",fila);
			yyerror(err);
		}
		$$.tipo = INT;
		$$.es_direccion = 0;
		gc_mult_enteros(yyout, $1.es_direccion, $3.es_direccion);

		fprintf(yyout, ";R75:\t<exp> ::= <exp> * <exp>\n");
   }
   | TOK_MENOS exp %prec SIG
   {
   		if($2.tipo != INT){
			sprintf(err,"****Error semantico en lin %d: Operacion aritmetica con operandos boolean.",fila);
			yyerror(err);
		}
		$$.tipo = INT;
		$$.es_direccion = 0;
		gc_neg_enteros(yyout, $2.es_direccion);

		fprintf(yyout, ";R76:\t<exp> ::= - <exp>\n");
   }
   | exp TOK_AND exp
   {
		if($1.tipo != BOOLEAN || $3.tipo != BOOLEAN){
			sprintf(err,"****Error semantico en lin %d: Operacion logica con operandos int.",fila);
			yyerror(err);
		}
		$$.tipo = BOOLEAN;
		$$.es_direccion = 0;
		gc_and_enteros(yyout, $1.es_direccion, $3.es_direccion);

		fprintf(yyout, ";R77:\t<exp> ::= <exp> && <exp>\n");
   }
   | exp TOK_OR exp
   {
   		if($1.tipo != BOOLEAN || $3.tipo != BOOLEAN){
			sprintf(err,"****Error semantico en lin %d: Operacion logica con operandos int.",fila);
			yyerror(err);
		}
		$$.tipo = BOOLEAN;
		$$.es_direccion = 0;
		gc_or_enteros(yyout, $1.es_direccion, $3.es_direccion);

		fprintf(yyout, ";R78:\t<exp> ::= <exp> || <exp>\n");
   }
   | TOK_NOT exp
   {
   		if($2.tipo != BOOLEAN){
			sprintf(err,"****Error semantico en lin %d: Operacion logica con operandos int.",fila);
			yyerror(err);
		}
		$$.tipo = BOOLEAN;
		$$.es_direccion = 0;
		etiqueta++;
		gc_not_enteros(yyout, $2.es_direccion,etiqueta);

		fprintf(yyout, ";R79:\t<exp> ::= ! <exp>\n");
   }
   | TOK_IDENTIFICADOR
   {
		sim = buscar($1.lexema);

		if(sim == NULL){
			sprintf(err,"****Error semantico en lin %d: Acceso a variable no declarada (%s).",fila, $1.lexema);
			yyerror(err);
		}

		if(sim->clase != ESCALAR){
			sprintf(err,"****Error semantico en lin %d: Variable local de tipo no escalar.",fila);
			yyerror(err);
		}

		if(sim->categoria == FUNCION){
			sprintf(err,"****Error semantico en lin %d: Identificador de categoria Funcion",fila);
			yyerror(err);
		}

		$$.tipo = sim->tipo;
		$$.es_direccion = 1;
    /************************************* GENERAR*/////
		fprintf(yyout, ";R80:\t<exp> ::= <identificador>\n");
   }
   | constante
   {
		$$.tipo = $1.tipo;
		$$.es_direccion = $1.es_direccion;

		fprintf(yyout, ";R81:\t<exp> ::= <constante>\n");
   }
   | TOK_PARENTESISIZQUIERDO exp TOK_PARENTESISDERECHO
   {
		$$.tipo = $2.tipo;
		$$.es_direccion = $2.es_direccion;

		fprintf(yyout, ";R82:\t<exp> ::= ( <exp> )\n");
   }
   | TOK_PARENTESISIZQUIERDO comparacion TOK_PARENTESISDERECHO
   {
		$$.tipo = $2.tipo;
		$$.es_direccion = $2.es_direccion;

		fprintf(yyout, ";R83:\t<exp> ::= ( <comparacion> )\n");
   }
   | elemento_vector
   {
		$$.tipo = $1.tipo;
		$$.es_direccion = $1.es_direccion;

		fprintf(yyout, ";R85:\t<exp> ::= <elemento_vector>\n");
   }
   | idf_llamada_funcion TOK_PARENTESISIZQUIERDO lista_expresiones TOK_PARENTESISDERECHO
   {
		sim = buscar($1.lexema);

		if(sim == NULL){
			sprintf(err,"****Error semantico en lin %d: Acceso a variable no declarada (%s).",fila, $1.lexema);
			yyerror(err);
		}
		if(num_parametros_llamada_actual!=sim->adicional1){
			sprintf(err,"****Error semantico en lin %d: Numero incorrecto de parametros en llamada a funcion.",fila);
			yyerror(err);
		}
		en_explist = 0;
		/***es funcion**//
		$$.tipo = sim->tipo;
		$$.es_direccion = 0;
		gc_idf_llamada_funcion(yyout,$1.lexema,num_parametros_llamada_actual);
		fprintf(yyout, ";R88:\t<exp> ::= <identificador> ( <lista_expresiones> )\n");
   }
   ;
idf_llamada_funcion: TOK_IDENTIFICADOR
				  {
				  	sim = buscar($1.lexema);

						if(sim == NULL){
							sprintf(err,"****Error semantico en lin %d: Acceso a variable no declarada (%s).",fila, $1.lexema);
							yyerror(err);
						}
						if(sim->categoria != FUNCION){
							sprintf(err,"****Error semantico en lin %d: Identificador de no es de categoria Funcion ",fila);
							yyerror(err);
						}
						if(en_explist==1){
							sprintf(err,"****Error semantico en lin %d: No esta permitido el uso de llamadas a funciones como parametros de otras funciones. ",fila);
							yyerror(err);
						}
						num_parametros_llamada_actual = 0;
						/*** es funcion **/
						en_explist = 1;
						strcpy($$.lexema,$1.lexema);
				  }
				  ;
lista_expresiones: exp resto_lista_expresiones
				 {
					num_parametros_llamada_actual++;
					fprintf(yyout, ";R89:\t<lista_expresiones> ::= <exp> <resto_lista_expresiones>\n");
				 }
				 |
				 {
					fprintf(yyout, ";R90:\t<lista_expresiones> ::=\n");
				 }
				 ;

resto_lista_expresiones: TOK_COMA exp resto_lista_expresiones
					   {
							num_parametros_llamada_actual++;
							fprintf(yyout, ";R91:\t<resto_lista_expresiones> ::= , <exp> <resto_lista_expresiones>\n");
					   }
					   |
					   {
							fprintf(yyout, ";R92:\t<resto_lista_expresiones> ::=\n");
					   }
					   ;

comparacion: exp TOK_IGUAL exp
		   {
		   		if($1.tipo != INT || $3.tipo != INT){
					sprintf(err,"****Error semantico en lin %d: Compracion con operandos boolean.",fila);
					yyerror(err);
				}
				$$.tipo = BOOLEAN;
				$$.es_direccion = 0;
				etiqueta++;
				gc_comp_igual_enteros(yyout,$1.es_direccion, $3.es_direccion,etiqueta);

				fprintf(yyout, ";R93:\t<comparacion> ::= <exp> == <exp>\n");
		   }
		   | exp TOK_DISTINTO exp
		   {
				if($1.tipo != INT || $3.tipo != INT){
					sprintf(err,"****Error semantico en lin %d: Compracion con operandos boolean.",fila);
					yyerror(err);
				}
				$$.tipo = BOOLEAN;
				$$.es_direccion = 0;
				etiqueta++;
				gc_comp_distinto_enteros(yyout,$1.es_direccion, $3.es_direccion,etiqueta);

				fprintf(yyout, ";R94:\t<comparacion> ::= <exp> != <exp>\n");
		   }
		   | exp TOK_MENORIGUAL exp
		   {
		   		if($1.tipo != INT || $3.tipo != INT){
					sprintf(err,"****Error semantico en lin %d: Compracion con operandos boolean.",fila);
					yyerror(err);
				}
				$$.tipo = BOOLEAN;
				$$.es_direccion = 0;
				etiqueta++;
				gc_comp_menorigual_enteros(yyout,$1.es_direccion, $3.es_direccion,etiqueta);

				fprintf(yyout, ";R95:\t<comparacion> ::= <exp> <= <exp>\n");
		   }
		   | exp TOK_MAYORIGUAL exp
		   {
		   		if($1.tipo != INT || $3.tipo != INT){
					sprintf(err,"****Error semantico en lin %d: Compracion con operandos boolean.",fila);
					yyerror(err);
				}
				$$.tipo = BOOLEAN;
				$$.es_direccion = 0;
				etiqueta++;
				gc_comp_mayorigual_enteros(yyout,$1.es_direccion, $3.es_direccion,etiqueta);

				fprintf(yyout, ";R96:\t<comparacion> ::= <exp> >= <exp>\n");
		   }
		   | exp TOK_MENOR exp
		   {
				if($1.tipo != INT || $3.tipo != INT){
					sprintf(err,"****Error semantico en lin %d: Compracion con operandos boolean.",fila);
					yyerror(err);
				}
				$$.tipo = BOOLEAN;
				$$.es_direccion = 0;
				etiqueta++;
				gc_comp_menor_enteros(yyout, $1.es_direccion, $3.es_direccion,etiqueta);

				fprintf(yyout, ";R97:\t<comparacion> ::= <exp> < <exp>\n");
		   }
		   | exp TOK_MAYOR exp
		   {
				if($1.tipo != INT || $3.tipo != INT){
					sprintf(err,"****Error semantico en lin %d: Compracion con operandos boolean.",fila);
					yyerror(err);
				}
				$$.tipo = BOOLEAN;
				$$.es_direccion = 0;
				etiqueta++;
				gc_comp_mayor_enteros(yyout,$1.es_direccion, $3.es_direccion,etiqueta);

				fprintf(yyout, ";R98:\t<comparacion> ::= <exp> > <exp>\n");
		   }
		   ;

constante: constante_logica
		 {
			$$.tipo = $1.tipo;
			$$.es_direccion = $1.es_direccion;
			fprintf(yyout, ";R99:\t<constante> ::= <constante_logica>\n");
		 }
		 | constante_entera
		 {
			$$.tipo = $1.tipo;
			$$.es_direccion = $1.es_direccion;

			fprintf(yyout, ";R100:\t<constante> ::= <constante_entera>\n");
		 }
		 ;

constante_logica: TOK_TRUE
				{
					$$.tipo = BOOLEAN;
					$$.es_direccion = 0;

					gc_constante(yyout,fila,1);

					fprintf(yyout, ";R102:\t<constante_logica> ::= true\n");
				}
				| TOK_FALSE
				{
					$$.tipo = BOOLEAN;
					$$.es_direccion = 0;

					gc_constante(yyout,fila,0);

					fprintf(yyout, ";R103:\t<constante_logica> ::= false\n");
				}
				;

constante_entera: TOK_CONSTANTE_ENTERA
				{
					$$.tipo = INT;
					$$.es_direccion = 0;

					gc_constante(yyout,fila,$1.valor_entero);

					fprintf(yyout, ";R104:\t<constante_entera> ::= TOK_CONSTANTE_ENTERA\n");
				}
				;
/*Identificadores de variables globales & locales*/
identificador: TOK_IDENTIFICADOR
			{
			 sim = buscar($1.lexema);
			 if(sim!=NULL){
				 sprintf(err,"****Error semantico en lin %d: Declaracion duplicada.",fila);
				 yyerror(err);
			 }
			 if(local==NULL){
					insertar_simbolo(global,$1.lexema,VARIABLE,tipo_actual,clase_actual,tamanio_vector_actual,0);
			}else{
				if(clase_actual!=ESCALAR){
					sprintf(err,"****Error semantico en lin %d: Variable local de tipo no escalar.",fila);
					yyerror(err);
				}
				insertar_simbolo(local,$1.lexema,categoria_actual,tipo_actual,clase_actual,tamanio_vector_actual,pos_variable_local_actual);
				pos_variable_local_actual++;
				num_variables_locales_actual++;
			}
			fprintf(yyout, ";R108:\t<identificador> ::= TOK_IDENTIFICADOR\n");
		 }
		 ;
/*Identificadores de parametros y Funciones*/
idpf: TOK_IDENTIFICADOR
	{
		sim = buscar($1.lexema);

		if(sim!=NULL){
			sprintf(err,"****Error semantico en lin %d: Declaracion duplicada.",fila);
			yyerror(err);
		}

		insertar_simbolo(local,$1.lexema,categoria_actual,tipo_actual,clase_actual,tamanio_vector_actual,pos_parametro_actual);
		pos_parametro_actual++;
		num_parametros_actual++;
	}
	;
%%

INFO_SIMBOLO* buscar(const char *lexema) {
	INFO_SIMBOLO* inf = NULL;
	if(local==NULL){
		inf=buscar_simbolo(local,lexema);
	}else{
		inf=buscar_simbolo(global,lexema);
	}
	return inf;
}

int yyerror (char* s){
	if (error_morfo == 0){
		column-=yyleng;
		fprintf(stderr,"****Error sintactico en [lin %d, col %d]\n", fila, column);
	}
	fprintf(stderr,"%s\n",s);
	return 1;
}
