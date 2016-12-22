#include "generacion_codigo.h"

void escribirSegmentos(FILE* f,TABLA_HASH* hash){
	escribirData(f);
	escribirBss(f,hash);
	escribirText(f);
}
void escribirData(FILE* f){
	fprintf(f,"segment .data\n");
	fprintf(f,"\tmensaje_1 db 'Indice fuera de rango' , 0\n");
	fprintf(f,"\tmensaje_2 db 'División por cero' , 0\n");
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
				fprintf(f, "\t_%s resd",n->info->lexema);
			if(n->info->clase==VECTOR)
				fprintf(f, "\t_%s resd %d",n->info->lexema,n->info->adicional1);
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
	fprintf(f,"\tcall print_string\n");
	fprintf(f,"\tadd esp, 4\n");
	fprintf(f,"\tjmp near fin\n");
	fprintf(f,"error_2: push dword mensaje_2\n");
	fprintf(f,"\tcall print_string\n");
	fprintf(f,"\tadd esp, 4\n");
	fprintf(f,"\tjmp near fin\n");
	fprintf(f,"fin: ret\n");
}
void gc_suma_enteros(FILE* f,int es_direccion_op1,int es_direccion_op2){
	fprintf(f, "; cargar el segundo operando en edx\n");
	fprintf(f, "pop dword edx\n");
	if (es_direccion_op2 == 1)
		fprintf(f, "mov dword edx , [edx]\n");
	fprintf(f, "; cargar el primer operando en eax\n");
	fprintf(f,"pop dword eax\n");
	if (es_direccion_op1 == 1)
		fprintf(f, "mov dword eax , [eax]\n");
	fprintf(f, "; realizar la suma y dejar el resultado en eax \n");
	fprintf(f, "add eax,edx\n");
	fprintf(f, "; apilar el resultado\n");
	fprintf(f, "push dword eax\n");
}
void gc_resta_enteros(FILE* f, int es_direccion_op1, int es_direccion_op2){
	fprintf(f, "; cargar el segundo operando en edx\n");
	fprintf(f, "pop dword edx\n");
	if (es_direccion_op2 == 1)
		fprintf(f, "mov dword edx , [edx]\n");
	fprintf(f, "; cargar el primer operando en eax\n");
	fprintf(f,"pop dword eax\n");
	if (es_direccion_op1 == 1)
		fprintf(f, "mov dword eax , [eax]\n");
	fprintf(f, "sub eax,edx\n");
	fprintf(f, "; apilar el resultado\n");
	fprintf(f, "push dword eax\n");
}
void gc_mult_enteros(FILE* f, int es_direccion_op1, int es_direccion_op2){
	fprintf(f, "; cargar el segundo operando en edx\n");
	fprintf(f, "pop dword edx\n");
	if (es_direccion_op2 == 1)
		fprintf(f, "mov dword edx , [edx]\n");
	fprintf(f, "; cargar el primer operando en eax\n");
	fprintf(f,"pop dword eax\n");
	if (es_direccion_op1 == 1)
		fprintf(f, "mov dword eax , [eax]\n");
	fprintf(f, "imult edx\n");
	fprintf(f, "; apilar el resultado\n");
	fprintf(f, "push dword eax\n");
}
void gc_div_enteros(FILE* f, int es_direccion_op1, int es_direccion_op2){
	fprintf(f, "; cargar el segundo operando en edx\n");
	fprintf(f, "pop dword edx\n");
	if (es_direccion_op2 == 1)
		fprintf(f, "mov dword edx , [edx]\n");
	fprintf(f, "; cargar el primer operando en eax\n");
	fprintf(f,"pop dword eax\n");
	if (es_direccion_op1 == 1)
		fprintf(f, "mov dword eax , [eax]\n");
	fprintf(f, "cmp edx, 0\n");
	fprintf(f, "je near error_2\n");
	fprintf(f, "mov ecx,edx\n");
	fprintf(f, "cdq\n");
	fprintf(f, "idiv ecx\n");
	fprintf(f, "; apilar el resultado\n");
	fprintf(f, "push dword eax\n");
}
void gc_neg_enteros(FILE* f,int es_direccion_op1){
	fprintf(f, "; cargar el operando en eax\n");
	fprintf(f, "pop dword eax\n");
	if (es_direccion_op1 == 1)
		fprintf(f, "mov dword eax , [eax]\n");
	fprintf(f, "; realizar la negación. El resultado en eax\n");
	fprintf(f, " neg eax\n");
	fprintf(f, "; apilar el resultado\n");
	fprintf(f, " push dword eax\n");
}
void gc_and_enteros(FILE* f, int es_direccion_op1, int es_direccion_op2){
	fprintf(f, "; cargar el segundo operando en edx\n");
	fprintf(f, "pop dword edx\n");
	if (es_direccion_op2 == 1)
		fprintf(f, "mov dword edx , [edx]\n");
	fprintf(f, "; cargar el primer operando en eax\n");
	fprintf(f,"pop dword eax\n");
	if (es_direccion_op1 == 1)
		fprintf(f, "mov dword eax , [eax]\n");
	fprintf(f, "; realizar la suma y dejar el resultado en eax \n");
	fprintf(f, "and eax,edx\n");
	fprintf(f, "; apilar el resultado\n");
	fprintf(f, "push dword eax\n");
}
void gc_or_enteros(FILE* f, int es_direccion_op1, int es_direccion_op2){
	fprintf(f, "; cargar el segundo operando en edx\n");
	fprintf(f, "pop dword edx\n");
	if (es_direccion_op2 == 1)
		fprintf(f, "mov dword edx , [edx]\n");
	fprintf(f, "; cargar el primer operando en eax\n");
	fprintf(f,"pop dword eax\n");
	if (es_direccion_op1 == 1)
		fprintf(f, "mov dword eax , [eax]\n");
	fprintf(f, "; realizar la suma y dejar el resultado en eax \n");
	fprintf(f, "or eax,edx\n");
	fprintf(f, "; apilar el resultado\n");
	fprintf(f, "push dword eax\n");
}
void gc_not_enteros(FILE* f, int es_direccion_op1, int etiqueta){
	fprintf(f, "; cargar el operando en eax \n");
	fprintf(f, "pop dword eax\n");
	if(es_direccion_op1 == 1)
		fprintf(f, "mov dword eax , [eax]\n");
	fprintf(f, "; ver si eax es 0 y en ese caso saltar a negar_falso\n");
	fprintf(f, "or eax , eax\n");
	fprintf(f, "jz near negar_falso%d\n",etiqueta);
	fprintf(f, "; cargar 0 en eax (negación de verdadero) y saltar al final\n");
	fprintf(f, "mov dword eax,0 \n");
	fprintf(f, "jmp near fin_negacion%d\n",etiqueta);
	fprintf(f, "; cargar 1 en eax (negación de falso) \n");
	fprintf(f, "negar_falso%d: \n",etiqueta);
	fprintf(f, "	mov dword eax,1 \n");
	fprintf(f, "; apilar eax \n");
	fprintf(f, "fin_negacion%d:\n",etiqueta);
	fprintf(f, "	push dword eax\n");
}
void gc_comp_igual_enteros(FILE* f, int es_direccion_op1, int es_direccion_op2,int etiqueta){
	fprintf(f, "; cargar la segunda expresión en edx\n");
	fprintf(f, "pop dword edx\n");
	if(es_direccion_op2 == 1)
		fprintf(f, "mov dword edx , [edx]\n");
	fprintf(f, "; cargar la primera expresión en eax pop dword eax\n");
	if (es_direccion_op1 == 1)
		fprintf(f, "mov dword eax , [eax]\n");
	fprintf(f, "; comparar y apilar el resultado\n");
	fprintf(f, "cmp eax, edx\n");
	fprintf(f, "je near igual%d\n",etiqueta);
	fprintf(f, "push dword 0\n");
	fprintf(f, "jmp near fin_igual%d\n",etiqueta);
	fprintf(f, "igual%d:\n",etiqueta);
	fprintf(f, "push dword 1\n");
	fprintf(f, "fin_igual%d:\n",etiqueta);
}
void gc_comp_distinto_enteros(FILE* f, int es_direccion_op1, int es_direccion_op2,int etiqueta){
	fprintf(f, "; cargar la segunda expresión en edx\n");
	fprintf(f, "pop dword edx\n");
	if(es_direccion_op2 == 1)
		fprintf(f, "mov dword edx , [edx]\n");
	fprintf(f, "; cargar la primera expresión en eax pop dword eax\n");
	if (es_direccion_op1 == 1)
		fprintf(f, "mov dword eax , [eax]\n");
	fprintf(f, "; comparar y apilar el resultado\n");
	fprintf(f, "cmp eax, edx\n");
	fprintf(f, "jne near distinto%d\n",etiqueta);
	fprintf(f, "push dword 0\n");
	fprintf(f, "jmp near fin_distinto%d\n",etiqueta);
	fprintf(f, "distinto%d:\n",etiqueta);
	fprintf(f, "push dword 1\n");
	fprintf(f, "fin_distinto%d:\n",etiqueta);
}
void gc_comp_menorigual_enteros(FILE* f, int es_direccion_op1, int es_direccion_op2,int etiqueta){
	fprintf(f, "; cargar la segunda expresión en edx\n");
	fprintf(f, "pop dword edx\n");
	if(es_direccion_op2 == 1)
		fprintf(f, "mov dword edx , [edx]\n");
	fprintf(f, "; cargar la primera expresión en eax pop dword eax\n");
	if (es_direccion_op1 == 1)
		fprintf(f, "mov dword eax , [eax]\n");
	fprintf(f, "; comparar y apilar el resultado\n");
	fprintf(f, "cmp eax, edx\n");
	fprintf(f, "jle near menorigual%d\n",etiqueta);
	fprintf(f, "push dword 0\n");
	fprintf(f, "jmp near fin_menorigual%d\n",etiqueta);
	fprintf(f, "menorigual%d:\n",etiqueta);
	fprintf(f, "push dword 1\n");
	fprintf(f, "fin_menorigual%d:\n",etiqueta);
}

