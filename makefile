# Makefile TP Flex

# $@ : the current target
# $^ : the current prerequisites
# $< : the first current prerequisite

CC=gcc
CFLAGS=-Wall
LDFLAGS=-Wall -lfl -ly
SRC = ./src/
BIN = ./bin/
OBJ = ./obj/
EXEC=tpc-2023-2024

all: $(BIN)tpcas clean

$(BIN)tpcas : $(OBJ)lex.yy.o $(OBJ)$(EXEC).tab.o $(OBJ)tree.o
	$(CC) -o $@ $^ $(LDFLAGS)

$(OBJ)lex.yy.c: $(SRC)$(EXEC).lex
	  flex $<

$(OBJ)lex.yy.o: $(OBJ)lex.yy.c $(OBJ)$(EXEC).tab.c
	$(CC) -o $@ -c $< $(CFLAGS)

$(OBJ)$(EXEC).tab.c : $(SRC)$(EXEC).y 
	bison -d $<

$(OBJ)$(EXEC).tab.o : $(OBJ)$(EXEC).tab.c $(OBJ)$(EXEC).tab.h
	$(CC) -o $@ -c $< $(CFLAGS) 

$(OBJ)tree.o : $(SRC)tree.c $(SRC)tree.h
	$(CC) -o $@ -c $< $(CFLAGS)

clean:
	rm -f $(BIN)tpcas
