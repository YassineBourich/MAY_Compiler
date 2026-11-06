%{
#include <stdio.h>
#include "ast.h"
int yylex(void);
void yyerror(const char *message);
int errors = 0;
AstNode *root = NULL;
%}

/* Les valeurs semantiques sont maintenant des pointeurs vers des noeuds. */
%union { AstNode *node; }
%token <node> ID INT FLOAT STRING CHAR RAW_STRING
%token BREAK CASE CONST CONTINUE DEFAULT DO ELSE FOR IF PROGRAM RETURN STRUCT SWITCH VAR WHILE
%token AND_ASSIGN OR_ASSIGN XOR_ASSIGN AND OR XOR NOT
%token BIT_CLEAR SLL SRL SRA SLL_ASSIGN SRL_ASSIGN SRA_ASSIGN CLEAR_ASSIGN BITWISE_AND BITWISE_OR BITWISE_XOR BITWISE_NOT
%token EQ NE LE GE ASSIGN LT GT
%token INCREMENT DECREMENT PLUS_ASSIGN MINUS_ASSIGN STAR_ASSIGN SLASH_ASSIGN MOD_ASSIGN PLUS MINUS STAR SLASH MOD
%token LPAREN RPAREN LBRACKET RBRACKET LBRACE RBRACE
%token COMMA ELLIPSIS DOT COLON SEMI
%token BAD_CHAR

%type <node> program stmt_list stmt
%type <node> decl_stmt init_stmt initialization var_init const_init
%type <node> assign_stmt assign_instruction struct_decl fields_decl_list
%type <node> func_decl params_list param_list_items variadic_params
%type <node> func_call_stmt func_call args_list arg_list_items
%type <node> if_stmt raw_if_stmt else_if_stmt_list else_stmt
%type <node> switch_stmt switch_cases switch_cases_list default_case
%type <node> iter_stmt for_loop for_loop_arguments iterator_init stopping_cond iterator_update while_loop do_while_loop
%type <node> return_stmt expr_stmt block_stmt
%type <node> expr term_5 term_4 term_3 term_2 term_1 term_0
%type <node> attribute_access condition struct_init array_init values_list

%start program

%%

/* Racine et liste d'instructions : actions fournies. */
program: 
	  PROGRAM ID SEMI stmt_list		{ root = ast_node(AST_PROGRAM, $4, NULL); }
	;

stmt_list: 
	  %empty 						{ $$ = NULL; }
	| stmt_list stmt				{ $$ = ast_append($1, $2); }
	;

stmt:
	  decl_stmt					{ $$ = $1; }
	| init_stmt					{ $$ = $1; }
    | assign_stmt				{ $$ = $1; }
    | struct_decl				{ $$ = $1; }
    | func_decl					{ $$ = $1; }
	| func_call_stmt			{ $$ = $1; }
    | if_stmt					{ $$ = $1; }
    | switch_stmt				{ $$ = $1; }
    | iter_stmt					{ $$ = $1; }
    | return_stmt				{ $$ = $1; }
    | expr_stmt					{ $$ = $1; }
    | block_stmt				{ $$ = $1; }
	| BREAK SEMI				{ $$ = ast_node(AST_BREAK, NULL, NULL); }
	| CONTINUE SEMI				{ $$ = ast_node(AST_CONTINUE, NULL, NULL); }
    | SEMI						{ $$ = NULL; }
	;

// _____________________________
decl_stmt:
	  ID ID SEMI				{ $$ = ast_node(AST_DECLARATION, $1, $2); }
	;

// _____________________________
init_stmt:
	  initialization SEMI		{ $$ = $1; }
	;

initialization:
	  var_init					{ $$ = $1; }
	| const_init				{ $$ = $1; }
	;

var_init:
	  ID ID ASSIGN expr			{ $$ = ast_node(AST_VAR_INIT_TYPED, ast_node(AST_DECLARATION, $1, $2), $4); }
	| VAR ID ASSIGN expr		{ $$ = ast_node(AST_VAR_INIT_IMPLICIT, $2, $4); }
	;