void gc_comp_mayorigual_enteros(FILE* f, int es_direccion_op1, int es_direccion_op2,int etiqueta){
	fprintf(f, "; cargar la segunda expresión en edx\n");
	fprintf(f, "pop dword edx\n");
	if(es_direccion_op2 == 1)
		fprintf(f, "mov dword edx , [edx]\n");
	fprintf(f, "; cargar la primera expresión en eax pop dword eax\n");
	if (es_direccion_op1 == 1)
		fprintf(f, "mov dword eax , [eax]\n");
	fprintf(f, "; comparar y apilar el resultado\n");
	fprintf(f, "cmp eax, edx\n");
	fprintf(f, "jge near mayorigual%d\n",etiqueta);
	fprintf(f, "push dword 0\n");
	fprintf(f, "jmp near fin_mayorigual%d\n",etiqueta);
	fprintf(f, "mayorigual%d:\n",etiqueta);
	fprintf(f, "push dword 1\n");
	fprintf(f, "fin_mayorigual%d:\n",etiqueta);
}
void gc_comp_menor_enteros(FILE* f, int es_direccion_op1, int es_direccion_op2,int etiqueta){
	fprintf(f, "; cargar la segunda expresión en edx\n");
	fprintf(f, "pop dword edx\n");
	if(es_direccion_op2 == 1)
		fprintf(f, "mov dword edx , [edx]\n");
	fprintf(f, "; cargar la primera expresión en eax pop dword eax\n");
	if (es_direccion_op1 == 1)
		fprintf(f, "mov dword eax , [eax]\n");
	fprintf(f, "; comparar y apilar el resultado\n");
	fprintf(f, "cmp eax, edx\n");
	fprintf(f, "jl near menor%d\n",etiqueta);
	fprintf(f, "push dword 0\n");
	fprintf(f, "jmp near fin_menor%d\n",etiqueta);
	fprintf(f, "menor%d:\n",etiqueta);
	fprintf(f, "push dword 1\n");
	fprintf(f, "fin_menor%d:\n",etiqueta);
}
void gc_comp_mayor_enteros(FILE* f, int es_direccion_op1, int es_direccion_op2,int etiqueta){
	fprintf(f, "; cargar la segunda expresión en edx\n");
	fprintf(f, "pop dword edx\n");
	if(es_direccion_op2 == 1)
		fprintf(f, "mov dword edx , [edx]\n");
	fprintf(f, "; cargar la primera expresión en eax pop dword eax\n");
	if (es_direccion_op1 == 1)
		fprintf(f, "mov dword eax , [eax]\n");
	fprintf(f, "; comparar y apilar el resultado\n");
	fprintf(f, "cmp eax, edx\n");
	fprintf(f, "jg near mayor%d\n",etiqueta);
	fprintf(f, "push dword 0\n");
	fprintf(f, "jmp near fin_mayorl%d\n",etiqueta);
	fprintf(f, "mayor%d:\n",etiqueta);
	fprintf(f, "push dword 1\n");
	fprintf(f, "fin_mayor%d:\n",etiqueta);
}

