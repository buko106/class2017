CC = gcc
CFLAGS = -Wall
TARGET = count10 ish

.PHONY: all
all: $(TARGET)

count10: count10.c
	$(CC) -o $@ $^ -O3 $(CFLAGS)
ish: ish.c parse.c print.c
	$(CC) -o $@ $^ $(CFLAGS)  
.PHONY: clean
clean:
	rm $(TARGET)
