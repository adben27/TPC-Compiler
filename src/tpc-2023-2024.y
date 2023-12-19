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
Prog:  DeclVars DeclFoncts { $$ = makeLabelNode(program); addChild($$, $1); addChild($$, $2); printTree($$); deleteTree($$);}
    ;
DeclVars: //OK!
       DeclVars TYPE Declarateurs ';' { $$ = $1;
                                        Node* tmp = makeStringNode($2, IDENTIFIER); 
                                        addChild($1, tmp); 
                                        addChild(tmp, $3);
                                    }
    | {$$ = makeLabelNode(declarations);}
    ;
Declarateurs: //OK!
       Declarateurs ',' IDENT {addSibling($$, makeStringNode($3, IDENTIFIER)); $$ = $1;} 
    |  IDENT {$$ = makeStringNode($1, IDENTIFIER);}
    ;
DeclFoncts:
       DeclFoncts DeclFonct {addChild($$,$2); $$ = $1;}
    |  DeclFonct {$$ = makeLabelNode(fonctions); addChild($$, $1);}
    ;
DeclFonct:
       EnTeteFonct Corps { $$ = makeLabelNode(fonction); addChild($$, $1); addChild($$, $2);}
    ;
EnTeteFonct: //OK!
       TYPE IDENT '(' Parametres ')' { $$ = makeLabelNode(heading); addChild($$, makeStringNode($1, IDENTIFIER)); addChild($$, makeStringNode($2, IDENTIFIER)); addChild($$, $4);}
    |  VOID IDENT '(' Parametres ')' { $$ = makeLabelNode(heading); addChild($$, makeStringNode($1, IDENTIFIER)); addChild($$, makeStringNode($2, IDENTIFIER)); addChild($$, $4);}
    ;
Parametres: //OK!
       VOID { $$ = makeLabelNode(parametres); addChild($$, makeStringNode($1, IDENTIFIER)); }
    |  ListTypVar {$$ = makeLabelNode(parametres); addChild($$, $1); }
    ;
ListTypVar: //OK!
       ListTypVar ',' TYPE IDENT { $$ = $1; 
                                   Node* tmp = makeStringNode($3, IDENTIFIER); 
                                   addChild($$, tmp); 
                                   addChild(tmp, makeStringNode($3, IDENTIFIER));
                                }
    |  TYPE IDENT { $$ = makeStringNode($1, IDENTIFIER); addChild($$, makeStringNode($2, IDENTIFIER));}
    |  TYPE IDENT '[' ']' { $$ = makeLabelNode(array);
                            Node* tmp = makeStringNode($1, IDENTIFIER);
                            addChild($$, tmp);
                            addChild(tmp, makeStringNode($2, IDENTIFIER));                           
                        }
    ;
Corps: '{' DeclVars SuiteInstr '}' { $$ = makeLabelNode(body); addChild($$, $2); /*addChild($$, $3);*/}
    ;
SuiteInstr:
       SuiteInstr Instr { $$ = $1;
                        Node* tmp = makeLabelNode(instruction);
                        addChild($1, tmp);
                        addChild($1, $2);
                    }
    | {$$ = makeLabelNode(instructions);}
    ;
Instr:
       LValue '=' Exp ';' {$$ = makeByteNode('='); addChild($$, $1); addChild($$, $3);}
    |  IF '(' Exp ')' Instr {$$ = makeStringNode($1, IDENTIFIER); addChild($$, $3); addChild($$, $5);}
    |  IF '(' Exp ')' Instr ELSE Instr {$$ = makeStringNode($1, IDENTIFIER);
                                        addChild($$, $3);
                                        addChild($$, $5);
                                        $$ = makeStringNode($6, IDENTIFIER);
                                        addChild($$, $7);
                                    }
    |  WHILE '(' Exp ')' Instr {$$ = makeStringNode($1, IDENTIFIER); addChild($$, $3); addChild($$, $5);}
    |  IDENT '(' Arguments  ')' ';' { $$ = makeStringNode($1, IDENTIFIER); addChild($$, $3);}
    |  RETURN Exp ';' {$$ = makeStringNode($1, IDENTIFIER); addChild($$, $2);}
    |  RETURN ';' {$$ = makeStringNode($1, IDENTIFIER);}
    |  '{' SuiteInstr '}' { $$ = $2; }
    |  ';' {}
    ;
Exp :  Exp OR TB {$$ = makeStringNode($2, COMPARATOR); addChild($$, $1); addChild($$, $3);}
    |  TB {$$ = $1;}
    ;
TB  :  TB AND FB {$$ = makeStringNode($2, COMPARATOR); addChild($$, $1); addChild($$, $3);}
    |  FB {$$ = $1;}
    ;
FB  :  FB EQ M {$$ = makeStringNode($2, COMPARATOR); addChild($$, $1); addChild($$, $3);}
    |  M {$$ = $1;}
    ;
M   :  M ORDER E {$$ = makeStringNode($2, COMPARATOR); addChild($$, $1); addChild($$, $3);}
    |  E {$$ = $1;}
    ;
E   :  E ADDSUB T {$$ = makeByteNode($2); addChild($$, $1); addChild($$, $3);}  
    |  T {$$ = $1;}
    ;
T   :  T DIVSTAR F {$$ = makeByteNode($2); addChild($$, $1); addChild($$, $3);}
    |  F {$$ = $1;}
    ;
F   :  ADDSUB F {} // ça veut dire quoi ??? {; addChild($$, $2);}
    |  '!' F {$$ = makeByteNode('!'); addChild($$, $2);}
    |  '(' Exp ')' { $$ = $2;}
    |  NUM { $$ = makeNumNode($1);}
    |  CHARACTER { $$ = makeByteNode($1);}
    |  LValue { $$ = $1;} 
    |  IDENT '(' Arguments  ')' {$$ = makeStringNode($1, IDENTIFIER); $$ = $3;}
    ;
LValue:
       IDENT { $$ = makeStringNode($1, IDENTIFIER);}
    ;
Arguments:
       ListExp {$$ = $1;}
    | {$$ = makeLabelNode(arguments);}
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