void gc_constante(FILE* f, int nlinea,int valor){
	fprintf(f, ";numero_linea%d\n",nlinea);
	fprintf(f, "\tpush dword %d\n",valor);
}

void gc_asignacion_iden(FILE* f,int es_direccion_op1,char* lex){
	fprintf(f, "pop dword eax\n");
	if (es_direccion_op1 == 1)
		fprintf(f, "mov dword eax , [eax]\n");
	fprintf(f, "mov dword [_%s] , eax\n",lex);
}
void gc_asignacion_funcion(FILE* f,int es_direccion,CATEGORIA cat,int pos,int nParLoc){
	fprintf(f, "pop dword eax\n");
	if (es_direccion == 1)
		fprintf(f, "mov dword eax , [eax]\n");
	if(cat == PARAMETRO)
		fprintf(f, "mov dword [ebp+%d]\n",4+4*(nParLoc-pos));
	else
		fprintf(f, "mov dword [ebp-%d]\n",4*pos);
}
void gc_asignacion_vector(FILE* f,int es_direccion_op1){
	fprintf(f, "pop dword eax\n");
	if (es_direccion_op1 == 1)
		fprintf(f, "mov dword eax , [eax]\n");
	fprintf(f, "pop dword edx\n");
	fprintf(f, "mov dword [edx] , eax\n");
}
void gc_asignacion_elemento_vector(FILE* f,int es_direccion_op1,char* lex){
	fprintf(f, "pop dword eax\n");
  if(es_direccion_op1 == 1)
		fprintf(f, "mov dword eax , [eax]\n");
	fprintf(f, "cmp eax,0\n");
	fprintf(f, "jl near mensaje_1\n");
	fprintf(f, "cmp eax, %d\n",MAX_TAMANIO_VECTOR-1);
	fprintf(f, "jl near mensaje_1\n");
	fprintf(f, "mov dword edx _%s\n",lex);
	fprintf(f, "lea eax, [edx + eax*4]\n");
	fprintf(f, "push dword eax\n");
}
void gc_lectura(FILE* f,char* lex,TIPO tipo){
	fprintf(f, "push dword _%s\n",lex );
	if(tipo==INT)
		fprintf(f, "call scan_int\n");
	if(tipo==BOOLEAN)
		fprintf(f, "call scan_boolean\n");
	fprintf(f, "add esp, 4\n");
}
void gc_escritura(FILE* f,int es_direccion,TIPO tipo){
	if(es_direccion == 1){
		fprintf(f, "pop dword eax\n");
		fprintf(f, "mov dword eax , [eax]\n");
		fprintf(f, "push dword eax\n");
	}
	if(tipo==INT)
		fprintf(f, "call print_int\n");
	if(tipo==BOOLEAN)
		fprintf(f, "call print_boolean\n");
	fprintf(f, "add esp, 4\n");
	fprintf(f, "call print_endofnile\n");
}
void gc_if_exp(FILE* f,int es_direccion,int etiqueta){
	fprintf(f, "pop eax\n");
	if(es_direccion==1)
		fprintf(f, "mov eax , [eax]\n");
	fprintf(f, "cmp eax, 0\n");
	fprintf(f, "je near fin_si%d\n",etiqueta);
}
void gc_if_exp_sentencias(FILE* f,int etiqueta){
	fprintf(f, "jmp near fin_sino%d\n",etiqueta);
	fprintf(f, "fin_si%d:\n",etiqueta);
}
void gc_condicional(FILE* f,int etiqueta){
	fprintf(f, "fin_si%d\n",etiqueta);
}
void gc_while_exp(FILE* f,int es_direccion,int etiqueta){
	fprintf(f, "pop eax\n");
	if(es_direccion==1)
		fprintf(f, "mov eax , [eax]\n");
	fprintf(f, "cmp eax, 0\n");
	fprintf(f, "je near fin_while%d\n",etiqueta);
}
void gc_while(FILE* f,int etiqueta){
	fprintf(f, "inicio_while%d:\n",etiqueta);
}
void gc_bucle(FILE* f,int etiqueta){
	fprintf(f, "jmp near inicio_while%d\n",etiqueta);
	fprintf(f, "fin_while%d:\n",etiqueta);
}
void gc_idf_llamada_funcion(FILE* f,char* lex,int gNumPar){
	fprintf(f, "call _%s\n",lex);
	fprintf(f, "add esp, %d\n",4*gNumPar);
	fprintf(f, "push dword eax\n");
}
void gc_fn_declaration(FILE* f,char* lex,int gNumVar){
	fprintf(f, "_%s:\n",lex);
	fprintf(f, "\tpush ebp\n");
	fprintf(f, "\tmov ebp, esp\n");
	fprintf(f, "\tsub esp, %d\n",4*gNumVar);
}
void gc_retorno_funcion(FILE* f,int es_direccion){
	fprintf(f, "pop dword eax\n");
	if(es_direccion==1)
		fprintf(f, "mov eax , [eax]\n");
	fprintf(f, "mov dword esp, ebp\n");
	fprintf(f, "pop dword ebp\n");
	fprintf(f, "ret\n");
}
void gc_exp_iden_var_local(FILE* f,int posVar){
	fprintf(f, "lea eax, [ebp-%d]\n",4*posVar);
	fprintf(f, "push dword eax\n");
}
void gc_exp_iden_param(FILE* f,int gNumPar,int posPar){
	fprintf(f, "lea eax, [ebp+%d]\n",4+4*(gNumPar - posPar));
	fprintf(f, "push dword eax\n");
}
void gc_direccion(FILE* f,char* lex){
		fprintf(f, "push dword _%s\n",lex);
}
void gc_contenido(FILE* f,char* lex){
	fprintf(f, "push dword [_%s]\n",lex);
}
