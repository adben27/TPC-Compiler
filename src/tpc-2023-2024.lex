%{
/* Analyseur syntaxique TPC*/
#include "tree.h"
#include "tpc-2023-2024.tab.h"
int lineno = 1;
%}

%option noinput
%option nounput

letter [A-Za-z_]
escape [\t ]

%x COM COMS

%%
"," return ',';

"(" return '(';
")" return ')';
"{" return '{';
"}" return '}';

"=" return '=';
"!" return '!';

"//" BEGIN COM;
<COM>. ;
<COM>\n BEGIN INITIAL;
"/*" BEGIN COMS;
<COMS>"*/" BEGIN INITIAL;
<COMS>. ;

return return RETURN;
if return IF;
else return ELSE;
while return WHILE;

void return VOID;
int|char return TYPE;

[+-] return ADDSUB;
[*/%] return ADDSUB;

[<>] return ORDER;
[<>]= return ORDER;

==|!= return EQ;
"||" return OR;
"&&" return AND;

[0-9]+ return NUM;

{letter}+ return IDENT;

\n lineno++;

{escape}+ ;
";" return ';';
. return CHARACTER;
%%
