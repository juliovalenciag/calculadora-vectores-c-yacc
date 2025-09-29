/* =================================================================
   vector_calc.y CORREGIDO
   ================================================================= */
%{
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "vector_calc.h"

int yylex(void);
void yyerror(const char *s);

/* Memoria para variables a..z */
static Vector *mem[26] = {0};

/* -------- helpers para construir vectores desde la gramática -------- */
typedef struct NumBuf {
  int n, cap;
  double *a;
} NumBuf;

static NumBuf* nb_new(void) {
  NumBuf* b = (NumBuf*)malloc(sizeof(NumBuf));
  b->n = 0; b->cap = 4;
  b->a = (double*)malloc(sizeof(double)*b->cap);
  return b;
}
static void nb_push(NumBuf* b, double x) {
  if (b->n >= b->cap) {
    b->cap *= 2;
    b->a = (double*)realloc(b->a, sizeof(double)*b->cap);
  }
  b->a[b->n++] = x;
}
static Vector* nb_to_vec(NumBuf* b) {
  Vector* v = creaVector(b->n);
  for (int i=0; i<b->n; i++) v->vec[i] = b->a[i];
  free(b->a); free(b);
  return v;
}

/* Multiplicación escalar */
static Vector* scalar_mul(double s, Vector* v) {
  Vector* r = creaVector(v->n);
  for (int i=0; i<v->n; i++) r->vec[i] = s * v->vec[i];
  return r;
}

/* Verificación de dimensiones para operaciones */
static int ensure_same_size(Vector* a, Vector* b) {
  if (a->n != b->n) {
    yyerror("Error: dimensiones de vectores incompatibles");
    return -1;
  }
  return 0;
}
%}

/* -------- Unión de valores semánticos -------- */
%union {
  int     id;      /* Para VAR (índice 0-25) */
  double  dval;    /* Para escalares y NÚMEROS */
  Vector* vval;    /* Para vectores */
  void* buf;     /* Para el buffer temporal (NumBuf*) */
}

/* -------- Tokens y Tipos (LA CORRECCIÓN CLAVE ESTÁ AQUÍ) -------- */
%token <dval> NUMBER   /* CAMBIO: NUMBER ahora es de tipo double */
%token <id>   VAR

%type <vval> vexpr vector
%type <dval> scalar num
%type <buf>  numlist

/* -------- Precedencia de operadores -------- */
%left '+' '-'
%left '*'
%right UMINUS /* Operador unario negativo (ej: -5) */

%%

/* La gramática puede ser una secuencia de líneas */
input
  : /* vacío */
  | input line
  ;

line
  : vexpr '\n'        { imprimeVector($1); liberaVector($1); }
  | scalar '\n'       { printf("%g\n", $1); }
  | VAR '=' vexpr '\n'  { 
                        if (mem[$1]) liberaVector(mem[$1]);
                        mem[$1] = $3; /* No se copia, se "roba" la referencia */
                      }
  | '\n'              { /* Línea vacía */ }
  | error '\n'        { yyerrok; /* Se recupera del error */ }
  ;

/* --- Expresiones de Vectores --- */
vexpr
  : vector
  | VAR               { 
                        if (!mem[$1]) {
                          yyerror("Error: variable no inicializada");
                          $$ = creaVector(0);
                        } else {
                          $$ = copiaVector(mem[$1]); 
                        }
                      }
  | vexpr '+' vexpr   {
                        if (ensure_same_size($1, $3) == 0) { $$ = sumaVector($1, $3); }
                        else { $$ = creaVector(0); }
                        liberaVector($1); liberaVector($3);
                      }
  | vexpr '-' vexpr   {
                        if (ensure_same_size($1, $3) == 0) { $$ = restaVector($1, $3); }
                        else { $$ = creaVector(0); }
                        liberaVector($1); liberaVector($3);
                      }
  | scalar '*' vexpr  { $$ = scalar_mul($1, $3); liberaVector($3); }
  | vexpr '*' scalar  { $$ = scalar_mul($3, $1); liberaVector($1); }
  | '(' vexpr ')'     { $$ = $2; /* Pasa el vector a través de los paréntesis */ }
  ;

/* --- Expresiones Escalares --- */
scalar
  : num
  | '-' scalar %prec UMINUS { $$ = -$2; }
  | '|' vexpr '|'      { 
                         double acc = 0.0;
                         for (int i=0; i<$2->n; i++) acc += $2->vec[i] * $2->vec[i];
                         $$ = sqrt(acc);
                         liberaVector($2);
                       }
  | '(' scalar ')'    { $$ = $2; }
  ;

/* --- Definición de Vectores --- */
vector
  : '[' ']'           { $$ = creaVector(0); }
  | '[' numlist ']'   { $$ = nb_to_vec((NumBuf*)$2); }
  ;

/* Números (pueden tener signo) dentro de la definición de un vector */
num
  : NUMBER
  | '-' NUMBER        { $$ = -$2; }
  ;

opt_comma: /* vacio */ | ',' ;

/* Lista de números: puede ser '1,2 3' o '1 2 3' o '1,2,3' */
numlist
  : num                        { NumBuf* b = nb_new(); nb_push(b, $1); $$ = (void*)b; }
  | numlist opt_comma num      { NumBuf* b = (NumBuf*)$1; nb_push(b, $3); $$ = (void*)b; }
  ;
%%
/* El código después de %% se copia al final del archivo y.tab.c */
/* No es necesario incluir vector_calc.c aquí si lo enlazas correctamente */