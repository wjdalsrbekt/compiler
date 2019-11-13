
%{
#define MSDOS
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define DEBUG	0

#define	 MAXSYM	100
#define	 MAXSYMLEN	20
#define	 MAXTSYMLEN	15
#define	 MAXTSYMBOL	MAXSYM/2


int tsymbolcnt=0;
int errorcnt=0;
FILE *fp;

extern char symtbl[MAXSYM][MAXSYMLEN];
extern int maxsym;
extern int lineno;
extern int cnt;
extern int top;
extern int stack[1000];

void	dwgen();
int	gentemp();
void	assgnstmt(int, int);
void	numassgn(int, int);
void	addstmt(int, int, int);-
void	substmt(int, int, int);
void	mulstmt(int, int, int);
void	divstmt(int, int, int);
void	modstmt(int, int, int);
void	swapstmt(int, int);
void	teststmt();
void	elsestmt();
void	finstmt();
void	loopstmt();
void	outstmt();
void	lessthan(int, int);
void	lessequal(int, int);
void	greaterthan(int, int);
void	greaterequal(int, int);
void	equal(int, int);
void	notequal(int, int);
int		insertsym(char *);
void	push(int);
void	pop();
%}

%token	IF ELSE FIN WHILE LT LE GT GE EQ NE SWAP LPAR RPAR SQR ONE TWO THR FOR FIV SIX SVN EHT MOD NIN ZER TEN ADD SUB MUL DIV ASSGN ID NUM STMTEND START END
%left ADD SUB
%left MUL DIV MOD
%left TEN
%right ASSGN


%%
program	: START stmt_list END		{ if (errorcnt==0) dwgen(); }
	;

stmt_list: 	stmt_list stmt 	
	|	/* null */
	| 	error STMTEND	{ errorcnt++; yyerrok;}
	;

stmt	: 	ID ASSGN expr STMTEND	{ $$=$1; assgnstmt($1, $3);}
	| 	IF tof ifstmt ELSE stmt_list FIN	{ finstmt();}
	|	WHILE tof loopstmt FIN	{ outstmt();}
	|	SWAP ID ID STMTEND	{ swapstmt($2, $3);}
	;

loopstmt	:	stmt_list		{ loopstmt();}
	;

ifstmt	:	stmt_list		{ elsestmt();}
	;

tof	: 	expr LT expr	{ teststmt(); lessthan($1, $3); }
	|	expr LE expr	{ teststmt(); lessequal($1, $3); }
	|	expr GT expr	{ teststmt(); greaterthan($1, $3); }
	|	expr GE expr	{ teststmt(); greaterequal($1, $3); }
	|	expr EQ expr	{ teststmt(); equal($1, $3); }
	|	expr NE expr	{ teststmt(); notequal($1, $3); }
	;

expr	: 	expr ADD term	{ $$=gentemp(); addstmt($$, $1, $3); }
	|	expr SUB term	{ $$=gentemp(); substmt($$, $1, $3); }
	|	term
	;


term	: 	term MUL fact	{ $$=gentemp(); mulstmt($$, $1, $3); }
	|	term DIV fact	{ $$=gentemp(); divstmt($$, $1, $3); }
	|	term MOD fact	{ $$=gentemp(); modstmt($$, $1, $3); }
	|	fact
	;

fact	:	expr SQR		{ $$=gentemp(); mulstmt($$, $1, $1); }	
	|	LPAR expr RPAR		{ $$=gentemp(); assgnstmt($$, $2); }
	|	ID	
	|	NUMBER	
	;


NUMBER : FGR TEN FGR {$$=gentemp(); numassgn($$, ($1*10 + $3));}
	| FGR	{$$=gentemp(); numassgn($$, $1); }
	;

FGR	: ONE {$$ = 1;}
	| TWO {$$ = 2;}
	| THR {$$ = 3;}
	| FOR {$$ = 4;}
	| FIV {$$ = 5;}
	| SIX {$$ = 6;}
	| SVN {$$ = 7;}
	| EHT {$$ = 8;}
	| NIN {$$ = 9;}
	| ZER {$$ = 0;}
	;

