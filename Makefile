# =================================================================
# Makefile CORREGIDO (sin el comando 'mv' destructivo)
# =================================================================
CC      ?= gcc
YACC    ?= yacc
CFLAGS  := -std=c11 -O2 -Wall -Wextra
LDFLAGS := -lm

TARGET = hoc1
OBJS   = y.tab.o vector_calc.o

all: $(TARGET)

# Enlaza los dos archivos objeto (.o) para crear el ejecutable final
$(TARGET): $(OBJS)
	$(CC) $(OBJS) -o $@ $(LDFLAGS)

# Genera el parser y.tab.c y la cabecera y.tab.h desde la gramática
y.tab.c y.tab.h: vector_calc.y
	$(YACC) -d vector_calc.y

# Compila el parser generado (y.tab.c) en un archivo objeto (y.tab.o)
y.tab.o: y.tab.c vector_calc.h
	$(CC) $(CFLAGS) -c -o $@ y.tab.c

# Compila TU código C (vector_calc.c) en otro archivo objeto (vector_calc.o)
vector_calc.o: vector_calc.c vector_calc.h y.tab.h
	$(CC) $(CFLAGS) -c -o $@ vector_calc.c

# Limpia todos los archivos generados
clean:
	rm -f $(TARGET) a.out y.tab.c y.tab.h *.o
	@echo "Clean"

.PHONY: all clean