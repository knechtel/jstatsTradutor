%option noyywrap

%{

#include <stdio.h>
#include <string.h>
#include <math.h>
#include <stdlib.h>

int numLines            = 0;
int numLinesComentario  = 0;
int palavraCnt          = 0;
int bufferCnt           = 0;
int numLiteral          = 0;
int cntChave            = 0;
int contLinesCode       = 0;
char **arrayPalavras    = NULL;
char **arrayBuffer      = NULL;

struct token{
    char* padrao;
    int line;
};

struct token arrayToken[100];


int indexArrayToken     = 0;
void palavrasArrayFree(){
    free(arrayPalavras);
}

int containesLineToken(int i){
    for(int j=0 ;j<indexArrayToken;j++){
        if(arrayToken[i].line==i){
            return 1;
        }
    }
    return 0;
}


void palavrasFree(){
    for(int i =0;i< palavraCnt-1;i++){
        
        free(arrayPalavras[i]);
        
    }
    palavraCnt=0;
}


void addToken(char * palavra){
    palavraCnt++;
    if(arrayPalavras==NULL)
    arrayPalavras = (char**) malloc(sizeof(char*) * 1000);
    
    arrayPalavras[palavraCnt-1] = (char*) malloc(sizeof(char)  * 20);
    strcpy(arrayPalavras[palavraCnt-1], palavra);

    
}


//  buffer

void bufferArrayFree(){
    free(arrayBuffer);
}

void bufferFree(){
    for(int i =0;i< bufferCnt-1;i++){
        free(arrayBuffer[i]);
    }
    bufferCnt=0;
}


void addBuffer(char * palavra){
    bufferCnt++;
    if(arrayBuffer==NULL)
    arrayBuffer = (char**) malloc(sizeof(char*) * 1000);
    arrayBuffer[bufferCnt-1] = (char*) malloc(sizeof(char)  * 20);
    strcpy(arrayBuffer[bufferCnt-1], palavra);
    
}
//


%}


%s test
%x  literal token
nomeInicioFrase [A-z]*
palavra [a-z]+
palavraDigito palavra[0-9]+
%%



"\"" BEGIN(literal);                  { }
<literal>[\^{}}\n]*                   { }
<literal>"\""  BEGIN(INITIAL);        { numLiteral++; }

"/*" BEGIN(test);                  {  }
<test>[\^{}}\n]*                   { numLinesComentario++;}
<test>"*/"  BEGIN(INITIAL);        { numLines++;}
"\n"                               { numLines++;   }
"class"                            {  if(cntChave==0)addToken(yytext);}
"{"                                {cntChave++;contLinesCode++;
    if(arrayBuffer!=NULL)
    {
        for(int i=0;i<bufferCnt;i++){
            if(arrayBuffer[i]!=NULL){
                printf(" %s ",arrayBuffer[i]);
                addToken(arrayBuffer[i]);
            }
        }}
        addToken("\n");
        bufferFree();
        }
"}"                                { numLines++;cntChave--;}
";"                                { 
                                        bufferFree();
}
"("                                { if(cntChave==1)addBuffer(yytext); if(cntChave==0)addToken(yytext); }
")"                                { if(cntChave==1)addBuffer(yytext); if(cntChave==0)addToken(yytext); }
"="                                {    }
{palavra}                          {
    
    if(containesLineToken(numLines)==0){
        arrayToken[indexArrayToken].line = numLines;
        indexArrayToken++;}
    if(cntChave==1)
        addBuffer(yytext);
    if(cntChave==0)
        addToken(yytext); }
{palavraDigito}                          {
    if(containesLineToken(numLines)==0){
        arrayToken[indexArrayToken].line = numLines;
        indexArrayToken++;}
    if(cntChave==1)addBuffer(yytext); if(cntChave==0)addToken(yytext); }

{nomeInicioFrase}                  {
    if(containesLineToken(numLines)==0){
    arrayToken[indexArrayToken].line = numLines;
        indexArrayToken++;}
    if(cntChave==1)addBuffer(yytext); if(cntChave==0)addToken(yytext); }










%%

int main(int argc, char *argv[]){
	yyin = fopen(argv[1], "r");
	yylex();
	fclose(yyin);
    
    printf("\e[H\e[2J");
    printf("======== classes seguido de metodo ===== \n");
    for(int i=0;i<palavraCnt;i++){
        if(arrayPalavras[i]!=NULL)
            printf(" %s ",arrayPalavras[i]);
    }
    int linhasDeCodigo =0;
    int ctl=0;
    for(int i=0 ;i<indexArrayToken;i++){
    
        for(int j=0 ;j<indexArrayToken;j++){
            if(arrayToken[i].line==arrayToken[j].line){
                 ctl++;
              if(ctl> 1){
                arrayToken[i].line=0;
                linhasDeCodigo++;
                ctl=0;
              }
           
             }
        }
    }

    printf("\n");
    palavrasFree();
    palavrasArrayFree();
    bufferFree();
    bufferArrayFree();
    printf("Numero total de linhas = %d \n",numLines);
    printf("Numero total de linhas em branco = %d \n",(numLines-numLinesComentario)-linhasDeCodigo);
    printf("Numero de linhas comentadas = %d \n",numLinesComentario);
    printf("Numero de literal String = %d \n",numLiteral);
    printf("Numero de linhas de codigo = %d \n",linhasDeCodigo);
    
    return 0;
}
	
