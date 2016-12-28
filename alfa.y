
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include "alfa.h"
#include "generacion_codigo.h"
#define HASHSIZE 101

extern int column,fila,error_morfo;
extern FILE *yyin, *yyout;
extern char *yytext;
extern int yylex();
extern int yyleng;

int yyerror(char* s);

INFO_SIMBOLO* sim = NULL,*simF = NULL;
TABLA_HASH* global = NULL, *local = NULL;
char err[200];
char fnName[100];

int etiqueta = 0;
int error_sem = 0;
int categoria_actual,tipo_actual;
int clase_actual,tamanio_vector_actual;
int pos_variable_local_actual = 1;
int num_variables_locales_actual = 0;
int pos_parametro_actual = 0;
int num_parametros_actual = 0;
int num_parametros_llamada_actual = 0;
int en_explist = 0;
int fn_return = 0;
int en_funcion = 0;
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
%token <atributos> TOK_ERROR

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
%type <atributos> idf_llamada_funcion
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
				fprintf(stderr, ";R1:\t<programa> ::= main { <declaraciones> <funciones> <sentencias> }\n");
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
				fprintf(stderr, ";R2:\t<declaraciones> ::= <declaracion>\n");
			 }
			 | declaracion declaraciones
			 {
				fprintf(stderr, ";R3:\t<declaraciones> ::= <declaracion> <declaraciones>\n");
			 }
			 ;

declaracion: clase identificadores TOK_PUNTOYCOMA
		   {
				fprintf(stderr, ";R4:\t<declaracion> ::= <clase> <identificadores> ;\n");
		   }
		   ;

clase: clase_escalar
	 {
	  clase_actual = ESCALAR;
		fprintf(stderr, ";R5:\t<clase> ::= <clase_escalar>\n");
	 }
	 | clase_vector
	 {
	  clase_actual=VECTOR;
		fprintf(stderr, ";R7:\t<clase> ::= <clase_vector>\n");
	 }
	 ;

clase_escalar: tipo
			 {
				fprintf(stderr, ";R9:\t<clase_escalar> ::= <tipo>\n");
			 }
			 ;
tipo: TOK_INT
	{
		tipo_actual=INT;
		fprintf(stderr, ";R10:\t<tipo> ::= int\n");
	}
	| TOK_BOOLEAN
	{
		tipo_actual=BOOLEAN;
		fprintf(stderr, ";R11:\t<tipo> ::= <boolean>\n");
	}
	;

clase_vector: TOK_ARRAY tipo TOK_CORCHETEIZQUIERDO TOK_CONSTANTE_ENTERA TOK_CORCHETEDERECHO
			{
				tamanio_vector_actual = $4.valor_entero;
				if ((tamanio_vector_actual < 1 ) ||
						(tamanio_vector_actual > MAX_TAMANIO_VECTOR))
				{
					sprintf(err,"****Error semantico en lin %d: El tamanyo del vector %d excede los limites permitidos (1,64).",fila,$4.valor_entero);
					error_sem = 1;
					return(yyerror(err));
				}
				fprintf(stderr, ";R15:\t<clase_vector> ::= array <tipo> [ <constante_entera> ]\n");
			}
			;

identificadores: identificador
			   {
					fprintf(stderr, ";R18:\t<identificadores> ::= <identificador>\n");
			   }
			   | identificador TOK_COMA identificadores
			   {
					fprintf(stderr, ";R19:\t<identificadores> ::= <identificador> , <identificadores>\n");
			   }
			   ;

funciones: funcion funciones
		 {
			fprintf(stderr, ";R20:\t<funciones> ::= <funcion> <funciones>\n");
		 }
		 |
		 {
			fprintf(stderr, ";R21:\t<funciones> ::=\n");
		 }
		 ;

