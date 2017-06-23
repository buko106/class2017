TARGET = Verify Verify2 test
CC = gcc
CFLAGS = -Wall

.PHONY:all clean
all:$(TARGET)

Verify:Verify.c fadd.c
	$(CC) $(CFLAGS) -o $@ $^
Verify2:Verify.c fadd2.c
	$(CC) $(CFLAGS) -o $@ $^
test:test.c fadd.c mt19937ar.c
	$(CC) $(CFLAGS) -o $@ $^

clean:
	rm $(TARGET)
