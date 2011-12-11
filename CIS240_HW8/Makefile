CC=clang

all: shopper trace

shopper: shopper.c
	$(CC) -g shopper.c -o shopper

trace: trace.c parse.o
	$(CC) -g trace.c parse.o -o trace

parse.o: parse.c
	$(CC) -g -c parse.c
