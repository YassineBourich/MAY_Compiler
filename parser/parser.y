%{
#include <stdio.h>
#include "ast.h"
int yylex(void);
void yyerror(const char *message);
AstNode *root = NULL;
%}

/* Les valeurs semantiques sont maintenant des pointeurs vers des noeuds. */
%union { AstNode *node; }
%token <node> ID INT
%token LET PRINT ASSIGN SEMI
%token PLUS MINUS STAR SLASH LPAREN RPAREN LBRACE RBRACE INVALID
%type <node> stmt_list stmt expr term factor
%start program

%%

/* Racine et liste d'instructions : actions fournies. */
program:
    stmt_list { root = ast_node(AST_PROGRAM, $1, NULL); }
  ;

stmt_list:
    /* vide */    { $$ = NULL; }
  | stmt_list stmt { $$ = ast_append($1, $2); }
  ;

/* TODO AST-INSTR (exercice 5) : remplacer les trois actions NULL.
   Le modele PRINT est fourni. */
stmt:
    PRINT expr SEMI          { $$ = ast_node(AST_PRINT, $2, NULL); }
  | LET ID ASSIGN expr SEMI { $$ = ast_node(AST_LET, $2, $4); }
  | ID ASSIGN expr SEMI     { $$ = ast_node(AST_ASSIGN, $1, $3); }
  | LBRACE stmt_list RBRACE { $$ = ast_node(AST_BLOCK, $2, NULL); }
  ;

/* TODO AST-EXPR (exercice 5) : remplacer les trois actions NULL
   dans expr et term. Le modele ADD est fourni. */
expr:
    term            { $$ = $1; }
  | expr PLUS term  { $$ = ast_node(AST_ADD, $1, $3); }
  | expr MINUS term { $$ = ast_node(AST_SUB, $1, $3); }
  ;

term:
    factor            { $$ = $1; }
  | term STAR factor  { $$ = ast_node(AST_MUL, $1, $3); }
  | term SLASH factor { $$ = ast_node(AST_DIV, $1, $3); }
  ;

factor:
    INT                { $$ = $1; }
  | ID                 { $$ = $1; }
  | LPAREN expr RPAREN { $$ = $2; }
  /* TODO AST-UNAIRE (exercice 5) : construire un noeud NEG. */
  | MINUS factor       { $$ = ast_node(AST_NEG, $2, NULL); }
  ;

%%

void yyerror(const char *message) {
    fprintf(stderr, "Erreur syntaxique : %s\n", message);
}

int main(void) {
    int status = yyparse();
    if (status == 0) {
        puts("AST du programme :");
        ast_print(root, 0);
        /* Dans un compilateur complet, l'analyse semantique utilise
           root ici, avant la liberation de l'arbre. */
    }
    ast_free_all();
    return status;
}
