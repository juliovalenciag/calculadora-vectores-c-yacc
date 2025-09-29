#ifndef VECTOR_CALC_H
#define VECTOR_CALC_H

#include <stdlib.h>

typedef struct vector {
    int n;
    double *vec;
} Vector;


Vector *creaVector(int n);
void    imprimeVector(Vector *a);
Vector *copiaVector(Vector *a);
Vector *sumaVector(Vector *a, Vector *b);
Vector *restaVector(Vector *a, Vector *b);
void    liberaVector(Vector *v);

#endif