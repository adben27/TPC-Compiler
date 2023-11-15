%{
/* Bison de départ projet TPC */
#include "tree.h"
#include <stdio.h>
extern int lineno;
int yylex();
int yyerror(char*);
%}

%token TYPE VOID IDENT IF ELSE WHILE RETURN OR AND EQ ORDER ADDSUB DIVSTAR NUM CHARACTER  

%%
Prog:  DeclVars DeclFoncts
    ;
DeclVars:
       DeclVars TYPE Declarateurs ';'
    |
    ;
Declarateurs:
       Declarateurs ',' IDENT
    |  IDENT
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
	fprintf(stderr, "%s at line %d\n", msg, lineno);
	return 0;
}

int main(){
	return yyparse();
}
