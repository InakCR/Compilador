%{
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "alfa.h"
#include "y.tab.h"
#define IDLEN 101

int column = 1;
int fila = 1;
int error_morfo = 0;
%}

%option noyywrap
%option nounput
%option noinput

COMENTARIOS["//"]
ENTERO[0-9]
LETRA[a-zA-Z]

%%

{COMENTARIOS}{COMENTARIOS}.*	{}
" "					{column++;}
"\t"				{column+=1;}
"\n"				{fila++; column = 1;}
"\r" 				{}
"main" 			{fprintf(stderr,";D:\tmain\n"); column+=yyleng; return TOK_MAIN;}
"int"				{fprintf(stderr,";D:\tint\n"); column+=yyleng; return TOK_INT;}
"boolean"		{fprintf(stderr,";D:\tboolean\n"); column+=yyleng; return TOK_BOOLEAN;}
"array"			{fprintf(stderr,";D:\tarray\n"); column+=yyleng; return TOK_ARRAY;}
"function"	{fprintf(stderr,";D:\tfunction\n"); column+=yyleng; return TOK_FUNCTION;}
"if"     		{fprintf(stderr,";D:\tif\n"); column+=yyleng; return TOK_IF;}
"else" 			{fprintf(stderr,";D:\telse\n"); column+=yyleng; return TOK_ELSE;}
"while" 		{fprintf(stderr,";D:\twhile\n"); column+=yyleng; return TOK_WHILE;}
"scanf" 		{fprintf(stderr,";D:\tscanf\n"); column+=yyleng; return TOK_SCANF;}
"printf" 		{fprintf(stderr,";D:\tprintf\n"); column+=yyleng; return TOK_PRINTF;}
"return"  	{fprintf(stderr,";D:\treturn\n"); column+=yyleng; return TOK_RETURN;}
";" 				{fprintf(stderr,";D:\t;\n"); column+=yyleng; return TOK_PUNTOYCOMA;}
"," 				{fprintf(stderr,";D:\t,\n"); column+=yyleng; return TOK_COMA;}
"(" 				{fprintf(stderr,";D:\t(\n"); column+=yyleng; return TOK_PARENTESISIZQUIERDO;}
"{"					{fprintf(stderr,";D:\t{\n"); column+=yyleng; return TOK_LLAVEIZQUIERDA;}
")" 				{fprintf(stderr,";D:\t)\n"); column+=yyleng; return TOK_PARENTESISDERECHO;}
"}"					{fprintf(stderr,";D:\t}\n"); column+=yyleng; return TOK_LLAVEDERECHA;}
"["       	{fprintf(stderr,";D:\t[\n"); column+=yyleng; return TOK_CORCHETEIZQUIERDO;}
"]"       	{fprintf(stderr,";D:\t]\n"); column+=yyleng; return TOK_CORCHETEDERECHO;}
"="       	{fprintf(stderr,";D:\t=\n"); column+=yyleng; return TOK_ASIGNACION;}
"+" 				{fprintf(stderr,";D:\t+\n"); column+=yyleng; return TOK_MAS;}
"-" 				{fprintf(stderr,";D:\t-\n"); column+=yyleng; return TOK_MENOS;}
"/"       	{fprintf(stderr,";D:\t/\n"); column+=yyleng; return TOK_DIVISION;}
"*" 				{fprintf(stderr,";D:\t*\n"); column+=yyleng; return TOK_ASTERISCO;}
"&&"				{fprintf(stderr,";D:\t&&\n"); column+=yyleng; return TOK_AND;}
"||" 				{fprintf(stderr,";D:\t||\n"); column+=yyleng; return TOK_OR;}
"!" 				{fprintf(stderr,";D:\t!\n"); column+=yyleng; return TOK_NOT;}
"==" 				{fprintf(stderr,";D:\t==\n"); column+=yyleng; return TOK_IGUAL;}
"!=" 				{fprintf(stderr,";D:\t!=\n"); column+=yyleng; return TOK_DISTINTO;}
">=" 				{fprintf(stderr,";D:\t>=\n"); column+=yyleng; return TOK_MAYORIGUAL;}
"<=" 				{fprintf(stderr,";D:\t<=\n"); column+=yyleng; return TOK_MENORIGUAL;}
"<" 				{fprintf(stderr,";D:\t<\n"); column+=yyleng; return TOK_MENOR;}
">" 				{fprintf(stderr,";D:\t>\n"); column+=yyleng; return TOK_MAYOR;}
{ENTERO}+ 	{fprintf(stderr,";D:\t%s\n",yytext); yylval.atributos.valor_entero=atoi(yytext); column+=yyleng; return TOK_CONSTANTE_ENTERA;}
"true" 			{fprintf(stderr,";D:\ttrue\n"); column+=yyleng; return TOK_TRUE;}
"false" 		{fprintf(stderr,";D:\tfalse\n"); column+=yyleng; return TOK_FALSE;}
{LETRA}({LETRA}|{ENTERO})*  {
								if(yyleng<IDLEN){
									strcpy(yylval.atributos.lexema, yytext);
									fprintf(stderr,";D:\t%s\n",yytext); column+=yyleng; return TOK_IDENTIFICADOR;
								}
								fprintf(stderr,"****Error en [lin %d, col %d]: identificador demasiado largo (%s)\n", fila, column, yytext);
								error_morfo = 1;
								return TOK_ERROR;
						}
.						{	error_morfo = 1;
							fprintf(stderr,"***Error en [lin %d, col %d]: simbolo no permitido (%s)\n", fila, column, yytext);
				 			return TOK_ERROR;
						}
%%
