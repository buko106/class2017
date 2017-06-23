CC = gcc
CFLAGS = -Wall
TARGET = iperfs iperfc

.PHONY: all
all: $(TARGET)

iperfs: iperfs.c
	$(CC) -o $@ $^ $(CFLAGS) 
iperfc: iperfc.c
	$(CC) -o $@ $^ $(CFLAGS)
.PHONY: clean
clean:
	rm $(TARGET)
