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
                                   addSibling($$, tmp); 
                                   addChild(tmp, makeStringNode($4, IDENTIFIER));
                                }
    | ListTypVar ',' TYPE IDENT '[' ']' { $$ = $1; 
                                   Node* tmp = makeLabelNode(array);
                                   addChild($$, tmp); 
                                   Node* tmp2 = makeStringNode($3, IDENTIFIER);
                                   addChild(tmp, tmp2); 
                                   addChild(tmp2, makeStringNode($4, IDENTIFIER));
                                }
    |  TYPE IDENT { $$ = makeStringNode($1, IDENTIFIER); addChild($$, makeStringNode($2, IDENTIFIER));}
    |  TYPE IDENT '[' ']' { $$ = makeLabelNode(array);
                            Node* tmp = makeStringNode($1, IDENTIFIER);
                            addChild($$, tmp);
                            addChild(tmp, makeStringNode($2, IDENTIFIER));                           
                        }
    ;
Corps: '{' DeclVars SuiteInstr '}' { $$ = makeLabelNode(body); addChild($$, $2); addChild($$, $3);} //OK!
    ;
SuiteInstr: //OK!
       SuiteInstr Instr { $$ = $1; addChild($1, $2);}
    | {$$ = makeLabelNode(instructions);}
    ;
Instr:
       LValue '=' Exp ';' {$$ = makeByteNode('=', OPERATION); addChild($$, $1); addChild($$, $3);} //OK!
    |  IF '(' Exp ')' Instr {$$ = makeStringNode($1, IDENTIFIER); addChild($$, $3); addChild($$, $5);} //OK!
    |  IF '(' Exp ')' Instr ELSE Instr {$$ = makeStringNode($1, IDENTIFIER); //OK!
                                        addChild($$, $3);
                                        addChild($$, $5);
                                        addChild($$, $7);
                                    }
    |  WHILE '(' Exp ')' Instr { $$ = makeStringNode($1, IDENTIFIER); addChild($$, $3); addChild($$, $5);} //OK!
    |  IDENT '(' Arguments  ')' ';' { $$ = makeStringNode($1, IDENTIFIER); addChild($$, $3);} //OK! 
    |  RETURN Exp ';' {$$ = makeStringNode($1, IDENTIFIER); addChild($$, $2);} //OK!
    |  RETURN ';' {$$ = makeStringNode($1, IDENTIFIER);} //OK!
    |  '{' SuiteInstr '}' { $$ = $2; } //OK!
    |  ';' {}
    ;
Exp :  Exp OR TB {$$ = makeStringNode($2, COMPARATOR); addChild($$, $1); addChild($$, $3);} //OK!
    |  TB { $$ = $1; } //OK!
    ;
TB  :  TB AND FB {$$ = makeStringNode($2, COMPARATOR); addChild($$, $1); addChild($$, $3);} //OK!
    |  FB { $$ = $1; } //OK!
    ;
FB  :  FB EQ M {$$ = makeStringNode($2, COMPARATOR); addChild($$, $1); addChild($$, $3);} //OK!
    |  M { $$ = $1; } //OK!
    ;
M   :  M ORDER E {$$ = makeStringNode($2, COMPARATOR); addChild($$, $1); addChild($$, $3);} //OK!
    |  E { $$ = $1; } //OK!
    ;
E   :  E ADDSUB T {$$ = makeByteNode($2, OPERATION); addChild($$, $1); addChild($$, $3);} //OK! 
    |  T { $$ = $1; } //OK!
    ;
T   :  T DIVSTAR F {$$ = makeByteNode($2, OPERATION); addChild($$, $1); addChild($$, $3);} //OK!
    |  F { $$ = $1; } //OK!
    ;
F   :  ADDSUB F {$$ = makeByteNode($1, OPERATION); addChild($$, $2);} //OK!
    |  '!' F {$$ = makeByteNode('!', OPERATION); addChild($$, $2);} //OK!
    |  '(' Exp ')' { $$ = $2; } //OK! 
    |  NUM { $$ = makeNumNode($1);} //OK!
    |  CHARACTER { $$ = makeByteNode($1, CHARAC); } //OK!
    |  LValue { $$ = $1; } //OK! 
    |  IDENT '(' Arguments ')' {$$ = makeStringNode($1, IDENTIFIER); addChild($$, $3);} //OK!
    ;
LValue:
       IDENT { $$ = makeStringNode($1, IDENTIFIER);} //OK!
    ;
Arguments: //OK!
       ListExp { $$ = $1;}
    | { $$ = NULL; }
    ;
ListExp: //OK!
       ListExp ',' Exp {$$ = $1; addSibling($$, $3);}
    |  Exp { $$ = $1; }
    ;
%%

int yyerror(char *msg) {
	fprintf(stderr, "%s at line %d and column %d\n", msg, lineno, column);
	return 0;
}

int main() {
	return yyparse();
}
