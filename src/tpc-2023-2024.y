%{
/* Bison de départ projet TPC */
#include "tree.h"
#include <stdio.h>
#include <string.h>
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

%type<node> Prog DeclVars Declarateurs DeclFoncts DeclFonct EnTeteFonct Parametres ListTypVar Corps SuiteInstr Instr Exp TB FB M E T F LValue Arguments ListExp
%token<byte> CHARACTER ADDSUB DIVSTAR
%token<num> NUM
%token<ident> TYPE VOID IDENT IF ELSE WHILE RETURN
%token<comp> EQ ORDER OR AND

%expect 1

%%
Prog:  DeclVars DeclFoncts { $$ = makeNode(program); addChild($$, $1);/*addChild($$, $2);*/ printTree($$); deleteTree($$);}
    ;
DeclVars:
       DeclVars TYPE Declarateurs ';' {addChild($1, makeNode(declaration)); $$ = $1; addChild($$, makeNode(type));}
    | {$$ = makeNode(declarations);}
    ;
Declarateurs:
       Declarateurs ',' IDENT {$$ = $1; addChild($$, makeNode(ident));} 
    |  IDENT {$$ = makeNode(ident);}
    ;
DeclFoncts:
       DeclFoncts DeclFonct { $$ = $1;}
    |  DeclFonct {$$ = makeNode(fonctions); $$ = $1;}
    ;
DeclFonct:
       EnTeteFonct Corps { $$ = makeNode(fonction); addChild($$, $1); addChild($$, $2);}
    ;
EnTeteFonct:
       TYPE IDENT '(' Parametres ')' { $$ = makeNode(entete); addChild($$, makeNode(type)); addChild($$, makeNode(ident)); addChild($$, $4);}
    |  VOID IDENT '(' Parametres ')' { addChild($$, makeNode(ident)); addChild($$, $4);}
    ;
Parametres:
       VOID {}
    |  ListTypVar {$$ = makeNode(parametres); $$ = $1; }
    ;
ListTypVar:
       ListTypVar ',' TYPE IDENT { $$ = $1; addChild($$, makeNode(type)); addChild($$, makeNode(ident));}
    |  TYPE IDENT { $$ = makeNode(vars); addChild($$, makeNode(type)); addChild($$, makeNode(ident));}
    |  TYPE IDENT '[' ']' {}
    ;
Corps: '{' DeclVars SuiteInstr '}' { $$ = makeNode(corps); addChild($$, $2); addChild($$, $3);}
    ;
SuiteInstr:
       SuiteInstr Instr {addChild($1, makeNode(instruction)); $$ = $1;}
    | {$$ = makeNode(instructions);}
    ;
Instr:
       LValue '=' Exp ';' {$$ = makeNode(eq); addChild($$, $1); addChild($$, $3);}
    |  IF '(' Exp ')' Instr {$$ = makeNode(ifcond); addChild($$, $3); addChild($$, $5);}
    |  IF '(' Exp ')' Instr ELSE Instr {}
    |  WHILE '(' Exp ')' Instr {$$ = makeNode(whilecond); addChild($$, $3); addChild($$, $5);}
    |  IDENT '(' Arguments  ')' ';' { $$ = makeNode(ident); $$ = $3;}
    |  RETURN Exp ';' {$$ = makeNode(returncond); addChild($$, $2);}
    |  RETURN ';' {$$ = makeNode(returncond);}
    |  '{' SuiteInstr '}' { $$ = $2;}
    |  ';' {}
    ;
Exp :  Exp OR TB {$$ = makeNode(or); addChild($$, $1); addChild($$, $3);}
    |  TB {$$ = $1;}
    ;
TB  :  TB AND FB {$$ = makeNode(and); addChild($$, $1); addChild($$, $3);}
    |  FB {$$ = $1;}
    ;
FB  :  FB EQ M {$$ = makeNode(eq); addChild($$, $1); addChild($$, $3);}
    |  M {$$ = $1;}
    ;
M   :  M ORDER E {$$ = makeNode(order); addChild($$, $1); addChild($$, $3);}
    |  E {$$ = $1;}
    ;
E   :  E ADDSUB T {$$ = makeNode(addsub); addChild($$, $1); addChild($$, $3);}  
    |  T {$$ = $1;}
    ;
T   :  T DIVSTAR F {$$ = makeNode(divstar); addChild($$, $1); addChild($$, $3);}
    |  F {$$ = $1;}
    ;
F   :  ADDSUB F {} // ça veut dire quoi ??? {; addChild($$, $2);}
    |  '!' F {$$ = makeNode(not); addChild($$, $2);}
    |  '(' Exp ')' { $$ = $2;}
    |  NUM { $$ = makeNode(num);}
    |  CHARACTER { $$ = makeNode(character);}
    |  LValue { $$ = $1;} 
    |  IDENT '(' Arguments  ')' {$$ = makeNode(ident); $$ = $3;}
    ;
LValue:
       IDENT { $$ = makeNode(ident);}
    ;
Arguments:
       ListExp {$$ = $1;}
    | {$$ = makeNode(arguments);}
    ;
ListExp:
       ListExp ',' Exp {$$ = $1; addChild($$, $3);}
    |  Exp {addChild($$,$1);}
    ;
%%

int yyerror(char *msg) {
	fprintf(stderr, "%s at line %d and column %d\n", msg, lineno, column);
	return 0;
}

int main() {
	return yyparse();
}
