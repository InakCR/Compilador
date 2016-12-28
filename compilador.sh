#!/bin/bash

nasm -g -o compilador.o -f elf32 sal.asm

gcc -m32 -o compilador compilador.o alfalib/alfalib.o

./compilador
