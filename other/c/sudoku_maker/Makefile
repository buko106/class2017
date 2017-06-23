CC=gcc
CFLAGS= -Wall
TARGET= solver_test random_maker

.PHONY:
all:$(TARGET)

solver_test: solver_test.c solver.c
	$(CC) -o $@ $^ $(CFLAGS)

random_maker: random_maker.c solver.c
	$(CC) -o $@ $^ $(CLAGS)

.PHONY:
clean:
	rm $(TARGET)
