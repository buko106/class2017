CC = gcc
CFLAGS = -Wall
TARGET = call ish

.PHONY: all
all: $(TARGET)

call: call.c
	$(CC) -o $@ $^ $(CFLAGS)
ish: ish.c parse.c print.c
	$(CC) -o $@ $^ $(CFLAGS)  
.PHONY: clean
clean:
	rm $(TARGET)