%%
main() 
{

	printf("계산기 컴파일러 한 글 버 전\n");

	fp=fopen("a.asm", "w");
	
	yyparse();

	fclose(fp);

	if (errorcnt==0) 
		{ printf("Successfully compiled. Assembly code is in 'a.asm'.\n");}
}

yyerror(s)
char *s;
{
	printf("%s (line %d)\n", s, lineno);
}

void swapstmt(left, right)
int left;
int right;
{	
	fprintf(fp, "$ -- SWAP STMT --\n");
	fprintf(fp, "LVALUE %s\n", symtbl[right]); 
	fprintf(fp, "RVALUE %s\n", symtbl[left]); 
	fprintf(fp, "LVALUE %s\n", symtbl[left]); 
	fprintf(fp, "RVALUE %s\n", symtbl[right]); 
	fprintf(fp, ":=\n");
	fprintf(fp, ":=\n");
}

void modstmt(t, first, second)
int t;
int first;
int second;
{
	fprintf(fp, "$ -- MOD STMT --\n");
	fprintf(fp, "LVALUE %s\n", symtbl[t]); 
	fprintf(fp, "RVALUE %s\n", symtbl[first]); 
	fprintf(fp, "RVALUE %s\n", symtbl[first]); 
	fprintf(fp, "RVALUE %s\n", symtbl[second]); 
	fprintf(fp, "/\n"); 
	fprintf(fp, "RVALUE %s\n", symtbl[second]); 
	fprintf(fp, "*\n"); 
	fprintf(fp, "-\n");
	fprintf(fp, ":=\n");
}

void numassgn(idx, num)
int idx;
int num;
{
	fprintf(fp, "$ -- NUM ASSIGNMENT STMT --\n");
	fprintf(fp, "LVALUE %s\n", symtbl[idx]); 
	fprintf(fp, "PUSH %d\n", num); 
	fprintf(fp, ":=\n");
}

void teststmt()
{	
	fprintf(fp, "$ -- TEST STMT --\n");
	fprintf(fp, "LABEL TEST%d\n", ++cnt);
	push(cnt);
	push(cnt);
}

void elsestmt()
{	
	fprintf(fp, "GOTO FIN%d\n", stack[top]);
	fprintf(fp, "$ -- ELSE STMT --\n");
	fprintf(fp, "LABEL OUT%d\n", stack[top]); 
	pop();
}

void finstmt()
{
	fprintf(fp, "$ -- FIN STMT --\n");
	fprintf(fp, "LABEL FIN%d\n", stack[top]); 
	pop();
}

void loopstmt()
{
	fprintf(fp, "$ -- LOOP STMT --\n");
	fprintf(fp, "GOTO TEST%d\n", stack[top]);
	pop();
}

void outstmt()
{
	fprintf(fp, "$ -- OUT STMT --\n");
	fprintf(fp, "LABEL OUT%d\n", stack[top]);
	pop();
}

void lessthan(left, right)
int left;
int right;
{	
	fprintf(fp, "$ -- LT STMT --\n");
	fprintf(fp, "RVALUE %s\n", symtbl[left]); 
	fprintf(fp, "RVALUE %s\n", symtbl[right]); 
	fprintf(fp, "-\n");
	fprintf(fp, "COPY\n");
	fprintf(fp, "GOPLUS OUT%d\n", cnt);
	fprintf(fp, "GOFALSE OUT%d\n", cnt);
}

void lessequal(left, right)
int left;
int right;
{	
	fprintf(fp, "$ -- LE STMT --\n");
	fprintf(fp, "RVALUE %s\n", symtbl[left]); 
	fprintf(fp, "RVALUE %s\n", symtbl[right]); 
	fprintf(fp, "-\n");
	fprintf(fp, "GOPLUS OUT%d\n", cnt);
}

void greaterthan(left, right)
int left;
int right;
{	
	fprintf(fp, "$ -- GT STMT --\n");
	fprintf(fp, "RVALUE %s\n", symtbl[left]); 
	fprintf(fp, "RVALUE %s\n", symtbl[right]); 
	fprintf(fp, "-\n");
	fprintf(fp, "COPY\n");
	fprintf(fp, "GOMINUS OUT%d\n", cnt);
	fprintf(fp, "GOFALSE OUT%d\n", cnt);
}

