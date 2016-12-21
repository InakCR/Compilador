
CC = gcc
CFLAGS = -Wall
EXE = alfa

all : $(EXE)

$(EXE) :
	@echo "#----------------------------------------"
	@echo "#        Generando alfa                  "
	@echo "#----------------------------------------"
	bison -y -d -v alfa.y
	flex alfa.l
	$(CC) $(CFLAGS) -o alfa alfa.c tablaHash.c generacion_codigo.c y.tab.c lex.yy.c

clean :
		rm -f *.o lex.yy.c y.output y.tab.* $(EXE)
