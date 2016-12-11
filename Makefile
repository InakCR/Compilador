
CC = gcc
CFLAGS = -Wall
EXE = alfa

all : $(EXE)

$(EXE) : lex.yy.c y.tab.c y.tab.h tablaHash.c tablaHash.h
	@echo "#----------------------------------------"
	@echo "#        Generando alfa                  "
	@echo "#----------------------------------------"
	$(CC) $(CFLAGS) -o $@ $^

y.tab.h y.tab.c : alfa.y
	@echo "#----------------------------------------"
	@echo "# Generando Bison: alfa.tab.h alfa.tab.c "
	@echo "#----------------------------------------"
	bison -d -y -v $^

lex.yy.c : alfa.l y.tab.h
	@echo "#----------------------------------------"
	@echo "#        Generando Flex: lex.yy.c        "
	@echo "#----------------------------------------"
	flex  $^

clean :
		rm -f *.o lex.yy.c y.output y.tab.* $(EXE)
