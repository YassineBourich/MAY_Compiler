%{
#include <stdio.h>
#include "ast.h"
int yylex(void);
void yyerror(const char *message);
AstNode *root = NULL;
%}

/* Les valeurs semantiques sont maintenant des pointeurs vers des noeuds. */
%union { AstNode *node; }
%token <node> ID INT FLOAT IMAGINARY STRING RUNE RAW_STRING
%token BREAK CASE CONST CONTINUE DEFAULT DO ELSE FOR IF IMPORT PROGRAM RETURN STRUCT SWITCH VAR WHILE
%token AND_ASSIGN OR_ASSIGN XOR_ASSIGN AND OR XOR NOT
%token BIT_CLEAR SLL SRL SRA SLL_ASSIGN SRL_ASSIGN SRA_ASSIGN CLEAR_ASSIGN BITWISE_AND BITWISE_OR BITWISE_XOR BITWISE_NOT
%token EQ NE LE GE ASSIGN LT GT
%token INCREMENT DECREMENT PLUS_ASSIGN MINUS_ASSIGN STAR_ASSIGN SLASH_ASSIGN MOD_ASSIGN PLUS MINUS STAR SLASH MOD
%token LPAREN RPAREN LBRACKET RBRACKET LBRACE RBRACE
%token COMMA ELLIPSIS DOT COLON SEMI

// %type <node> 
%start program

%%

/* Racine et liste d'instructions : actions fournies. */
program: 
	  PROGRAM ID SEMI stmt_list
	;

stmt_list: 
	  %empty 
	| stmt_list stmt
	;

stmt:
	  decl_stmt
	| init_stmt
    | assign_stmt
    | struct_decl
    | func_decl
	| func_call_stmt
    | if_stmt
    | switch_stmt
    | iter_stmt
    | return_stmt
    | expr_stmt
    | block_stmt
	| BREAK SEMI
	| CONTINUE SEMI
    | SEMI
	;

// _____________________________
decl_stmt:
	  ID ID SEMI
	;

// _____________________________
init_stmt:
	  initialization SEMI
	;

initialization:
	  var_init
	| const_init
	;

var_init:
	  ID ID ASSIGN expr
	| VAR ID ASSIGN expr
	;

const_init:
	  CONST ID ID ASSIGN expr
	| CONST VAR ID ASSIGN expr
	;

// _____________________________
assign_stmt:
	  assign_instruction SEMI
	;

assign_instruction:
	  ID ASSIGN expr

	| ID PLUS_ASSIGN expr
	| ID MINUS_ASSIGN expr
	| ID STAR_ASSIGN expr
	| ID SLASH_ASSIGN expr
	| ID MOD_ASSIGN expr

	| ID AND_ASSIGN expr
	| ID OR_ASSIGN expr
	| ID XOR_ASSIGN expr

	| ID SLL_ASSIGN expr
	| ID SRL_ASSIGN expr
	| ID SRA_ASSIGN expr
	| ID CLEAR_ASSIGN expr

	| ID INCREMENT
	| ID DECREMENT
	;

// _____________________________
struct_decl:
	  STRUCT ID LBRACE fields_decl_list RBRACE SEMI
	;

fields_decl_list:
	  %empty
	| fields_decl_list decl_stmt
	;

// _____________________________
func_decl:
	  ID ID LPAREN params_list RPAREN block_stmt
	;

params_list:
      %empty
    | param_list_items
	| any_params
    ;

param_list_items:
	  ID ID
	| param_list_items COMMA ID ID
    ;

any_params:
	  ID ID ELLIPSIS
	;

// _____________________________
func_call_stmt:
	  func_call SEMI
	;

func_call:
	  ID LPAREN args_list RPAREN
	;

args_list:
      %empty
    | arg_list_items
    ;

arg_list_items:
	  expr
    | arg_list_items COMMA expr
    ;

// _____________________________
if_stmt:
	  raw_if_stmt else_if_stmt_list else_stmt
	;

raw_if_stmt:
	  IF LPAREN condition RPAREN block_stmt
	;

else_if_stmt_list:
	  %empty
	| else_if_stmt_list ELSE raw_if_stmt
	;

else_stmt:
	  %empty
	| ELSE block_stmt
	;

// _____________________________
switch_stmt:
	  SWITCH LPAREN ID RPAREN LBRACE switch_cases RBRACE
	;

switch_cases:
	  switch_cases_list default_case
	;
	
switch_cases_list:
	  %empty
	| switch_cases_list CASE expr COLON stmt_list
	;

default_case:
	  %empty
	| DEFAULT COLON stmt_list
	;

// _____________________________
iter_stmt:
	  for_loop
	| while_loop
	| do_while_loop
	;

for_loop:
	  FOR LPAREN for_loop_arguments RPAREN block_stmt
	;

for_loop_arguments:
	  iterator_init SEMI stopping_cond SEMI iterator_update
	;

iterator_init:
	  %empty
	| var_init
	;

stopping_cond:
	  %empty
	| condition
	;

iterator_update:
	  %empty
	| assign_instruction
	;


while_loop:
	  WHILE LPAREN condition RPAREN block_stmt
	;


do_while_loop:
	  DO block_stmt WHILE LPAREN condition RPAREN SEMI
	;

// _____________________________
return_stmt:
	  RETURN expr SEMI
	;

// _____________________________
expr_stmt:
	  expr SEMI
	;

// _____________________________
block_stmt:
	  LBRACE stmt_list RBRACE
	;

// _____________________________
expr:
	  term_5
	| expr OR term_5
	;

term_5:
	  term_4
	| term_5 XOR term_4
	;

term_4:
	  term_3
	| term_4 AND term_3
	;

term_3:
	  term_2
	| term_3 EQ term_2
	| term_3 NE term_2
	| term_3 LE term_2
	| term_3 GE term_2
	| term_3 LT term_2
	| term_3 GT term_2
	;

term_2:
	  term_1
	| term_2 PLUS term_1
	| term_2 MINUS term_1
	| term_2 BITWISE_OR term_1
	| term_2 BITWISE_XOR term_1
	;

term_1:
	  term_0
	| term_1 STAR term_0
	| term_1 SLASH term_0
	| term_1 MOD term_0
	| term_1 BIT_CLEAR term_0
	| term_1 BITWISE_AND term_0
	| term_1 SLL term_0
	| term_1 SRL term_0
	| term_1 SRA term_0
	;

term_0:
	  ID
	| INT
	| FLOAT
	| IMAGINARY
	| STRING
	| RAW_STRING
	| RUNE

	| MINUS term_0
	| NOT term_0
	| BITWISE_NOT term_0

	| LPAREN expr RPAREN

	| term_0 LBRACKET expr RBRACKET
	| func_call
	| attribute_access
	;

attribute_access:
	  term_0 DOT ID
	;

condition:
	  expr
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
