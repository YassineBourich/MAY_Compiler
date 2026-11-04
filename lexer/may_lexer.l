%option noyywrap nodefault noinput nounput

%{
#include <stdio.h>
#include <stdlib.h>
#include "../parser/ast.h"
#include "../parser/may_parser.tab.h"

static int line = 1;
static int column = 1;

static void emit(const int kind, const char *lexeme,
                 int token_line, int token_column)
{
    printf("%-10d lexeme=\"%s\"  @ %d:%d\n",
           kind, lexeme, token_line, token_column);
}

#define EMIT(kind) (emit((kind), yytext, line, column), column += yyleng, kind)
%}

DIGIT       [0-9]
LETTER      [A-Za-z_]
ID          {LETTER}({LETTER}|{DIGIT})*
INT         {DIGIT}+
FLOAT       ({DIGIT}+\.{DIGIT}*|\.{DIGIT}+)
IMAGINARY   ({FLOAT}|{INT})i
CHAR        ([^\'\\\n]|\\.)
STRING      \"{CHAR}*\"
RAW_STRING  `[^`]*`
RUNE        \'{CHAR}\'
HSPACE      [ \t\r]+
SINGLE_LINE_COMMENT     "//"[^\n]*
MULTILINE_COMMENT       "/*"([^*]|\*+[^*/])*\*+"/"

%%


    /* ________ Keywords ________ */
"break"       { return EMIT(BREAK); }
"case"        { return EMIT(CASE); }
    /*"chan"        { return EMIT(CHAN); } */
"const"       { return EMIT(CONST); }
"continue"    { return EMIT(CONTINUE); }
"default"     { return EMIT(DEFAULT); }
    /*"defer"       { EMIT("DEFER"); } */
"do"          { return EMIT(DO); }
"else"        { return EMIT(ELSE); }
    /*"fallthrough" { EMIT("FALLTHROUGH"); } */
"for"         { return EMIT(FOR); }
    /*"func"        { EMIT("FUNC"); } */
    /*"go"          { EMIT("GO"); } */
    /*"goto"        { EMIT("GOTO"); } */
"if"          { return EMIT(IF); }
    /*"import"      { return EMIT(IMPORT); } (Currently omited) */
    /*"interface"   { EMIT("INTERFACE"); } */
    /*"map"         { EMIT("MAP"); } */
"program"     { return EMIT(PROGRAM); }
    /*"range"       { EMIT("RANGE"); } */
"return"      { return EMIT(RETURN); }
    /*"select"      { EMIT("SELECT"); } */
"struct"      { return EMIT(STRUCT); }
"switch"      { return EMIT(SWITCH); }
    /*"type"        { return EMIT(TYPE); } */
"var"         { return EMIT(VAR); }
"while"       { return EMIT(WHILE); }


    /* ________ Boolean Operators ________ */
"&="          { return EMIT(AND_ASSIGN); }
"|="          { return EMIT(OR_ASSIGN); }
"^="          { return EMIT(XOR_ASSIGN); }
"&&"          { return EMIT(AND); }
"||"          { return EMIT(OR); }
"^^"          { return EMIT(XOR); }
"!"           { return EMIT(NOT); }

    /* ________ Boolean Bitwise Operators ________ */
"&^"          { return EMIT(BIT_CLEAR); }
"<<"          { return EMIT(SLL); }
">>"          { return EMIT(SRL); }
">>>"          { return EMIT(SRA); }
"<<="         { return EMIT(SLL_ASSIGN); }
">>="         { return EMIT(SRL_ASSIGN); }
">>>="         { return EMIT(SRA_ASSIGN); }
"&^="         { return EMIT(CLEAR_ASSIGN); }
"&"           { return EMIT(BITWISE_AND); }
"|"           { return EMIT(BITWISE_OR); }
"^"           { return EMIT(BITWISE_XOR); }
"~"           { return EMIT(BITWISE_NOT); }


    /* ________ Comparison Operators ________ */
"=="        { return EMIT(EQ); }
"!="        { return EMIT(NE); }
"<="        { return EMIT(LE); }
">="        { return EMIT(GE); }
"="         { return EMIT(ASSIGN); }
"<"         { return EMIT(LT); }
">"         { return EMIT(GT); }

    /* ________ Arithmetic Operators ________ */
"++"         { return EMIT(INCREMENT); }
"--"         { return EMIT(DECREMENT); }
"+="         { return EMIT(PLUS_ASSIGN); }
"-="         { return EMIT(MINUS_ASSIGN); }
"*="         { return EMIT(STAR_ASSIGN); }
"/="         { return EMIT(SLASH_ASSIGN); }
"%="         { return EMIT(MOD_ASSIGN); }
"+"         { return EMIT(PLUS); }
"-"         { return EMIT(MINUS); }
"*"         { return EMIT(STAR); }
"/"         { return EMIT(SLASH); }
"%"         { return EMIT(MOD); }

    /* ________ Parentheses and Colons ________ */
"("         { return EMIT(LPAREN); }
")"         { return EMIT(RPAREN); }
"["         { return EMIT(LBRACKET); }
"]"         { return EMIT(RBRACKET); }
"{"         { return EMIT(LBRACE); }
"}"         { return EMIT(RBRACE); }
","         { return EMIT(COMMA); }
"..."       { return EMIT(ELLIPSIS); }
"."         { return EMIT(DOT); }
":"         { return EMIT(COLON); }
";"         { return EMIT(SEMI); }


{INT}       {
                char *end = NULL;
                long value = strtol(yytext, &end, 10);

                printf("%-10d lexeme=\"%s\" value=%ld @ %d:%d\n",
                       INT, yytext, value, line, column);

                column += yyleng;
                return INT;
            }

{FLOAT}     {
                char *end = NULL;
                double value = strtod(yytext, &end);

                printf("%-10d lexeme=\"%s\" value=%g @ %d:%d\n",
                       FLOAT, yytext, value, line, column);

                column += yyleng;
                return FLOAT;
            }

{IMAGINARY} {
                char *end = NULL;
                double value = strtod(yytext, &end);

                printf("%-10d lexeme=\"%s\" value=%gi @ %d:%d\n",
                       IMAGINARY, yytext, value, line, column);

                column += yyleng;
                return IMAGINARY;
            }
{STRING}    { return EMIT(STRING); }
{RUNE}    { return EMIT(RUNE); }

{RAW_STRING} {
                emit(STRING, yytext, line, column);

                for (int i = 0; i < yyleng; i++) {
                    if (yytext[i] == '\n') {
                        line++;
                        column = 1;
                    } else {
                        column++;
                    }
                }
                return STRING;
             }

{ID}        { return EMIT(ID); }

{SINGLE_LINE_COMMENT}   { column += yyleng; }
{MULTILINE_COMMENT}     {
                            for (int i = 0; i < yyleng; i++) {
                                if (yytext[i] == '\n') {
                                    line++;
                                    column = 1;
                                } else {
                                    column++;
                                }
                            }
                        }

{HSPACE}    { column += yyleng; }
\n          { line += 1; column = 1; }

.           {
                fprintf(stderr,
                        "Erreur lexicale : caractere inattendu '%s' @ %d:%d\n",
                        yytext, line, column);
                column += yyleng;
            }

%%

int main(void) {
    yylex();
    emit(YYEOF, "", line, column);
    return EXIT_SUCCESS;
}