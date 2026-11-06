#pragma once

typedef enum {
    AST_ADDITION,
    AST_AND,
    AST_AND_ASSIGN,
    AST_ARGUMENT,
    AST_ARITHMETIC_NEGATION,
    AST_ARRAY_ACCESS,
    AST_ASSIGN,
    AST_ATTRIBUTE_ACCESS,
    AST_BITWISE_AND,
    AST_BITWISE_NEGATION,
    AST_BITWISE_OR,
    AST_BITWISE_XOR,
    AST_BLOCK,
    AST_BOOLEAN_NEGATION,
    AST_BREAK,
    AST_CHAR,
    AST_CLEAR_ASSIGN,
    AST_CONST_INIT_IMPLICIT,
    AST_CONST_INIT_TYPED,
    AST_CONTINUE,
    AST_DECLARATION,
    AST_DECREMENT,
    AST_DIV,
    AST_DO_WHILE,
    AST_ELSE_BLOCK,
    AST_EQ,
    AST_EXPRESSION,
    AST_FLOAT,
    AST_FOR,
    AST_FOR_ARGS,
    AST_FOR_TRIPLET,
    AST_FUNC_CALL,
    AST_FUNC_DECL,
    AST_FUNC_HEADER,
    AST_FUNC_NAME_PARAMS,
    AST_GE,
    AST_GT,
    AST_ID,
    AST_IF_STATEMENT,
    AST_INCREMENT,
    AST_INT,
    AST_LE,
    AST_LT,
    AST_MINUS_ASSIGN,
    AST_MOD,
    AST_MOD_ASSIGN,
    AST_MUL,
    AST_NE,
    AST_OR,
    AST_OR_ASSIGN,
    AST_PARAM,
    AST_PLUS_ASSIGN,
    AST_PROGRAM,
    AST_RAW_IF,
    AST_RETURN,
    AST_SHIFT_LIFT_LOGICAL,
    AST_SHIFT_RIGHT_ARITHMETIC,
    AST_SHIFT_RIGHT_LOGICAL,
    AST_SLASH_ASSIGN,
    AST_SLL_ASSIGN,
    AST_SRA_ASSIGN,
    AST_SRL_ASSIGN,
    AST_STAR_ASSIGN,
    AST_STRING,
    AST_STRUCT_DECLARATION,
    AST_STRUCT_INITIALIZATION,
    AST_SUBTRACTION,
    AST_SWITCH,
    AST_SWITCH_CASE,
    AST_SWITCH_DEFAULT,
    AST_VAR_INIT_IMPLICIT,
    AST_VAR_INIT_TYPED,
    AST_VARIADIC_PARAM,
    AST_WHILE,
    AST_XOR,
    AST_XOR_ASSIGN
} NodeKind;

typedef struct AstNode {
    NodeKind kind;
    long int_value;
    float float_value;
    char* string_value;
    char char_value;
    char *name;
    struct AstNode *left, *right;
    struct AstNode *next;
} AstNode;

AstNode *ast_int(long value);
AstNode *ast_float(double value);
AstNode *ast_string(const char* value);
AstNode *ast_char(char value);
AstNode *ast_id(const char *name);

AstNode *ast_node(NodeKind kind, AstNode *left, AstNode *right);
AstNode *ast_append(AstNode *list, AstNode *statement);
void ast_print(const AstNode *node, int depth);
void ast_free_all(void);
