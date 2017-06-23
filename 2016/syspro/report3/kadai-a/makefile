CC=gcc
CFLAGS=-Wall -pthread

all:btree btree-unlock

btree:btree.c
	$(CC) $^ -o $@ $(CFLAGS)

btree-unlock:btree-unlock.c
	$(CC) $^ -o $@ $(CFLAGS)

clean:
	rm btree btree-unlock

