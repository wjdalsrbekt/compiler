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
��		{return(ONE);}
��		{return(TWO);}
��		{return(THR);}
��		{return(FOR);}
��		{return(FIV);}
��		{return(SIX);}
ĥ		{return(SVN);}
��		{return(EHT);}
��		{return(NIN);}
��		{return(ZER);}
��		{return(TEN);}
���ϱ�		{return(ADD);}
����		{return(SUB);}
���ϱ�		{return(MUL);}
������		{return(DIV);}
��		{return(ASSGN); }
;		{return(STMTEND); }
����		{return(START);}
��		{return(END);}
������		{return(MOD);}
����		{return(SQR);}
����		{return(SWAP);}
"("		{return(LPAR);}
")"		{return(RPAR);}
����		{return(IF);}
�ƴϸ�		{return(ELSE);}
�������		{return(FIN);}
�ݺ�����		{return(WHILE);}
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