const_init:
	  CONST ID ID ASSIGN expr	{ $$ = ast_node(AST_CONST_INIT_TYPED, ast_node(AST_DECLARATION, $2, $3), $5); }
	| CONST VAR ID ASSIGN expr	{ $$ = ast_node(AST_CONST_INIT_IMPLICIT, $3, $5); }
	;

// _____________________________
assign_stmt:
	  assign_instruction SEMI	{ $$ = $1; }
	;

assign_instruction:
	  ID ASSIGN expr			{ $$ = ast_node(AST_ASSIGN, $1, $3); }

	| ID PLUS_ASSIGN expr		{ $$ = ast_node(AST_PLUS_ASSIGN, $1, $3); }
	| ID MINUS_ASSIGN expr		{ $$ = ast_node(AST_MINUS_ASSIGN, $1, $3); }
	| ID STAR_ASSIGN expr		{ $$ = ast_node(AST_STAR_ASSIGN, $1, $3); }
	| ID SLASH_ASSIGN expr		{ $$ = ast_node(AST_SLASH_ASSIGN, $1, $3); }
	| ID MOD_ASSIGN expr		{ $$ = ast_node(AST_MOD_ASSIGN, $1, $3); }

	| ID AND_ASSIGN expr		{ $$ = ast_node(AST_AND_ASSIGN, $1, $3); }
	| ID OR_ASSIGN expr			{ $$ = ast_node(AST_OR_ASSIGN, $1, $3); }
	| ID XOR_ASSIGN expr		{ $$ = ast_node(AST_XOR_ASSIGN, $1, $3); }

	| ID SLL_ASSIGN expr		{ $$ = ast_node(AST_SLL_ASSIGN, $1, $3); }
	| ID SRL_ASSIGN expr		{ $$ = ast_node(AST_SRL_ASSIGN, $1, $3); }
	| ID SRA_ASSIGN expr		{ $$ = ast_node(AST_SRA_ASSIGN, $1, $3); }
	| ID CLEAR_ASSIGN expr		{ $$ = ast_node(AST_CLEAR_ASSIGN, $1, $3); }

	| ID INCREMENT				{ $$ = ast_node(AST_INCREMENT, $1, NULL); }
	| ID DECREMENT				{ $$ = ast_node(AST_DECREMENT, $1, NULL); }
	;

// _____________________________
struct_decl:
	  STRUCT ID LBRACE fields_decl_list RBRACE SEMI		{ $$ = ast_node(AST_STRUCT_DECLARATION, $2, $4); }
	;

fields_decl_list:
	  %empty											{ $$ = NULL; }
	| fields_decl_list decl_stmt						{ $$ = ast_append($1, $2); }
	;

// _____________________________
func_decl:
	  ID ID LPAREN params_list RPAREN block_stmt	{ $$ = ast_node(AST_FUNC_DECL, ast_node(AST_FUNC_HEADER, $1, ast_node(AST_FUNC_NAME_PARAMS, $2, $4)), $6); }
	;

params_list:
      %empty										{ $$ = NULL; }
    | param_list_items								{ $$ = $1; }
	| variadic_params								{ $$ = $1; }
    ;

param_list_items:
	  ID ID											{ $$ = ast_node(AST_PARAM, $1, $2); }
	| param_list_items COMMA ID ID					{ $$ = ast_append($1, ast_node(AST_PARAM, $3, $4)); }
    ;

variadic_params:
	  ID ID ELLIPSIS								{ $$ = ast_node(AST_VARIADIC_PARAM, $1, $2); }
	;

// _____________________________
func_call_stmt:
	  func_call SEMI					{ $$ = $1; }
	;

func_call:
	  ID LPAREN args_list RPAREN		{ $$ = ast_node(AST_FUNC_CALL, $1, $3); }
	;

args_list:
      %empty							{ $$ = NULL; }
    | arg_list_items					{ $$ = $1; }
    ;

