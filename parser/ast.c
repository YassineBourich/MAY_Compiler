/* Support fourni : aucune modification n'est demandee dans ce fichier. */
#include "ast.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* Registre prive des allocations : il inclut les fragments abandonnes
   en cas d'erreur ou pendant la completion des actions du squelette. */
typedef struct Allocation {
    AstNode node;
    struct Allocation *next;
} Allocation;

static Allocation *allocations = NULL;

static void memory_error(void) {
    fputs("Memoire insuffisante.\n", stderr);
    ast_free_all();
    exit(EXIT_FAILURE);
}

AstNode *ast_node(NodeKind kind, AstNode *left, AstNode *right) {
    Allocation *item = calloc(1, sizeof *item);
    if (!item) memory_error();
    item->next = allocations;
    allocations = item;
    item->node.kind = kind;
    item->node.left = left;
    item->node.right = right;
    return &item->node;
}

AstNode *ast_int(long value) {
    AstNode *node = ast_node(AST_INT, NULL, NULL);
    node->int_value = value;
    return node;
}

AstNode *ast_float(double value) {
    AstNode *node = ast_node(AST_FLOAT, NULL, NULL);
    node->float_value = value;
    return node;
}

AstNode *ast_string(const char* value) {
    AstNode *node = ast_node(AST_STRING, NULL, NULL);
    node->string_value = malloc(strlen(value) + 1);
    if (!node->string_value) memory_error();
    strcpy(node->string_value, value);
    return node;
}

AstNode *ast_char(char value) {
    AstNode *node = ast_node(AST_CHAR, NULL, NULL);
    node->char_value = value;
    return node;
}

AstNode *ast_id(const char *name) {
    AstNode *node = ast_node(AST_ID, NULL, NULL);
    node->name = malloc(strlen(name) + 1);
    if (!node->name) memory_error();
    strcpy(node->name, name);
    return node;
}

AstNode *ast_append(AstNode *list, AstNode *statement) {
    if (!list) return statement;
    AstNode *last = list;
    while (last->next) last = last->next;
    last->next = statement;
    return list;
}

void ast_print(const AstNode *node, int depth) {
    const char* node_names[] = {
        "ADDITION",
        "AND",
        "AND_ASSIGN",
        "ARGUMENT",
        "ARITHMETIC_NEGATION",
        "ARRAY_ACCESS",
        "ASSIGN",
        "ATTRIBUTE_ACCESS",
        "BITWISE_AND",
        "BITWISE_NEGATION",
        "BITWISE_OR",
        "BITWISE_XOR",
        "BLOCK",
        "BOOLEAN_NEGATION",
        "BREAK",
        "CLEAR_ASSIGN",
        "CONST_INIT_IMPLICIT",
        "CONST_INIT_TYPED",
        "CONTINUE",
        "DECLARATION",
        "DECREMENT",
        "DIV",
        "DO_WHILE",
        "ELSE_BLOCK",
        "EQ",
        "EXPRESSION",
        "FOR",
        "FOR_ARGS",
        "FOR_TRIPLET",
        "FUNC_CALL",
        "FUNC_DECL",
        "FUNC_HEADER",
        "FUNC_NAME_PARAMS",
        "GE",
        "GT",
        "IF_STATEMENT",
        "INCREMENT",
        "LE",
        "LT",
        "MINUS_ASSIGN",
        "MOD",
        "MOD_ASSIGN",
        "MUL",
        "NE",
        "OR",
        "OR_ASSIGN",
        "PARAM",
        "PLUS_ASSIGN",
        "PROGRAM",
        "RAW_IF",
        "RETURN",
        "SHIFT_LIFT_LOGICAL",
        "SHIFT_RIGHT_ARITHMETIC",
        "SHIFT_RIGHT_LOGICAL",
        "SLASH_ASSIGN",
        "SLL_ASSIGN",
        "SRA_ASSIGN",
        "SRL_ASSIGN",
        "STAR_ASSIGN",
        "STRUCT_DECLARATION",
        "STRUCT_INITIALIZATION",
        "SUBTRACTION",
        "SWITCH",
        "SWITCH_CASE",
        "SWITCH_DEFAULT",
        "VAR_INIT_IMPLICIT",
        "VAR_INIT_TYPED",
        "VARIADIC_PARAM",
        "WHILE",
        "XOR",
        "XOR_ASSIGN"
    };
    for (; node; node = node->next) {
        printf("%*s%s", depth * 2, "", node_names[node->kind]);
        if (node->kind == AST_INT) printf(" %ld", node->int_value);
        if (node->kind == AST_FLOAT) printf(" %f", node->float_value);
        if (node->kind == AST_STRING) printf(" \"%s\"", node->string_value);
        if (node->kind == AST_CHAR) printf(" '%c'", node->char_value);
        if (node->kind == AST_ID) printf(" %s", node->name);
        putchar('\n');
        ast_print(node->left, depth + 1);
        ast_print(node->right, depth + 1);
    }
}

void ast_free_all(void) {
    while (allocations) {
        Allocation *next = allocations->next;
        free(allocations->node.name);
        free(allocations->node.string_value);
        free(allocations);
        allocations = next;
    }
}
