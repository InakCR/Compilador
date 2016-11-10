%{
#include <stdio.h>
#include "y.tab.h"
int column = 0;
int fila = 0;

int error_morfo = 0;

%}

%option noyywrap
%option nounput
%option noinput

COMENTARIOS["//"]
ENTERO[0-9]
LETRA[A-z]

%%

{COMENTARIOS}({LETRA}|{ENTERO})*.+	{}
" "				{column++;}
"\t"			{column+=yyleng;}
"\n"			{fila++; column = 0;}
"main" 		{fprintf(yyout,";D:\tmain\n"); column+=yyleng; return TOK_MAIN;}
"int"			{fprintf(yyout,";D:\tint\n"); column+=yyleng; return TOK_INT;}
"boolean"	{fprintf(yyout,";D:\tboolean\n"); column+=yyleng; return TOK_BOOLEAN;}
"array"		{fprintf(yyout,";D:\tarray\n"); column+=yyleng; return TOK_ARRAY;}
"function"{fprintf(yyout,";D:\tfunction\n"); column+=yyleng; return TOK_FUNCTION;}
"if"     	{fprintf(yyout,";D:\tif\n"); column+=yyleng; return TOK_IF;}
"else" 		{fprintf(yyout,";D:\telse\n"); column+=yyleng; return TOK_ELSE;}
"while" 	{fprintf(yyout,";D:\twhile\n"); column+=yyleng; return TOK_WHILE;}
"scanf" 	{fprintf(yyout,";D:\tscanf\n"); column+=yyleng; return TOK_SCANF;}
"printf" 	{fprintf(yyout,";D:\tprintf\n"); column+=yyleng; return TOK_PRINTF;}
"return"  {fprintf(yyout,";D:\treturn\n"); column+=yyleng; return TOK_RETURN;}
";" 			{fprintf(yyout,";D:\t;\n"); column+=yyleng; return TOK_PUNTOYCOMA;}
"," 			{fprintf(yyout,";D:\t,\n"); column+=yyleng; return TOK_COMA;}
"(" 			{fprintf(yyout,";D:\t(\n"); column+=yyleng; return TOK_PARENTESISIZQUIERDO;}
"{"				{fprintf(yyout,";D:\t{\n"); column+=yyleng; return TOK_LLAVEIZQUIERDA;}
")" 			{fprintf(yyout,";D:\t)\n"); column+=yyleng; return TOK_PARENTESISDERECHO;}
"}"				{fprintf(yyout,";D:\t}\n"); column+=yyleng; return TOK_LLAVEDERECHA;}
"["       {fprintf(yyout,";D:\t[\n"); column+=yyleng; return TOK_CORCHETEIZQUIERDO;}
"]"       {fprintf(yyout,";D:\t]\n"); column+=yyleng; return TOK_CORCHETEDERECHO;}
"="       {fprintf(yyout,";D:\t=\n"); column+=yyleng; return TOK_ASIGNACION;}
"+" 			{fprintf(yyout,";D:\t+\n"); column+=yyleng; return TOK_MAS;}
"-" 			{fprintf(yyout,";D:\t-\n"); column+=yyleng; return TOK_MENOS;}
"/"       {fprintf(yyout,";D:\t/\n"); column+=yyleng; return TOK_DIVISION;}
"*" 			{fprintf(yyout,";D:\t*\n"); column+=yyleng; return TOK_ASTERISCO;}
"&&"			{fprintf(yyout,";D:\t&&\n"); column+=yyleng; return TOK_AND;}
"||" 			{fprintf(yyout,";D:\t||\n"); column+=yyleng; return TOK_OR;}
"!" 			{fprintf(yyout,";D:\t!\n"); column+=yyleng; return TOK_NOT;}
"==" 			{fprintf(yyout,";D:\t==\n"); column+=yyleng; return TOK_IGUAL;}
"!=" 			{fprintf(yyout,";D:\t!=\n"); column+=yyleng; return TOK_DISTINTO;}
">=" 			{fprintf(yyout,";D:\t>=\n"); column+=yyleng; return TOK_MAYORIGUAL;}
"<=" 			{fprintf(yyout,";D:\t<=\n"); column+=yyleng; return TOK_MENORIGUAL;}
"<" 			{fprintf(yyout,";D:\t<\n"); column+=yyleng; return TOK_MENOR;}
">" 			{fprintf(yyout,";D:\t>\n"); column+=yyleng; return TOK_MAYOR;}
{ENTERO}+ {fprintf(yyout,";D:\t%s\n",yytext); column+=yyleng; return TOK_CONSTANTE_ENTERA;}
"true" 		{fprintf(yyout,";D:\ttrue\n"); column+=yyleng; return TOK_TRUE;}
"false" 	{fprintf(yyout,";D:\tfalse\n"); column+=yyleng; return TOK_FALSE;}
{LETRA}({LETRA}|{ENTERO})*  {
								if(yyleng<101){
									fprintf(yyout,";D:\t%s\n",yytext); column+=yyleng; return TOK_IDENTIFICADOR;
								}
								else{
									printf("****Error en [lin %d, col %d]: identificador demasiado largo (%s)\n", fila, column, yytext);
									error_morfo = 1;
									return -1;
								}
				}
.				{	error_morfo = 1;
         	printf("****Error Morfologico en [l: %d c: %d] %s Caracter no permitido\n", fila, column, yytext);
				 	return -1;
				}
%%
