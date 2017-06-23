CC = gcc
CFLAGS = -Wall
TARGET = udpechoserver udpechoclient

.PHONY: all
all: $(TARGET)

udpechoserver: udpechoserver.c
	$(CC) -o $@ $^
udpechoclient: udpechoclient.c
	$(CC) -o $@ $^
.PHONY: clean
clean:
	rm $(TARGET)
