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

%type<node> Prog DeclVars Declarateurs DeclFoncts DeclFonct EnTeteFonct Parametres ListTypVar Corps SuiteInstr Instr Exp TB FB M E T F LValue Arguments ListExp
%token<byte> CHARACTER ADDSUB DIVSTAR
%token<num> NUM
%token<ident> TYPE VOID IDENT IF ELSE WHILE RETURN
%token<comp> EQ ORDER
%token OR AND

%expect 1

%%
Prog:  DeclVars DeclFoncts {$$ = makeNode(program); addChild($$, $1); addSibling($1,$2); printTree($$); deleteTree($$);}
    ;
DeclVars:
       DeclVars TYPE Declarateurs ';' {addChild($1, makeNode(declaration)); $$ = $1;}
    | {$$ = makeNode(declarations);}
    ;
Declarateurs:
       Declarateurs ',' IDENT {$$ = $1; addChild($$, makeNode(ident));} 
    |  IDENT {addChild($$, makeNode(ident));}
    ;
DeclFoncts:
       DeclFoncts DeclFonct {$$ = $1; addChild($$, $2);}
    |  DeclFonct {addChild($$, $1);}
    ;
DeclFonct:
       EnTeteFonct Corps { addChild($$, $1); addChild($$, $2);}
    ;
EnTeteFonct:
       TYPE IDENT '(' Parametres ')' { addChild($$, makeNode(type)); addChild($$, makeNode(ident)); addChild($$, $4);}
    |  VOID IDENT '(' Parametres ')'
    ;
Parametres:
       VOID {addChild($$, makeNode(void));}
    |  ListTypVar {$$ = $1;}
    ;
ListTypVar:
       ListTypVar ',' TYPE IDENT { $$ = $1; addChild($$, makeNode(type)); addChild($$, makeNode(ident));}
    |  TYPE IDENT { addChild($$, makeNode(type)); addChild($$, makeNode(ident));}
    ;
Corps: '{' DeclVars SuiteInstr '}' {$2 = makeNode(vars); addChild($$, $2); addChild($$, $3);}
    ;
SuiteInstr:
       SuiteInstr Instr {$$ = $1};
    | {$$ = makeNode(instr);}
    ;
Instr:
       LValue '=' Exp ';' {$$ = $1; addChild($$,makeNode(=)); addChild($$, $1); addChild($$, $3);}
    |  IF '(' Exp ')' Instr {$$ = $5; $1 = addChild(if); addChild($$, $1); addChild($1, $3);}
    |  IF '(' Exp ')' Instr ELSE Instr
    |  WHILE '(' Exp ')' Instr {$$ = $5; $1 = addChild(while); addChild($$, $1); addChild($1, $3);}
    |  IDENT '(' Arguments  ')' ';' {$$ = $3; addChild($$, makeNode(ident));}
    |  RETURN Exp ';' {$1 = makeNode(return); addChild($$, $1); addChild($1, $2);}
    |  RETURN ';' {addChild($$, makeNode(return));}
    |  '{' SuiteInstr '}' {$$ = $2;}
    |  ';'
    ;
Exp :  Exp OR TB {$$ = makeNode(||);; addChild($$, $1); addSibling($1, $3);}
    |  TB {$$ = $1;}
    ;
TB  :  TB AND FB {$$ = makeNode(&&); addChild($$, $1); addSibling($1, $3);}
    |  FB {$$ = $1;}
    ;
FB  :  FB EQ M {$$ = makeNode(eq); addChild($$, $1); addSibling($1, $3);}
    |  M {$$ = $1;}
    ;
M   :  M ORDER E {$$ = makeNode(order); addChild($$, $1); addSibling($1, $3);}
    |  E {$$ = $1;}
    ;
E   :  E ADDSUB T {$$ = makeNode(addsub); addChild($$, $1); addSibling($1, $3);}  
    |  T {$$ = $1;}
    ;
T   :  T DIVSTAR F {$$ = makeNode(divstar); addChild($$, $1); addSibling($1, $3);}
    |  F {$$ = $1;}
    ;
F   :  ADDSUB F {$$ = $1; addChild($$, $2);}
    |  '!' F {$$ = $1; addChild($$, $2);}
    |  '(' Exp ')' {makeNode($$, makeNode(!));}
    |  NUM {addChild($$, makeNode(num));}
    |  CHARACTER {addChild($$, makeNode(character));}
    |  LValue {$$ = $1;} 
    |  IDENT '(' Arguments  ')' {$$ = $3; addChild($$, makeNode(ident));}
    ;
LValue:
       IDENT {addChild($$, makeNode(ident));}
    ;
Arguments:
       ListExp {$$ = $1;}
    | {$$ = makeNode(arguments);}
    ;
ListExp:
       ListExp ',' Exp {$$ = $1; addChild($$, $3;)}
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
