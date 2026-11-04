/* A Bison parser, made by GNU Bison 3.8.2.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015, 2018-2021 Free Software Foundation,
   Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <https://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* DO NOT RELY ON FEATURES THAT ARE NOT DOCUMENTED in the manual,
   especially those whose name start with YY_ or yy_.  They are
   private implementation details that can be changed or removed.  */

#ifndef YY_YY_MAY_PARSER_TAB_H_INCLUDED
# define YY_YY_MAY_PARSER_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif
/* "%code requires" blocks.  */
#line 10 "may_parser.y"

    #include "ast.h"

#line 53 "may_parser.tab.h"

/* Token kinds.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    YYEMPTY = -2,
    YYEOF = 0,                     /* "end of file"  */
    YYerror = 256,                 /* error  */
    YYUNDEF = 257,                 /* "invalid token"  */
    ID = 258,                      /* ID  */
    INT = 259,                     /* INT  */
    FLOAT = 260,                   /* FLOAT  */
    IMAGINARY = 261,               /* IMAGINARY  */
    STRING = 262,                  /* STRING  */
    RAW_STRING = 263,              /* RAW_STRING  */
    BREAK = 264,                   /* BREAK  */
    CASE = 265,                    /* CASE  */
    CHAN = 266,                    /* CHAN  */
    CONST = 267,                   /* CONST  */
    CONTINUE = 268,                /* CONTINUE  */
    DEFAULT = 269,                 /* DEFAULT  */
    DO = 270,                      /* DO  */
    ELSE = 271,                    /* ELSE  */
    FOR = 272,                     /* FOR  */
    IF = 273,                      /* IF  */
    IMPORT = 274,                  /* IMPORT  */
    PROGRAM = 275,                 /* PROGRAM  */
    RETURN = 276,                  /* RETURN  */
    STRUCT = 277,                  /* STRUCT  */
    SWITCH = 278,                  /* SWITCH  */
    TYPE = 279,                    /* TYPE  */
    VAR = 280,                     /* VAR  */
    WHILE = 281,                   /* WHILE  */
    AND = 282,                     /* AND  */
    OR = 283,                      /* OR  */
    XOR = 284,                     /* XOR  */
    NOT = 285,                     /* NOT  */
    BITWISE_AND = 286,             /* BITWISE_AND  */
    BITWISE_OR = 287,              /* BITWISE_OR  */
    BITWISE_XOR = 288,             /* BITWISE_XOR  */
    BITWISE_NOT = 289,             /* BITWISE_NOT  */
    EQ = 290,                      /* EQ  */
    NE = 291,                      /* NE  */
    LE = 292,                      /* LE  */
    GE = 293,                      /* GE  */
    ASSIGN = 294,                  /* ASSIGN  */
    LT = 295,                      /* LT  */
    GT = 296,                      /* GT  */
    DOUBLE_PLUS = 297,             /* DOUBLE_PLUS  */
    DOUBLE_MINUS = 298,            /* DOUBLE_MINUS  */
    PLUS_ASSIGN = 299,             /* PLUS_ASSIGN  */
    MINUS_ASSIGN = 300,            /* MINUS_ASSIGN  */
    STAR_ASSIGN = 301,             /* STAR_ASSIGN  */
    SLASH_ASSIGN = 302,            /* SLASH_ASSIGN  */
    PLUS = 303,                    /* PLUS  */
    MINUS = 304,                   /* MINUS  */
    STAR = 305,                    /* STAR  */
    SLASH = 306,                   /* SLASH  */
    LPAREN = 307,                  /* LPAREN  */
    RPAREN = 308,                  /* RPAREN  */
    LBRACE = 309,                  /* LBRACE  */
    RBRACE = 310,                  /* RBRACE  */
    SEMI = 311                     /* SEMI  */
  };
  typedef enum yytokentype yytoken_kind_t;
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
union YYSTYPE
{
#line 15 "may_parser.y"
 AstNode *node; 

#line 129 "may_parser.tab.h"

};
typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;


int yyparse (void);


#endif /* !YY_YY_MAY_PARSER_TAB_H_INCLUDED  */
