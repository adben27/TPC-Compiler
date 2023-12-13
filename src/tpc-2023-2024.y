%{
/* Bison de départ projet TPC */
#include "tree.h"
#include <stdio.h>
extern int lineno;
extern int column;
int yylex();
int yyerror(char*);
%}

%union {
    Node *node;    
	char byte;
	int num;
	char ident[64];
	char comp[3];
}

// %type<node> Prog DeclVars Declarateurs DeclFoncts
%token<byte> CHARACTER ADDSUB DIVSTAR
%token<num> NUM
%token<ident> TYPE VOID IDENT IF ELSE WHILE RETURN
%token<comp> EQ ORDER
%token OR AND

%expect 1

%%
Prog:  DeclVars DeclFoncts //{$$ = makeNode(program); addChild($$, $1); addSibling($1,$2); printTree($$); deleteTree($$);}
    ;
DeclVars:
       DeclVars TYPE Declarateurs ';' //{addChild($1, makeNode(declaration)); $$ = $1;}
    | //{$$ = makeNode(declarations);}
    ;
Declarateurs:
       Declarateurs ',' IDENT  
    |  IDENT //{addChild($$, makeNode(ident));}
    ;
DeclFoncts:
       DeclFoncts DeclFonct
    |  DeclFonct
    ;
DeclFonct:
       EnTeteFonct Corps
    ;
EnTeteFonct:
       TYPE IDENT '(' Parametres ')'
    |  VOID IDENT '(' Parametres ')'
    ;
Parametres:
       VOID
    |  ListTypVar
    ;
ListTypVar:
       ListTypVar ',' TYPE IDENT
    |  TYPE IDENT
    ;
Corps: '{' DeclVars SuiteInstr '}'
    ;
SuiteInstr:
       SuiteInstr Instr
    |
    ;
Instr:
       LValue '=' Exp ';'
    |  IF '(' Exp ')' Instr
    |  IF '(' Exp ')' Instr ELSE Instr
    |  WHILE '(' Exp ')' Instr
    |  IDENT '(' Arguments  ')' ';'
    |  RETURN Exp ';'
    |  RETURN ';'
    |  '{' SuiteInstr '}'
    |  ';'
    ;
Exp :  Exp OR TB
    |  TB
    ;
TB  :  TB AND FB
    |  FB
    ;
FB  :  FB EQ M
    |  M
    ;
M   :  M ORDER E
    |  E
    ;
E   :  E ADDSUB T
    |  T
    ;
T   :  T DIVSTAR F
    |  F
    ;
F   :  ADDSUB F
    |  '!' F
    |  '(' Exp ')'
    |  NUM
    |  CHARACTER
    |  LValue
    |  IDENT '(' Arguments  ')'
    ;
LValue:
       IDENT
    ;
Arguments:
       ListExp
    |
    ;
ListExp:
       ListExp ',' Exp
    |  Exp
    ;
%%

int yyerror(char *msg) {
	fprintf(stderr, "%s at line %d and column %d\n", msg, lineno, column);
	return 0;
}

int main() {
	return yyparse();
}
