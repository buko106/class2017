CC = gcc
CFLAGS = -Wall
LPTHREADFLAGS = -pthread
TARGET = tcpechoserver1 tcpechoserver2 tcpechoclient

.PHONY: all
all: $(TARGET)

tcpechoserver1: tcpechoserver1.c
	$(CC) -o $@ $^ $(CFLAGS) $(LPTHREADFLAGS)
tcpechoserver2: tcpechoserver2.c
	$(CC) -o $@ $^ $(CFLAGS) 
tcpechoclient: tcpechoclient.c
	$(CC) -o $@ $^ $(CFLAGS)
.PHONY: clean
clean:
	rm $(TARGET)