funcion: fn_declaration sentencias TOK_LLAVEDERECHA
	   {
			liberarAmbitoLocal();
			sim = buscar($1.lexema);
			if(sim==NULL){
				sprintf(err,"****Error semantico en lin %d: Acceso a variable no declarada (%s).",fila, $1.lexema);
				error_sem = 1;
				return(yyerror(err));
			}
			sim->adicional1 = num_parametros_actual;
			sim->adicional2 = num_variables_locales_actual;
			if(fn_return == 0){
				sprintf(err,"****Error semantico en lin %d:	Funcion <%s> sin sentencia de retorno.",fila,$1.lexema);
				error_sem = 1;
				return(yyerror(err));
			}
			fprintf(stderr, ";R22:\t<funcion> ::= function <tipo> <identificador> ( <parametros_funcion> ) { <declaraciones_funcion> <sentencias> }\n");
	   }
	   ;
fn_name : TOK_FUNCTION tipo TOK_IDENTIFICADOR
		{
			sim = buscar($3.lexema);

			if(sim!=NULL){
				sprintf(err,"****Error semantico en lin %d: Declaracion duplicada (%s).",fila,$1.lexema);
				error_sem = 1;
				return(yyerror(err));
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
			strcpy(fnName, $$.lexema);
		}
		;
fn_declaration : fn_name TOK_PARENTESISIZQUIERDO parametros_funcion TOK_PARENTESISDERECHO TOK_LLAVEIZQUIERDA declaraciones_funcion
				{
					sim = buscar($1.lexema);
					if(sim==NULL){
						sprintf(err,"****Error semantico en lin %d: Acceso a variable no declarada (%s).",fila, $1.lexema);
						error_sem = 1;
						return(yyerror(err));
					}
					sim->adicional1 = num_parametros_actual;
					sim->adicional2 = num_variables_locales_actual;
					strcpy($$.lexema,$1.lexema);
					gc_fn_declaration(yyout,$1.lexema, num_variables_locales_actual);
				}
				;
parametros_funcion: parametro_funcion resto_parametros_funcion
				  {
					fprintf(stderr, ";R23:\t<parametros_funcion> ::= <parametro_funcion> <resto_parametros_funcion>\n");
				  }
				  |
				  {
					fprintf(stderr, ";R24:\t<parametros_funcion> ::=\n");
				  }
				  ;

resto_parametros_funcion: TOK_PUNTOYCOMA parametro_funcion resto_parametros_funcion
						{
							fprintf(stderr, ";R25:\t<resto_parametros_funcion> ::= ; <parametro_funcion> <resto_parametros_funcion>\n");
						}
						|
						{
							fprintf(stderr, ";R26:\tt<resto_parametros_funcion> ::=\n");
						}
						;

parametro_funcion: tipo idpf
				 {
					fprintf(stderr, ";R27:\t<parametro_funcion> ::= <tipo> <identificador>\n");
				 }
				 ;

declaraciones_funcion: declaraciones
					 {
						fprintf(stderr, ";R28:\t<declaraciones_funcion> ::= <declaraciones>\n");
					 }
					 |
					 {
						fprintf(stderr, ";R29:\t<declaraciones_funcion> ::=\n");
					 }
					 ;

sentencias: sentencia
		  {
			fprintf(stderr, ";R30:\t<sentencias> ::= <sentencia>\n");
		  }
		  | sentencia sentencias
		  {
			fprintf(stderr, ";R31:\t<sentencias> ::= <sentencia> <sentencias>\n");
		  }
		  ;

sentencia: sentencia_simple TOK_PUNTOYCOMA
		 {
			fprintf(stderr, ";R32:\t<sentencia> ::= <sentencia_simple> ;\n");
		 }
		 | bloque
		 {
			fprintf(stderr, ";R33:\t<sentencia> ::= <bloque>\n");
		 }
		 ;

sentencia_simple: asignacion
				{
					fprintf(stderr, ";R34:\t<sentencia_simple> ::= <asignacion>\n");
				}
				| lectura
				{
					fprintf(stderr, ";R35:\t<sentencia_simple> ::= <lectura>\n");
				}
				| escritura
				{
					fprintf(stderr, ";R36:\t<sentencia_simple> ::= <escritura>\n");
				}
				| retorno_funcion
				{
					fprintf(stderr, ";R38:\t<sentencia_simple> ::= <retorno_funcion>\n");
				}
				;

bloque: condicional
	  {
		fprintf(stderr, ";R40:\t<bloque> ::= <condicional>\n");
	  }
	  | bucle
	  {
		fprintf(stderr, ";R41:\t<bloque> ::= <bucle>\n");
	  }
	  ;

asignacion: TOK_IDENTIFICADOR TOK_ASIGNACION exp
		  {
			sim = buscar($1.lexema);

			if(sim == NULL){
				sprintf(err,"****Error semantico en lin %d: Acceso a variable no declarada (%s).",fila, $1.lexema);
				error_sem = 1;
				return(yyerror(err));
			}

			if(sim->categoria == FUNCION){
				sprintf(err,"****Error semantico en lin %d: Identificador de categoria Funcion ",fila);
				error_sem = 1;
				return(yyerror(err));
			}

			if(sim->clase != ESCALAR){
				sprintf(err,"****Error semantico en lin %d: Variable local de tipo no escalar.",fila);
				error_sem = 1;
				return(yyerror(err));
			}

			 if(sim->tipo != $3.tipo){
				sprintf(err,"****Error semantico en lin %d: Asignacion incompatible.",fila);
				error_sem = 1;
				return(yyerror(err));
			}

			/*Si la tabla local esta abierta se estara insertando en una funcion*/
			if(local==NULL){
				gc_asignacion_iden(yyout,$3.es_direccion,$1.lexema);
			}else{
				simF=buscar(fnName);
				gc_asignacion_funcion(yyout,$3.es_direccion,sim->categoria,sim->adicional2,simF->adicional1);
			}
			fprintf(stderr, ";R43:\t<asignacion> ::= <identificador> = <exp>\n");
		  }
		  | elemento_vector TOK_ASIGNACION exp
		  {
			if($1.tipo != $3.tipo){
				sprintf(err,"****Error semantico en lin %d: Asignacion incompatible.",fila);
				error_sem = 1;
				return(yyerror(err));
			}
			gc_asignacion_vector(yyout,$3.es_direccion);
			fprintf(stderr, ";R44:\t<asignacion> ::= <elemento_vector> = <exp>\n");
		  }
		  ;

elemento_vector: TOK_IDENTIFICADOR TOK_CORCHETEIZQUIERDO exp TOK_CORCHETEDERECHO
			   {
					sim = buscar($1.lexema);

		 			if(sim == NULL){
		 				sprintf(err,"****Error semantico en lin %d: Acceso a variable no declarada (%s).",fila, $1.lexema);
						error_sem = 1;
						return(yyerror(err));
		 			}
					if(sim->clase != VECTOR){
						sprintf(err,"****Error semantico en lin %d:Intento de indexacion de una variable que no es de tipo vector.",fila);
						error_sem = 1;
						return(yyerror(err));
					}
					if($3.tipo != INT){
						sprintf(err,"**** Error semantico en lin %d: El indice en una operacion de indexacion tiene que ser de tipo entero.", fila);
						error_sem = 1;
						return(yyerror(err));
					}
					if($3.es_direccion==0){
						if($3.valor_entero < 0 || $3.valor_entero > (sim->adicional1 - 1)){
							sprintf(err,"**** Error semantico en lin %d: El indice indicado del vector <%s> excede los limites declarados (1,%d).", fila, $1.lexema,sim->adicional1);
							error_sem = 1;
							return(yyerror(err));
						}
					}
					$$.tipo = sim->tipo;
					$$.es_direccion = 1;
					gc_asignacion_elemento_vector(yyout,$3.es_direccion,$1.lexema,sim->adicional1);
					fprintf(stderr, ";R48:\t<elemento_vector> ::= <identificador> [ <exp> ]\n");
			   }
			   ;

condicional: if_exp sentencias TOK_LLAVEDERECHA
			 		{
						gc_condicional_if(yyout,$1.etiqueta);
			 		}
			 		| if_exp_sentencias TOK_ELSE TOK_LLAVEIZQUIERDA sentencias TOK_LLAVEDERECHA
			 		{
						gc_condicional_else(yyout,$1.etiqueta);
			 		}
			 		;
if_exp_sentencias: if_exp sentencias TOK_LLAVEDERECHA
							{
								$$.etiqueta = $1.etiqueta;
								gc_if_exp_sentencias(yyout,$1.etiqueta);
							}
							;
if_exp: TOK_IF TOK_PARENTESISIZQUIERDO exp TOK_PARENTESISDERECHO TOK_LLAVEIZQUIERDA
		   {
				if($3.tipo != BOOLEAN){
					sprintf(err,"****Error semantico en lin %d: Condicional con condicion de tipo int.",fila);
					error_sem = 1;
					return(yyerror(err));
				}
				etiqueta++;
				$$.etiqueta = etiqueta;
				gc_if_exp(yyout,$3.es_direccion,$$.etiqueta);
				fprintf(stderr, ";R50:\t<condicional> ::= if( <exp> ){ <sentencias> }\n");
		   }
		   ;
while: TOK_WHILE TOK_PARENTESISIZQUIERDO
		{
			etiqueta++;
			$$.etiqueta = etiqueta;
			gc_while(yyout,etiqueta);
		}
		;
while_exp: while exp TOK_PARENTESISDERECHO TOK_LLAVEIZQUIERDA
				{
					if($2.tipo != BOOLEAN){
						sprintf(err,"****Error semantico en lin %d: Condicional con condicion de tipo int.",fila);
						error_sem = 1;
						return(yyerror(err));
					}
					$$.etiqueta = $1.etiqueta;
					gc_while_exp(yyout,$2.es_direccion,$1.etiqueta);
				}
				;
bucle: while_exp sentencias TOK_LLAVEDERECHA
	 {
		gc_bucle(yyout,$1.etiqueta);
		fprintf(stderr, ";R52:\t<bucle> ::= while ( <exp> ){ <sentencias> }\n");
	 }
	 ;

lectura: TOK_SCANF TOK_IDENTIFICADOR
	   {
			sim = buscar($2.lexema);
			if(sim==NULL){
				sprintf(err,"****Error semantico en lin %d: Acceso a variable no declarada (%s).",fila, $1.lexema);
				error_sem = 1;
				return(yyerror(err));
			}
			if(sim->categoria==FUNCION){
					sprintf(err,"****Error semantico en lin %d: Identificador de categoria Funcion.",fila);
					error_sem = 1;
					return(yyerror(err));
				}
			if(sim->clase==VECTOR){
					sprintf(err,"****Error semantico en lin %d: Variable local de tipo no escalar.",fila);
					error_sem = 1;
					return(yyerror(err));
				}
			if(sim->adicional2==0){ /*Variable Global*/
				gc_lectura(yyout,$2.lexema,sim->tipo);
			}else{ /*Variable Local o PARAMETRO*/
				if(sim->categoria==PARAMETRO){
					simF=buscar(fnName);
					gc_lectura_fn_para(yyout,sim->tipo,sim->adicional2,simF->adicional1);
				}
				else{
					gc_lectura_fn_var(yyout,sim->tipo,sim->adicional2);
				}
			}
			fprintf(stderr, ";R54:\t<lectura> ::= scanf <identificador>\n");
	   }
	   ;

escritura: TOK_PRINTF exp
		 {
			gc_escritura(yyout,$2.es_direccion,$2.tipo);
			fprintf(stderr, ";R56:\t<escritura> ::= printf <exp>\n");
		 }
		 ;

retorno_funcion: TOK_RETURN exp
			   {
					simF=buscar(fnName);
					if(simF->tipo != $2.tipo){
						sprintf(err,"**** Error semantico en lin %d:Asignacion incompatible",fila);
						error_sem = 1;
						return(yyerror(err));
					}
					if($2.es_direccion != 1 && $2.es_direccion != 0){
						sprintf(err,"**** Error semantico en lin %d:Asignacion incompatible",fila);
						error_sem = 1;
						return(yyerror(err));
					}

					fn_return++;
					gc_retorno_funcion(yyout,$2.es_direccion);
					fprintf(stderr, ";R61:\t<retorno_funcion> ::= return <exp>\n");
			   }
			   ;

exp: exp TOK_MAS exp
   {
		if($1.tipo != INT || $3.tipo != INT){
			sprintf(err,"****Error semantico en lin %d: Operacion aritmetica con operandos boolean.",fila);
			error_sem = 1;
			return(yyerror(err));
		}
		$$.tipo = INT;
		$$.es_direccion = 0;
		gc_suma_enteros(yyout, $1.es_direccion, $3.es_direccion);

		fprintf(stderr, ";R72:\t<exp> ::= <exp> + <exp>\n");
   }
   | exp TOK_MENOS exp
   {
   		if($1.tipo != INT || $3.tipo != INT){
			sprintf(err,"****Error semantico en lin %d: Operacion aritmetica con operandos boolean.",fila);
			error_sem = 1;
			return(yyerror(err));
		}
		$$.tipo = INT;
		$$.es_direccion = 0;
		gc_resta_enteros(yyout, $1.es_direccion, $3.es_direccion);

		fprintf(stderr, ";R73:\t<exp> ::= <exp> - <exp>\n");
   }
   | exp TOK_DIVISION exp
   {
   		if($1.tipo != INT || $3.tipo != INT){
			sprintf(err,"****Error semantico en lin %d: Operacion aritmetica con operandos boolean.",fila);
			error_sem = 1;
			return(yyerror(err));
		}
		$$.tipo = INT;
		$$.es_direccion = 0;
		gc_div_enteros(yyout, $1.es_direccion, $3.es_direccion);

		fprintf(stderr, ";R74:\t<exp> ::= <exp> / <exp>\n");
   }
   | exp TOK_ASTERISCO exp
   {
   		if($1.tipo != INT || $3.tipo != INT){
			sprintf(err,"****Error semantico en lin %d: Operacion aritmetica con operandos boolean.",fila);
			error_sem = 1;
			return(yyerror(err));
		}
		$$.tipo = INT;
		$$.es_direccion = 0;
		gc_mult_enteros(yyout, $1.es_direccion, $3.es_direccion);

		fprintf(stderr, ";R75:\t<exp> ::= <exp> * <exp>\n");
   }
   | TOK_MENOS exp %prec SIG
   {
   		if($2.tipo != INT){
			sprintf(err,"****Error semantico en lin %d: Operacion aritmetica con operandos boolean.",fila);
			error_sem = 1;
			return(yyerror(err));
		}
		$$.tipo = INT;
		$$.es_direccion = 0;
		gc_neg_enteros(yyout, $2.es_direccion);

		fprintf(stderr, ";R76:\t<exp> ::= - <exp>\n");
   }
   | exp TOK_AND exp
   {
		if($1.tipo != BOOLEAN || $3.tipo != BOOLEAN){
			sprintf(err,"****Error semantico en lin %d: Operacion logica con operandos int.",fila);
			error_sem = 1;
			return(yyerror(err));
		}
		$$.tipo = BOOLEAN;
		$$.es_direccion = 0;
		gc_and_enteros(yyout, $1.es_direccion, $3.es_direccion);

		fprintf(stderr, ";R77:\t<exp> ::= <exp> && <exp>\n");
   }
   | exp TOK_OR exp
   {
   		if($1.tipo != BOOLEAN || $3.tipo != BOOLEAN){
			sprintf(err,"****Error semantico en lin %d: Operacion logica con operandos int.",fila);
			error_sem = 1;
			return(yyerror(err));
		}
		$$.tipo = BOOLEAN;
		$$.es_direccion = 0;
		gc_or_enteros(yyout, $1.es_direccion, $3.es_direccion);

		fprintf(stderr, ";R78:\t<exp> ::= <exp> || <exp>\n");
   }
   | TOK_NOT exp
   {
   		if($2.tipo != BOOLEAN){
			sprintf(err,"****Error semantico en lin %d: Operacion logica con operandos int.",fila);
			error_sem = 1;
			return(yyerror(err));
		}
		$$.tipo = BOOLEAN;
		$$.es_direccion = 0;
		etiqueta++;
		$$.etiqueta = etiqueta;
		gc_not_enteros(yyout, $2.es_direccion,etiqueta);

		fprintf(stderr, ";R79:\t<exp> ::= ! <exp>\n");
   }
   | TOK_IDENTIFICADOR
   {
		sim = buscar($1.lexema);

		if(sim == NULL){
			sprintf(err,"****Error semantico en lin %d: Acceso a variable no declarada (%s).",fila, $1.lexema);
			error_sem = 1;
			return(yyerror(err));
		}

		if(sim->clase != ESCALAR){
			sprintf(err,"****Error semantico en lin %d: Variable local de tipo no escalar.",fila);
			error_sem = 1;
			return(yyerror(err));
		}

		if(sim->categoria == FUNCION){
			sprintf(err,"****Error semantico en lin %d: Identificador de categoria Funcion",fila);
			error_sem = 1;
			return(yyerror(err));
		}

		$$.tipo = sim->tipo;
		$$.es_direccion = 1;
		if(sim->categoria == PARAMETRO){
			gc_exp_iden_param(yyout,num_parametros_actual,sim->adicional2);
		}
		if(sim->categoria == VARIABLE){
			if(sim->adicional2 == 0){
				if(en_funcion == 1){
					gc_contenido(yyout,$1.lexema);
				}else{
					gc_direccion(yyout,$1.lexema);
				}
			}else{
				gc_exp_iden_var_local(yyout,sim->adicional2);
			}
		}
		fprintf(stderr, ";R80:\t<exp> ::= <identificador>\n");
   }
   | constante
   {
		$$.tipo = $1.tipo;
		$$.es_direccion = $1.es_direccion;

		fprintf(stderr, ";R81:\t<exp> ::= <constante>\n");
   }
   | TOK_PARENTESISIZQUIERDO exp TOK_PARENTESISDERECHO
   {
		$$.tipo = $2.tipo;
		$$.es_direccion = $2.es_direccion;

		fprintf(stderr, ";R82:\t<exp> ::= ( <exp> )\n");
   }
   | TOK_PARENTESISIZQUIERDO comparacion TOK_PARENTESISDERECHO
   {
		$$.tipo = $2.tipo;
		$$.es_direccion = $2.es_direccion;

		fprintf(stderr, ";R83:\t<exp> ::= ( <comparacion> )\n");
   }
   | elemento_vector
   {
		$$.tipo = $1.tipo;
		$$.es_direccion = $1.es_direccion;

		fprintf(stderr, ";R85:\t<exp> ::= <elemento_vector>\n");
   }
   | idf_llamada_funcion TOK_PARENTESISIZQUIERDO lista_expresiones TOK_PARENTESISDERECHO
   {
		sim = buscar($1.lexema);

		if(sim == NULL){
			sprintf(err,"****Error semantico en lin %d: Acceso a variable no declarada (%s).",fila, $1.lexema);
			error_sem = 1;
			return(yyerror(err));
		}
		if(num_parametros_llamada_actual!=sim->adicional1){
			sprintf(err,"****Error semantico en lin %d: Numero incorrecto de parametros en llamada a funcion.",fila);
			error_sem = 1;
			return(yyerror(err));
		}
		en_explist = 0;
		/***es funcion**/
		en_funcion = 0;
		$$.tipo = sim->tipo;
		$$.es_direccion = 0;
		gc_idf_llamada_funcion(yyout,$1.lexema,num_parametros_llamada_actual);
		fprintf(stderr, ";R88:\t<exp> ::= <identificador> ( <lista_expresiones> )\n");
   }
   ;
idf_llamada_funcion: TOK_IDENTIFICADOR
				  {
				  	sim = buscar($1.lexema);

						if(sim == NULL){
							sprintf(err,"****Error semantico en lin %d: Acceso a variable no declarada (%s).",fila, $1.lexema);
							error_sem = 1;
							return(yyerror(err));
						}
						if(sim->categoria != FUNCION){
							sprintf(err,"****Error semantico en lin %d: Identificador de no es de categoria Funcion ",fila);
							error_sem = 1;
							return(yyerror(err));
						}
						if(en_explist==1){
							sprintf(err,"****Error semantico en lin %d: No esta permitido el uso de llamadas a funciones como parametros de otras funciones. ",fila);
							error_sem = 1;
							return(yyerror(err));
						}
						num_parametros_llamada_actual = 0;
						en_funcion = 1;
						/*** es funcion **/
						en_explist = 1;
						strcpy($$.lexema,$1.lexema);
				  }
				  ;
lista_expresiones: exp resto_lista_expresiones
				 {
					num_parametros_llamada_actual++;
					fprintf(stderr, ";R89:\t<lista_expresiones> ::= <exp> <resto_lista_expresiones>\n");
				 }
				 |
				 {
					fprintf(stderr, ";R90:\t<lista_expresiones> ::=\n");
				 }
				 ;

resto_lista_expresiones: TOK_COMA exp resto_lista_expresiones
					   {
							num_parametros_llamada_actual++;
							fprintf(stderr, ";R91:\t<resto_lista_expresiones> ::= , <exp> <resto_lista_expresiones>\n");
					   }
					   |
					   {
							fprintf(stderr, ";R92:\t<resto_lista_expresiones> ::=\n");
					   }
					   ;

comparacion: exp TOK_IGUAL exp
		   {
		   	if($1.tipo != INT || $3.tipo != INT){
					sprintf(err,"****Error semantico en lin %d: Compracion con operandos boolean.",fila);
					error_sem = 1;
					return(yyerror(err));
				}
				$$.tipo = BOOLEAN;
				$$.es_direccion = 0;
				etiqueta++;
				$$.etiqueta = etiqueta;
				gc_comp_igual_enteros(yyout,$1.es_direccion, $3.es_direccion,etiqueta);

				fprintf(stderr, ";R93:\t<comparacion> ::= <exp> == <exp>\n");
		   }
		   | exp TOK_DISTINTO exp
		   {
				if($1.tipo != INT || $3.tipo != INT){
					sprintf(err,"****Error semantico en lin %d: Compracion con operandos boolean.",fila);
					error_sem = 1;
					return(yyerror(err));
				}
				$$.tipo = BOOLEAN;
				$$.es_direccion = 0;
				etiqueta++;
				$$.etiqueta = etiqueta;
				gc_comp_distinto_enteros(yyout,$1.es_direccion, $3.es_direccion,etiqueta);

				fprintf(stderr, ";R94:\t<comparacion> ::= <exp> != <exp>\n");
		   }
		   | exp TOK_MENORIGUAL exp
		   {
		   	if($1.tipo != INT || $3.tipo != INT){
					sprintf(err,"****Error semantico en lin %d: Compracion con operandos boolean.",fila);
					error_sem = 1;
					return(yyerror(err));
				}
				$$.tipo = BOOLEAN;
				$$.es_direccion = 0;
				etiqueta++;
				$$.etiqueta = etiqueta;
				gc_comp_menorigual_enteros(yyout,$1.es_direccion, $3.es_direccion,etiqueta);

				fprintf(stderr, ";R95:\t<comparacion> ::= <exp> <= <exp>\n");
		   }
		   | exp TOK_MAYORIGUAL exp
		   {
		   	if($1.tipo != INT || $3.tipo != INT){
					sprintf(err,"****Error semantico en lin %d: Compracion con operandos boolean.",fila);
					error_sem = 1;
					return(yyerror(err));
				}
				$$.tipo = BOOLEAN;
				$$.es_direccion = 0;
				etiqueta++;
				$$.etiqueta = etiqueta;
				gc_comp_mayorigual_enteros(yyout,$1.es_direccion, $3.es_direccion,etiqueta);

				fprintf(stderr, ";R96:\t<comparacion> ::= <exp> >= <exp>\n");
		   }
		   | exp TOK_MENOR exp
		   {
				if($1.tipo != INT || $3.tipo != INT){
					sprintf(err,"****Error semantico en lin %d: Compracion con operandos boolean.",fila);
					error_sem = 1;
					return(yyerror(err));
				}
				$$.tipo = BOOLEAN;
				$$.es_direccion = 0;
				etiqueta++;
				$$.etiqueta = etiqueta;
				gc_comp_menor_enteros(yyout, $1.es_direccion, $3.es_direccion,etiqueta);

				fprintf(stderr, ";R97:\t<comparacion> ::= <exp> < <exp>\n");
		   }
		   | exp TOK_MAYOR exp
		   {
				if($1.tipo != INT || $3.tipo != INT){
					sprintf(err,"****Error semantico en lin %d: Compracion con operandos boolean.",fila);
					error_sem = 1;
					return(yyerror(err));
				}
				$$.tipo = BOOLEAN;
				$$.es_direccion = 0;
				etiqueta++;
				$$.etiqueta = etiqueta;
				gc_comp_mayor_enteros(yyout,$1.es_direccion, $3.es_direccion,etiqueta);

				fprintf(stderr, ";R98:\t<comparacion> ::= <exp> > <exp>\n");
		   }
		   ;

constante: constante_logica
		 {
			$$.tipo = $1.tipo;
			$$.es_direccion = $1.es_direccion;
			fprintf(stderr, ";R99:\t<constante> ::= <constante_logica>\n");
		 }
		 | constante_entera
		 {
			$$.tipo = $1.tipo;
			$$.es_direccion = $1.es_direccion;

			fprintf(stderr, ";R100:\t<constante> ::= <constante_entera>\n");
		 }
		 ;

constante_logica: TOK_TRUE
				{
					$$.tipo = BOOLEAN;
					$$.es_direccion = 0;

					gc_constante(yyout,fila,1);

					fprintf(stderr, ";R102:\t<constante_logica> ::= true\n");
				}
				| TOK_FALSE
				{
					$$.tipo = BOOLEAN;
					$$.es_direccion = 0;

					gc_constante(yyout,fila,0);

					fprintf(stderr, ";R103:\t<constante_logica> ::= false\n");
				}
				;

constante_entera: TOK_CONSTANTE_ENTERA
				{
					$$.tipo = INT;
					$$.es_direccion = 0;

					gc_constante(yyout,fila,$1.valor_entero);

					fprintf(stderr, ";R104:\t<constante_entera> ::= TOK_CONSTANTE_ENTERA\n");
				}
				;
/*Identificadores de variables globales & locales*/
identificador: TOK_IDENTIFICADOR
			{
			 sim = buscar($1.lexema);
			 if(sim!=NULL){
				 sprintf(err,"****Error semantico en lin %d: Declaracion duplicada (%s).",fila,$1.lexema);
				 error_sem = 1;
				 return(yyerror(err));
			 }
			 if(local==NULL){
					insertar_simbolo(global,$1.lexema,VARIABLE,tipo_actual,clase_actual,tamanio_vector_actual,0);
			}else{
				if(clase_actual!=ESCALAR){
					sprintf(err,"****Error semantico en lin %d: Variable local de tipo no escalar.",fila);
					error_sem = 1;
					return(yyerror(err));
				}
				insertar_simbolo(local,$1.lexema,VARIABLE,tipo_actual,clase_actual,0,pos_variable_local_actual);
				pos_variable_local_actual++;
				num_variables_locales_actual++;
			}
			fprintf(stderr, ";R108:\t<identificador> ::= TOK_IDENTIFICADOR\n");
		 }
		 ;
/*Identificadores de parametros y Funciones*/
idpf: TOK_IDENTIFICADOR
	{
		sim = buscar($1.lexema);

		if(sim!=NULL){
			sprintf(err,"****Error semantico en lin %d: Declaracion duplicada (%s).",fila,$1.lexema);
			error_sem = 1;
			return(yyerror(err));
		}
		insertar_simbolo(local,$1.lexema,PARAMETRO,tipo_actual,ESCALAR,0,pos_parametro_actual);
		pos_parametro_actual++;
		num_parametros_actual++;
	}
	;
%%

void liberarAmbitoLocal(){
	liberar_tabla(local);
	local=NULL;
}

INFO_SIMBOLO* buscar(const char *lexema) {
	INFO_SIMBOLO* inf = NULL;

	if(local != NULL)
		inf=buscar_simbolo(local,lexema);
	if(inf == NULL)
		inf=buscar_simbolo(global,lexema);

	return inf;
}

int yyerror (char* s){
	if (error_morfo == 0){
		if(error_sem == 1){
			fprintf(stderr,"%s\n",s);
		}else{
			if(column > 1){
				column-=yyleng;
			}
			fprintf(stderr,"****Error sintactico en [lin %d, col %d]\n",fila, column);
		}
	}
	if(local!=NULL){
		liberar_tabla(local);
	}
	if(global!=NULL){
		liberar_tabla(global);
	}
	return -1;
}
