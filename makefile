# Makefile TP Flex

# $@ : the current target
# $^ : the current prerequisites
# $< : the first current prerequisite

CC=gcc
CFLAGS= -Wall -g -Iobj -Isrc
LDFLAGS= -lfl
EXEC=tpc-2023-2024

bin/tpcas : obj/lex.yy.o obj/$(EXEC).tab.o obj/tree.o | bin
	$(CC) -o $@ $^ $(CFLAGS) $(LDFLAGS)

obj/tree.o : src/tree.c src/tree.h | obj
	$(CC) -o $@ -c $< $(CFLAGS)

obj/$(EXEC).tab.o : obj/$(EXEC).tab.c | obj
	$(CC) -o $@ -c $< $(CFLAGS)

obj/lex.yy.o : obj/lex.yy.c obj/$(EXEC).tab.c | obj 
	$(CC) -o $@ -c $< $(CFLAGS)

obj/lex.yy.c: src/$(EXEC).lex | obj
	  flex -o $@ $<

obj/$(EXEC).tab.c : src/$(EXEC).y obj/tree.o | obj
	bison --output=$@ --defines=obj/$(EXEC).tab.h $<

bin obj:
	mkdir $@

clean:
	rm -rf bin obj
