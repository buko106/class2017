prog: a.o b.o c.o
	gcc a.o b.o c.o -Wall -o prog

a.o: a.c b.h c.h
	gcc -c a.c -Wall
b.o: b.c
	gcc -c b.c -Wall
c.o: c.c
	gcc -c c.c -Wall
clean:
	rm -f *.o prog