arg_list_items:
	  expr								{ $$ = ast_node(AST_ARGUMENT, $1, NULL); }
    | arg_list_items COMMA expr			{ $$ = ast_append($1, ast_node(AST_ARGUMENT, $3, NULL)); }
    ;

// _____________________________
if_stmt:
	  raw_if_stmt else_if_stmt_list else_stmt				{ $$ = ast_node(AST_IF_STATEMENT, $1, ast_append_last($2, $3)); }
	;

raw_if_stmt:
	  IF LPAREN condition RPAREN block_stmt					{ $$ = ast_node(AST_RAW_IF, $3, $5); }
	;

else_if_stmt_list:
	  %empty												{ $$ = NULL; }
	| else_if_stmt_list ELSE raw_if_stmt					{ $$ = ast_append($1, $3); }
	;

else_stmt:
	  %empty												{ $$ = NULL; }
	| ELSE block_stmt										{ $$ = ast_node(AST_ELSE_BLOCK, $2, NULL); }
	;

// _____________________________
switch_stmt:
	  SWITCH LPAREN ID RPAREN LBRACE switch_cases RBRACE	{ $$ = ast_node(AST_SWITCH, $3, $6); }
	;

switch_cases:
	  switch_cases_list default_case						{ $$ = ast_append_last($1, $2); }
	;
	
switch_cases_list:
	  %empty												{ $$ = NULL; }
	| switch_cases_list CASE expr COLON stmt_list			{ $$ = ast_append($1, ast_node(AST_SWITCH_CASE, $3, $5)); }
	;

default_case:
	  %empty												{ $$ = NULL; }
	| DEFAULT COLON stmt_list								{ $$ = ast_node(AST_SWITCH_DEFAULT, $3, NULL); }
	;

// _____________________________
iter_stmt:
	  for_loop						{ $$ = $1; }
	| while_loop					{ $$ = $1; }
	| do_while_loop					{ $$ = $1; }
	;

for_loop:
	  FOR LPAREN for_loop_arguments RPAREN block_stmt	{ $$ = ast_node(AST_FOR, $3, $5); }
	;

for_loop_arguments:
	  iterator_init SEMI stopping_cond SEMI iterator_update		{ $$ = ast_node(AST_FOR_ARGS, ast_node(AST_FOR_TRIPLET, $1, $3), $5); }
	;

iterator_init:
	  %empty											{ $$ = NULL; }
	| var_init											{ $$ = $1; }
	;

stopping_cond:
	  %empty											{ $$ = NULL; }
	| condition											{ $$ = $1; }
	;

iterator_update:
	  %empty											{ $$ = NULL; }
	| assign_instruction								{ $$ = $1; }
	;


while_loop:
	  WHILE LPAREN condition RPAREN block_stmt			{ $$ = ast_node(AST_WHILE, $3, $5); }
	;


do_while_loop:
	  DO block_stmt WHILE LPAREN condition RPAREN SEMI	{ $$ = ast_node(AST_DO_WHILE, $2, $5); }
	;

// _____________________________
return_stmt:
	  RETURN expr SEMI				{ $$ = ast_node(AST_RETURN, $2, NULL); }
	;

// _____________________________
expr_stmt:
	  expr SEMI						{ $$ = ast_node(AST_EXPRESSION, $1, NULL); }
	;

// _____________________________
block_stmt:
	  LBRACE stmt_list RBRACE		{ $$ = ast_node(AST_BLOCK, $2, NULL); }
	;

// _____________________________
expr:
	  term_5						{ $$ = $1; }
	| expr OR term_5				{ $$ = ast_node(AST_OR, $1, $3); }
	;

term_5:
	  term_4						{ $$ = $1; }
	| term_5 XOR term_4				{ $$ = ast_node(AST_XOR, $1, $3); }
	;

term_4:
	  term_3						{ $$ = $1; }
	| term_4 AND term_3				{ $$ = ast_node(AST_AND, $1, $3); }
	;

