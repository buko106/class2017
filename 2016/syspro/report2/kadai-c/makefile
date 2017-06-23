CC = gcc
CFLAGS = -Wall

mycp:mycp.c
	$(CC) $(CFLAGS) -o $@ $^
mycp1:mycp1.c
	$(CC) $(CFLAGS) -o $@ $^
mycp8192:mycp8192.c
	$(CC) $(CFLAGS) -o $@ $^
mycpf:mycpf.c
	$(CC) $(CFLAGS) -o $@ $^
mycpf1:mycpf1.c
	$(CC) $(CFLAGS) -o $@ $^
mycpf8192:mycpf8192.c
	$(CC) $(CFLAGS) -o $@ $^
mycpf1setvbuf:mycpf1setvbuf.c
	$(CC) $(CFLAGS) -o $@ $^
clean:
	rm mycp mycp1 mycp8192 mycpf mycpf1 mycpf8192 mycpf1setvbuf

all:mycp mycp1 mycp8192 mycpf mycpf1 mycpf8192 mycpf1setvbuf
