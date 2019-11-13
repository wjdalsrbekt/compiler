%{
#include <string.h>
#include "cbu.h"
#define MAXSYM	100
#define	MAXSYMLEN	20
char symtbl[MAXSYM][MAXSYMLEN];
extern int yylval;
int lineno=1;
int insertsym();
int maxsym=0;
int cnt=0;
int top=-1;
int stack[1000];
char s[30];

%}
sp		[ \t]
ws		{sp}+
nl		\n
eletter		[A-Za-z]
hletter		[\xb0-\xfe][\xa0-\xfe]
letter		({eletter}|{hletter})
digit		[0-9]
id		{letter}({letter}|{digit})*
%%
{ws}		{/* do nothing */}
{nl}		{lineno++; }
일		{return(ONE);}
이		{return(TWO);}
삼		{return(THR);}
사		{return(FOR);}
오		{return(FIV);}
육		{return(SIX);}
칠		{return(SVN);}
팔		{return(EHT);}
구		{return(NIN);}
영		{return(ZER);}
십		{return(TEN);}
더하기		{return(ADD);}
빼기		{return(SUB);}
곱하기		{return(MUL);}
나누기		{return(DIV);}
는		{return(ASSGN); }
;		{return(STMTEND); }
시작		{return(START);}
끝		{return(END);}
나머지		{return(MOD);}
제곱		{return(SQR);}
스왑		{return(SWAP);}
"("		{return(LPAR);}
")"		{return(RPAR);}
만약		{return(IF);}
아니면		{return(ELSE);}
여기까지		{return(FIN);}
반복조건		{return(WHILE);}
"<"		{return(LT);}
"<="		{return(LE);}
">"		{return(GT);}
">="		{return(GE);}
"=="		{return(EQ);}
"!="		{return(NE);}
:=		{return(ASSGN); }
;		{return(STMTEND); }
{id}		{strncpy(s, yytext, yyleng); s[yyleng]='\0'; yylval=insertsym(s); return(ID);}
{digit}+		{sscanf(yytext, "%d", &yylval); return(NUM);}
.		{printf("invalid token %s\n", yytext); }
%%

int insertsym(s)
char *s;
{
int i;

	for(i=0;i<maxsym; i++) {
		if(strcmp(s, symtbl[i])==0) return(i);
		}
	if (i<MAXSYM-1) {
		strcpy(symtbl[maxsym],s);
		maxsym++;
		return(maxsym-1);
		}
	else
		{printf("symbol table overflow\n");}
	return(0);
}

yywrap() {}