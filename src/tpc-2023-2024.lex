%{
/* Analyseur syntaxique TPC*/
#include "tree.h"
#include "tpc-2023-2024.tab.h"
#include <string.h>
#include <stdlib.h>
int lineno = 1;
int column = 1;
%}

%option noinput
%option nounput

escape [\r\t ]

%x COM COMS

%%
";" { column++; return ';'; }
"," { column++; return ','; }

"(" { column++; return '('; }
")" { column++; return ')'; }
"{" { column++; return '{'; }
"}" { column++; return '}'; }

"=" { column++; return '='; }
"!" { column++; return '!'; }

"[" { column++; return '['; }
"]" { column++; return ']'; }

"//" BEGIN COM;
<COM>. ;
<COM>\n { BEGIN INITIAL; lineno++; column = 1; }
"/*" BEGIN COMS;
<COMS>"*/" BEGIN INITIAL;
<COMS>\n { column = 1; lineno++; }
<COMS>. ;

return {
	column += yyleng;
	strcpy(yylval.ident, yytext);
	return RETURN; 
}

if {
	column += yyleng;
	strcpy(yylval.ident, yytext);
	return IF; 
}

else {
	column += yyleng;
	strcpy(yylval.ident, yytext);
	return ELSE;
}

while {
	column += yyleng;
	strcpy(yylval.ident, yytext);
	return WHILE; 
}

void { 
	column += yyleng;
	strcpy(yylval.ident, yytext);
	return VOID;
}

int|char {
	column += yyleng;
	strcpy(yylval.ident, yytext);
	return TYPE; 
}

[+-] {
	column += yyleng;
	yylval.byte = yytext[0];
	return ADDSUB; 
}

[*/%] {
	column += yyleng;
	yylval.byte = yytext[0];
	return DIVSTAR; 
}

[<>] {
	column += yyleng;
	strcpy(yylval.comp, yytext);
	return ORDER;
}

[<>]= {
	column += yyleng;
	strcpy(yylval.comp, yytext);
	return ORDER;
}

"=="|"!=" {
	column += yyleng;
	strcpy(yylval.comp, yytext);
	return EQ;
}

"||" { 
	column += yyleng;
	strcpy(yylval.comp, yytext);
	return OR; 
}

"&&" { 
	column += yyleng;
	strcpy(yylval.comp, yytext);
	return AND; 
}

-?[0-9]+ {
	column += yyleng;
	yylval.num = atoi(yytext);
	return NUM;
}

'[^'\\]' {
	column += yyleng;
	yylval.byte = yytext[1];
	return CHARACTER;
}

'\\[n|t||'|\\]' {
	column += yyleng;
	switch(yytext[2]) {
		case 'n':
			yylval.byte = '\n';
			break;
		case 't':
			yylval.byte = '\t';
			break;
		default:
			yylval.byte = yytext[2];
			break;
	}
	return CHARACTER;
}

[A-Za-z_][A-Za-z0-9_]* {
	column += yyleng;
  	strcpy(yylval.ident, yytext);
  	return IDENT; 
}

\n { column = 1; lineno++; }
{escape}+ column += yyleng;
. {
	fprintf(stderr, "syntax error at line %d and column %d\n", lineno, column);
	exit(1);
}
%%
