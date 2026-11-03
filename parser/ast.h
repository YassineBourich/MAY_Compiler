#pragma once

typedef enum {
    AST_PROGRAM, AST_BLOCK, AST_LET, AST_ASSIGN, AST_PRINT,
    AST_ADD, AST_SUB, AST_MUL, AST_DIV, AST_NEG, AST_INT, AST_ID
} AstKind;

typedef struct AstNode {
    AstKind kind;
    long value;
    char *name;
    struct AstNode *left, *right;
    struct AstNode *next;
} AstNode;

AstNode *ast_int(long value);
AstNode *ast_id(const char *name);
AstNode *ast_node(AstKind kind, AstNode *left, AstNode *right);
AstNode *ast_append(AstNode *list, AstNode *statement);
void ast_print(const AstNode *node, int depth);
void ast_free_all(void);
