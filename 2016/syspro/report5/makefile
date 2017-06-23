CC = gcc
CFLAGS = -Wall
LPTHREADFLAGS = -pthread
TARGET = httpserver

.PHONY: all
all: $(TARGET)

httpserver: httpserver.c
	$(CC) -o $@ $^ $(CFLAGS) $(LPTHREADFLAGS)
.PHONY: clean
clean:
	rm $(TARGET)
