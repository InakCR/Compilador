/**
 *
 * Descripcion:
 *
 * Fichero: generacion_codigo.c
 * Autor: Daniel Cuesta, Iñaki Cadalso
 * Version: 1.0
 * Fecha: 28-09-2016
 *
 */

#include <stdlib.h>
#include <stdio.h>

#include "generacion_codigo.h"

void escribirSegmentos(FILE* f,int op1,int op2){
	escribirData(f);
	escribirBss(f);
	escribirText(f);
	escribirImain(f,op1,op2);
	escribirFmain(f);
}
void escribirData(FILE* f){
 	 fprintf(f,"segment .data\n");
 	 fprintf(f,"	rsuma dw 'La suma es:'\n");
 	 fprintf(f,"	rdiv dw 'La division es:'\n");
 	 fprintf(f,"	rmul dw 'La multiplicacion es:'\n");
 	 fprintf(f,"	error0 dw 'Division por Cero'\n");
 	 fprintf(f,"	rdif dw 'La diferencia es:'\n");
	 fprintf(f,"\n");
 }
void escribirBss(FILE* f){
	fprintf(f,"segment .bss\n");
	fprintf(f,"	op1 resd 1\n");
	fprintf(f,"	op2 resd 1\n");
	fprintf(f,"	pila resd 1\n");
	fprintf(f,"\n");
}
void escribirText(FILE* f){
	fprintf(f,"segment .text\n");
	fprintf(f,"	global main\n");
	fprintf(f,"	extern print_int,print_endofline,print_string\n");
	fprintf(f,"\n");
}
void escribirImain(FILE* f,int op1,int op2){
	fprintf(f,"main:\n");
	fprintf(f," MOV dword [pila], esp\n");
	fprintf(f,"	MOV dword [op1],%d\n", op1);
	fprintf(f,"	MOV dword [op2],%d\n", op2);
	fprintf(f,"	jmp suma\n");
	fprintf(f,"\n");
}
void escribirFmain(FILE* f){
	fprintf(f,"error:\n");
	fprintf(f,"	push dword error0 \n");
	fprintf(f,"	call print_string\n");
	fprintf(f,"	ADD esp,4\n");
	fprintf(f,"	call print_endofline\n");
	fprintf(f,"fin:\n");
	fprintf(f," MOV esp,[pila]\n");
	fprintf(f,"	ret\n");
	fprintf(f,"\n");
}

void suma(FILE* f){
	fprintf(f,"suma:\n");
	fprintf(f,"	push dword rsuma \n");
	fprintf(f,"	call print_string\n");
	fprintf(f,"	ADD esp,4\n");
	fprintf(f,"	call print_endofline\n");
	fprintf(f,"\n");
	fprintf(f,"	MOV eax, [op1]\n");
	fprintf(f,"	MOV ebx, [op2]\n");
	fprintf(f,"	ADD eax, ebx\n");
	fprintf(f,"\n");
	fprintf(f,"	push dword eax\n");
	fprintf(f,"	call print_int\n");
	fprintf(f,"	ADD esp,4\n");
	fprintf(f,"	call print_endofline\n");
	fprintf(f,"\n");
}
void resta(FILE* f){
	fprintf(f,"resta:\n");
	fprintf(f,"	push dword rdif \n");
	fprintf(f,"	call print_string\n");
	fprintf(f,"	ADD esp,4\n");
	fprintf(f,"	call print_endofline\n");
	fprintf(f,"\n");
	fprintf(f,"	MOV eax, [op1]\n");
	fprintf(f,"	MOV ebx, [op2]\n");
	fprintf(f,"	SUB eax, ebx\n"); /**sub eax,edx*/
	fprintf(f,"\n");
	fprintf(f,"	push dword eax\n");
	fprintf(f,"	call print_int\n");
	fprintf(f,"	ADD esp,4\n");
	fprintf(f,"	call print_endofline\n");
	fprintf(f,"\n");
}
void multiplicacion(FILE* f){
	fprintf(f,"mult:\n");
	fprintf(f,"	push dword rmul \n");
	fprintf(f,"	call print_string\n");
	fprintf(f,"	ADD esp,4\n");
	fprintf(f,"	call print_endofline\n");
	fprintf(f,"\n");
	fprintf(f," MOV eax,[op1] \n");
	fprintf(f," MOV ecx,[op2] \n");
	fprintf(f,"	IMUL ecx\n");
	fprintf(f,"\n");
	fprintf(f,"	push eax\n");
	fprintf(f,"	call print_int\n");
	fprintf(f,"	ADD esp,4\n");
	fprintf(f,"	call print_endofline\n");
	fprintf(f,"\n");
}
void division(FILE* f){
	fprintf(f,"div:\n");
	fprintf(f,"	MOV ecx,[op2] \n");
	fprintf(f,"	cmp ecx,0\n");
	fprintf(f,"	je error\n");
	fprintf(f,"\n");
	fprintf(f,"	push dword rdiv \n");
	fprintf(f,"	call print_string\n");
	fprintf(f,"	ADD esp,4\n");
	fprintf(f,"	call print_endofline\n");
	fprintf(f,"\n");
	fprintf(f,"	MOV eax,[op1] \n");
	fprintf(f,"	MOV ecx,[op2] \n");
	fprintf(f,"	CDQ\n");
	fprintf(f,"	IDIV ecx\n");
	fprintf(f,"\n");
	fprintf(f,"	push eax\n");
	fprintf(f,"	call print_int\n");
	fprintf(f,"	ADD esp,4\n");
	fprintf(f,"	call print_endofline\n");
	fprintf(f,"\n");
	fprintf(f,"	jmp fin\n");
	fprintf(f,"\n");
}
