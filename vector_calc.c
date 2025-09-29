#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include "vector_calc.h"
#include "y.tab.h"

/* Implementación de las funciones de vectores */
Vector *creaVector(int n) {
    Vector *v = (Vector *)malloc(sizeof(Vector));
    v->n = n;
    v->vec = (n > 0) ? (double *)calloc(n, sizeof(double)) : NULL;
    return v;
}

void imprimeVector(Vector *a) {
    if (!a) return;
    printf("[");
    for (int i = 0; i < a->n; i++) {
        printf("%g%s", a->vec[i], (i == a->n - 1) ? "" : ", ");
    }
    printf("]\n");
}

Vector *copiaVector(Vector *a) {
    if (!a) return NULL;
    Vector *nuevo = creaVector(a->n);
    for (int i = 0; i < a->n; i++) {
        nuevo->vec[i] = a->vec[i];
    }
    return nuevo;
}

Vector *sumaVector(Vector *a, Vector *b) {
    Vector *resultado = creaVector(a->n);
    for (int i = 0; i < a->n; i++) {
        resultado->vec[i] = a->vec[i] + b->vec[i];
    }
    return resultado;
}

Vector *restaVector(Vector *a, Vector *b) {
    Vector *resultado = creaVector(a->n);
    for (int i = 0; i < a->n; i++) {
        resultado->vec[i] = a->vec[i] - b->vec[i];
    }
    return resultado;
}

void liberaVector(Vector *v) {
    if (!v) return;
    free(v->vec);
    free(v);
}

/* Analizador léxico */
int yylex(void) {
    int c;
    while ((c = getchar()) == ' ' || c == '\t');

    if (isdigit(c) || c == '.') {
        ungetc(c, stdin);
        scanf("%lf", &yylval.dval);
        return NUMBER;
    }

    if (islower(c)) {
        yylval.id = c - 'a';
        return VAR;
    }
    
    if (c == EOF) return 0;
    
    return c;
}

void yyerror(const char *s) {
    fprintf(stderr, "%s\n", s);
}

int main() {
    printf("Calculadora de Vectores. Introduce una expresión o Ctrl+C para salir.\n");
    while(1) {
        printf("> ");
        yyparse();
    }
    return 0;
}