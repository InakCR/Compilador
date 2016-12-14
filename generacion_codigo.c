#include "generacion_codigo.h"

void escribirSegmentos(FILE* f,TABLA_HASH* hash){
	escribirData(f);
	escribirBss(f,hash);
	escribirText(f);
}
void escribirData(FILE* f){
	fprintf(f,"segment .data\n");
	fprintf(f,"mensaje_1 db 'Indice fuera de rango' , 0\n");
	fprintf(f,"mensaje_2 db 'División por cero' , 0\n");
	fprintf(f,"\n");
}
void escribirBss(FILE* f,TABLA_HASH* hash){
	NODO_HASH *n;
	int i;
	fprintf(f,"segment .bss\n");
	for(i=0;i<hash->tam;i++){
		n=hash->tabla[i];
		while(n!=NULL){
			if(n->info->clase==ESCALAR)
				fprintf(f, "_%s resd",n->info->lexema);
			if(n->info->clase==VECTOR)
				fprintf(f, "_%s resd %d",n->info->lexema,n->info->adicional1);
			n=n->siguiente;
		}
	}
	fprintf(f,"\n");
}
void escribirText(FILE* f){
	fprintf(f,"segment .text\n");
	fprintf(f,"global main\n");
	fprintf(f,"extern scan_int, scan_boolean\n");
	fprintf(f,"extern print_int, print_boolean, print_string, print_blank, print_endofline\n");
	fprintf(f,"\n");
}
void escribirImain(FILE* f){
	fprintf(f,"main:\n");
	fprintf(f,"\n");
}
void escribirFmain(FILE* f){
	fprintf(f,"error_1: push dword mensaje_1\n");
	fprintf(f,"   call print_string\n");
	fprintf(f,"   add esp, 4\n");
	fprintf(f,"   jmp near fin\n");
	fprintf(f,"error_2: push dword mensaje_2\n");
	fprintf(f,"   call print_string\n");
	fprintf(f,"   add esp, 4\n");
	fprintf(f,"   jmp near fin\n");
	fprintf(f,"fin: ret\n");
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
