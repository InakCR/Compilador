/*
 * Fichero: prueba_tabla.c
 * Autor: Iñaki Cadalso , Daniel Cuesta
 * Curso: 2016-17
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "tablaHash.h"
#define HASHSIZE 101
int main(int argc, char** argv){
        FILE* fe = NULL, *fs = NULL;
        TABLA_HASH* global = NULL, *local = NULL, *ambito = NULL;
        char f1[256], f2[256], iden [20];
        int valor = -1, valorg = -1, valorl = -1, valora = -1;
        INFO_SIMBOLO * sim = NULL;
        /*Lectura porarmumentos de los ficheros de entrada y salida*/
        if(argc < 3) {
                printf("Introduzca nombre de ficheros\n");
                return 0;
        }
        strcpy(f1, argv[1]);
        strcpy(f2, argv[2]);
        /*Inicializacion de las tablas hash*/
        local = crear_tabla(HASHSIZE);
        global = crear_tabla(HASHSIZE);
        ambito=global;

        /*Apertura de los ficheros de salida(escritura) y entrada(lectura)*/
        fe = fopen(f1, "r");
        if(!fe) {
                printf("Nombre de fichero no encontrado\n");
                return 0;
        }
        fs = fopen(f2, "w");
        /*Lectura de ficherao fe hasta fin de linea(EOF)*/
        while (fscanf(fe, "%s\t%d", iden, &valor) != EOF) {
                sim = buscar_simbolo(ambito, iden);
                if(sim)
                        valora= sim->adicional1;
                else
                        valora = 0;

                if (valor<-1) { /*Nuevo ambito o cierre del ambito*/

                        if (valor == -999) { /*Cierre Ambito*/

                                if (strcmp(iden, "cierre") == 0) {
                                        liberar_tabla(local); /*Se limpia la tabla local*/
                                        local = crear_tabla(HASHSIZE);
                                        ambito = global; /*Se cambia de ambito al global*/
                                        fprintf(fs, "%s\n", iden);
                                        printf("Cierre de ambito \n");
                                }
                        }
                        if (valor>-999) { /*Creacion de un nuevo ambito segun el indentificador*/
                                if (valora == 0) {
                                        insertar_simbolo(global,iden,FUNCION,ENTERO,VECTOR, valor, valor);
                                        insertar_simbolo(local,iden,FUNCION,ENTERO,VECTOR, valor, valor);
                                        ambito = local; /*Se cambia de ambito al local*/
                                        fprintf(fs, "%s\n", iden);
                                        printf("Insercion del %s con valor: %d y apertura de Ambito \n", iden, valor);
                                }
                                if (valora != 0) {
                                        fprintf(fs, "-1\t%s\n", iden);
                                        printf("Fallo al insertar %s con valor: %d \n", iden, valor);
                                }

                        }
                }
                if (valor >-1) {/*insercion del identificador en el ambito*/
                        if (valora == 0) {
                                insertar_simbolo(ambito,iden,VARIABLE,ENTERO,ESCALAR, valor, valor);
                                fprintf(fs, "%s\n", iden);
                                printf("Insercion del %s con valor: %d \n", iden, valor);
                        }
                        if (valora != 0) {
                                fprintf(fs, "-1\t%s\n", iden);
                                printf("Fallo en la insercion de %s, ya existe\n", iden);
                        }
                }
                if (valor == -1) { /*Busqueda del iden en la tabla global y en la local,primero mirando en el ambito,seguido de la local y por ultimo de la global*/

                        if (valora != 0) { /*En el ambito*/
                                fprintf(fs, "%s\t%d\n", iden, valora);
                                printf("Encontrado el %s con valor en el ambito: %d \n", iden, valora);
                        }
                        if (valora == 0) { /*En la otra tabla , mirando la local y por ultimo la global*/
                                sim = buscar_simbolo(local, iden);
                                if(sim)
                                        valorl = sim->adicional1;
                                else
                                        valorl = 0;
                                sim = buscar_simbolo(global, iden);
                                if(sim)
                                        valorg = sim->adicional1;
                                else
                                        valorg = 0;
                                if (valorl != 0) {
                                        fprintf(fs, "%s\t%d\n", iden, valorl);
                                        printf("Encontrado el %s con valor en local: %d \n", iden, valorl);
                                }
                                else if (valorg != 0) {
                                        fprintf(fs, "%s\t%d\n", iden, valorg);
                                        printf("Encontrado el %s con valor en global: %d \n", iden, valorg);
                                }
                                else if(valorg == 0 && valorl == 0) {
                                        fprintf(fs, "%s\t-1\n", iden);
                                        printf("No encontrado el %s \n", iden);
                                }
                        }
                }


                valor = -1; /*Inicializacion del valor de lectura por si no se lee nada en la siguiente iteracion de fscanf*/
        }

        /*Cierre de ficheros*/
        fclose(fe);
        fclose(fs);

        /*Limpieza de tablas hash*/
        if(global)
                liberar_tabla(global);
        if(local)
                liberar_tabla(local);
        return 1;
}