void greaterequal(left, right)
int left;
int right;
{	
	fprintf(fp, "$ -- GE STMT --\n");
	fprintf(fp, "RVALUE %s\n", symtbl[left]); 
	fprintf(fp, "RVALUE %s\n", symtbl[right]); 
	fprintf(fp, "-\n");
	fprintf(fp, "GOMINUS OUT%d\n", cnt);
}

void equal(left, right)
int left;
int right;
{	
	fprintf(fp, "$ -- EQ STMT --\n");
	fprintf(fp, "RVALUE %s\n", symtbl[left]); 
	fprintf(fp, "RVALUE %s\n", symtbl[right]); 
	fprintf(fp, "-\n");
	fprintf(fp, "GOTRUE OUT%d\n", cnt);
}

void notequal(left, right)
int left;
int right;
{	
	fprintf(fp, "$ -- NE STMT --\n");
	fprintf(fp, "RVALUE %s\n", symtbl[left]); 
	fprintf(fp, "RVALUE %s\n", symtbl[right]); 
	fprintf(fp, "-\n");
	fprintf(fp, "GOFALSE OUT%d\n", cnt);
}

void assgnstmt(left, right)
int left;
int right;
{	
	fprintf(fp, "$ -- ID ASSIGNMENT STMT --\n");
	fprintf(fp, "LVALUE %s\n", symtbl[left]); 
	fprintf(fp, "RVALUE %s\n", symtbl[right]); 
	fprintf(fp, ":=\n");
}
	
void addstmt(t, first, second)
int t;
int first;
int second;
{
	fprintf(fp, "$ -- ADD STMT --\n");
	fprintf(fp, "LVALUE %s\n", symtbl[t]); 
	fprintf(fp, "RVALUE %s\n", symtbl[first]); 
	fprintf(fp, "RVALUE %s\n", symtbl[second]); 
	fprintf(fp, "+\n");
	fprintf(fp, ":=\n");
}

void substmt(t, first, second)
int t;
int first;
int second;
{
	fprintf(fp, "$ -- SUB STMT --\n");
	fprintf(fp, "LVALUE %s\n", symtbl[t]); 
	fprintf(fp, "RVALUE %s\n", symtbl[first]); 
	fprintf(fp, "RVALUE %s\n", symtbl[second]); 
	fprintf(fp, "-\n");
	fprintf(fp, ":=\n");
}

void mulstmt(t, first, second)
int t;
int first;
int second;
{
	fprintf(fp, "$ -- MUL STMT --\n");
	fprintf(fp, "LVALUE %s\n", symtbl[t]); 
	fprintf(fp, "RVALUE %s\n", symtbl[first]); 
	fprintf(fp, "RVALUE %s\n", symtbl[second]); 
	fprintf(fp, "*\n");
	fprintf(fp, ":=\n");
}

void divstmt(t, first, second)
int t;
int first;
int second;
{
	fprintf(fp, "$ -- DIV STMT --\n");
	fprintf(fp, "LVALUE %s\n", symtbl[t]); 
	fprintf(fp, "RVALUE %s\n", symtbl[first]); 
	fprintf(fp, "RVALUE %s\n", symtbl[second]); 
	fprintf(fp, "/\n");
	fprintf(fp, ":=\n");
}

int gentemp()
{
char buffer[MAXTSYMLEN];
char tempsym[MAXSYMLEN]="TTCBU";

	tsymbolcnt++;
	if (tsymbolcnt > MAXTSYMBOL) printf("temp symbol overflow\n");
	itoa(tsymbolcnt, buffer, 10);
	strcat(tempsym, buffer);
	return( insertsym(tempsym) ); // Warning: duplicated symbol is not checked for lazy implementation
}

void dwgen()
{
int i;
	fprintf(fp, "HALT\n");
	fprintf(fp, "$ -- END OF EXECUTION CODE AND START OF VAR DEFINITIONS --\n");

// Warning: this code should be different if variable declaration is supported in the language 
	for(i=0; i<maxsym; i++) 
		fprintf(fp, "DW %s\n", symtbl[i]);
	fprintf(fp, "END\n");
}
void push(num)
int num;
{
	stack[++top]=num;
}
void pop()
{
	top--;
}



