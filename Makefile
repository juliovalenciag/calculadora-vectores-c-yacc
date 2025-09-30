# =================================================================
# Makefile CORREGIDO Y VERIFICADO
# =================================================================
CC      ?= gcc
YACC    ?= yacc
CFLAGS  := -std=c11 -O2 -Wall -Wextra
LDFLAGS := -lm

# El nombre del programa final
TARGET = hoc1

# Los archivos objeto que necesita el programa
OBJS   = y.tab.o vector_calc.o

all: $(TARGET)

# Regla para enlazar los .o y crear el ejecutable
$(TARGET): $(OBJS)
	$(CC) $(OBJS) -o $@ $(LDFLAGS)

# Regla para generar el parser desde el archivo .y
y.tab.c y.tab.h: vector_calc.y
	$(YACC) -d vector_calc.y

# Regla para compilar el parser (y.tab.c -> y.tab.o)
y.tab.o: y.tab.c vector_calc.h
	$(CC) $(CFLAGS) -c -o $@ y.tab.c

# Regla para compilar TU código C (vector_calc.c -> vector_calc.o)
# La clave está en el '-o' de la siguiente línea.
vector_calc.o: vector_calc.c vector_calc.h y.tab.h
	$(CC) $(CFLAGS) -c -o $@ vector_calc.c

# Regla para limpiar los archivos generados
clean:
	rm -f $(TARGET) a.out y.tab.c y.tab.h *.o
	@echo "Clean"

.PHONY: all clean