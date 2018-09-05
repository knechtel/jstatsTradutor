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
char **arrayPalavras    = NULL;
char **arrayBuffer      = NULL;

void palavrasArrayFree(){
    free(arrayPalavras);
}

void palavrasFree(){
    for(int i =0;i< palavraCnt-1;i++){
        
        free(arrayPalavras[i]);
        
    }
    palavraCnt=0;
}


void addPalavra(char * palavra){
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
%%



"\"" BEGIN(literal);                  { }
<literal>[\^{}}\n]*                   { }
<literal>"\""  BEGIN(INITIAL);        { numLiteral++; }

"/*" BEGIN(test);                  {  }
<test>[\^{}}\n]*                   { numLinesComentario++;}
<test>"*/"  BEGIN(INITIAL);        { numLines++;}
"\n"                               { numLines++;   }
"class"                            {  if(cntChave==0)addPalavra(yytext);}
"{"                                {cntChave++;
    if(arrayBuffer!=NULL)
    {
        for(int i=0;i<bufferCnt;i++){
            if(arrayBuffer[i]!=NULL){
                printf(" %s ",arrayBuffer[i]);
                addPalavra(arrayBuffer[i]);
            }
        }}
        addPalavra("\n");
        bufferFree();
        }
"}"                                { cntChave--;}
";"                                {
                                        bufferFree();
}
"("                                { if(cntChave==1)addBuffer(yytext); if(cntChave==0)addPalavra(yytext); }
")"                                { if(cntChave==1)addBuffer(yytext); if(cntChave==0)addPalavra(yytext); }
"="                                {    }
{palavra}                          { if(cntChave==1)addBuffer(yytext); if(cntChave==0)addPalavra(yytext); }
{nomeInicioFrase}                  { if(cntChave==1)addBuffer(yytext); if(cntChave==0)addPalavra(yytext); }










%%

int main(int argc, char *argv[]){
	yyin = fopen(argv[1], "r");
	yylex();
	fclose(yyin);
    
    printf("\n");
    printf("======== classes seguido de metodo ===== \n");
    for(int i=0;i<palavraCnt;i++){
        if(arrayPalavras[i]!=NULL)
            printf(" %s ",arrayPalavras[i]);
    }

    printf("\n");
    palavrasFree();
    palavrasArrayFree();
    bufferFree();
    bufferArrayFree();
    printf("Numero de linhas = %d \n",numLines+numLinesComentario);
    printf("Numero de linhas comentadas = %d \n",numLinesComentario);
    printf("Numero de literal String = %d \n",numLiteral);
    
    
    return 0;
}
	
