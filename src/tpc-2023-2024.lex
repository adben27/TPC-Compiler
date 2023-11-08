%{
/* Analyseur syntaxique TPC*/
#include "tree.h"
#include "tpcas.tab.h"
int lineno = 1;
%}

letter [A-Za-z_]
digit [0-9]
escape [\n\t ]

%x COM

%%
return return RETURN;
if return IF;
else return ELSE;
while return WHILE;

void return VOID;
int|char  return TYPE;

{letter}+/{escape}*"(" printf("%s ", yytext);
"//"{escape}*{letter}+/{escape}* ;
"/*" BEGIN COM;
<COM>"*/" BEGIN INITIAL;
<COM>. ;
[+-] return ADDSUB;
[*/%] return ADDSUB;
{letter}+ return IDENT;
\n lineno++;
.;
%%
