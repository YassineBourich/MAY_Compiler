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

AstNode *ast_node(AstKind kind, AstNode *left, AstNode *right) {
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
    node->value = value;
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
    static const char *names[] = {
        "PROGRAM", "BLOCK", "LET", "ASSIGN", "PRINT",
        "ADD", "SUB", "MUL", "DIV", "NEG", "INT", "ID"
    };
    for (; node; node = node->next) {
        printf("%*s%s", depth * 2, "", names[node->kind]);
        if (node->kind == AST_INT) printf(" %ld", node->value);
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
        free(allocations);
        allocations = next;
    }
}