term_3:
	  term_2						{ $$ = $1; }
	| term_3 EQ term_2				{ $$ = ast_node(AST_EQ, $1, $3); }
	| term_3 NE term_2				{ $$ = ast_node(AST_NE, $1, $3); }
	| term_3 LE term_2				{ $$ = ast_node(AST_LE, $1, $3); }
	| term_3 GE term_2				{ $$ = ast_node(AST_GE, $1, $3); }
	| term_3 LT term_2				{ $$ = ast_node(AST_LT, $1, $3); }
	| term_3 GT term_2				{ $$ = ast_node(AST_GT, $1, $3); }
	;

term_2:
	  term_1						{ $$ = $1; }
	| term_2 PLUS term_1			{ $$ = ast_node(AST_ADDITION, $1, $3); }
	| term_2 MINUS term_1			{ $$ = ast_node(AST_SUBTRACTION, $1, $3); }
	| term_2 BITWISE_OR term_1		{ $$ = ast_node(AST_BITWISE_OR, $1, $3); }
	| term_2 BITWISE_XOR term_1		{ $$ = ast_node(AST_BITWISE_XOR, $1, $3); }
	;

term_1:
	  term_0						{ $$ = $1; }
	| term_1 STAR term_0			{ $$ = ast_node(AST_MUL, $1, $3); }
	| term_1 SLASH term_0			{ $$ = ast_node(AST_DIV, $1, $3); }
	| term_1 MOD term_0				{ $$ = ast_node(AST_MOD, $1, $3); }
	| term_1 BIT_CLEAR term_0		{ $$ = ast_node(AST_BIT_CLEAR, $1, $3); }
	| term_1 BITWISE_AND term_0		{ $$ = ast_node(AST_BITWISE_AND, $1, $3); }
	| term_1 SLL term_0				{ $$ = ast_node(AST_SHIFT_LIFT_LOGICAL, $1, $3); }
	| term_1 SRL term_0				{ $$ = ast_node(AST_SHIFT_RIGHT_LOGICAL, $1, $3); }
	| term_1 SRA term_0				{ $$ = ast_node(AST_SHIFT_RIGHT_ARITHMETIC, $1, $3); }
	;

term_0:
	  ID							{ $$ = $1; }
	| INT							{ $$ = $1; }
	| FLOAT							{ $$ = $1; }
	| STRING						{ $$ = $1; }
	| RAW_STRING					{ $$ = $1; }
	| CHAR							{ $$ = $1; }

	| MINUS term_0					{ $$ = ast_node(AST_ARITHMETIC_NEGATION, $2, NULL); }
	| NOT term_0					{ $$ = ast_node(AST_BOOLEAN_NEGATION, $2, NULL); }
	| BITWISE_NOT term_0			{ $$ = ast_node(AST_BITWISE_NEGATION, $2, NULL); }

	| LPAREN expr RPAREN			{ $$ = $2; }

	| term_0 LBRACKET expr RBRACKET	{ $$ = ast_node(AST_ARRAY_ACCESS, $1, $3); }
	| func_call						{ $$ = $1; }
	| attribute_access				{ $$ = $1; }
	| struct_init					{ $$ = $1; }
	| array_init					{ $$ = $1; }
	;

attribute_access:
	  term_0 DOT ID						{ $$ = ast_node(AST_ATTRIBUTE_ACCESS, $1, $3); }
	;

struct_init:
	  ID LBRACE values_list RBRACE		{ $$ = ast_node(AST_STRUCT_INITIALIZATION, $1, $3); }
	;

array_init:
	  LBRACKET values_list RBRACKET		{ $$ = ast_node(AST_ARRAY_INITIALIZATION, $2, NULL); }

values_list:
	  %empty						{ $$ = NULL; }
	| expr							{ $$ = $1; }
	| values_list COMMA expr		{ $$ = ast_append($1, $3); }
	;


condition:
	  expr							{ $$ = $1; }
	;

%%

void yyerror(const char *message) {
	++errors;
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
