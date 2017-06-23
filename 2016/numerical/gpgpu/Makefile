CC=nvcc
NVCC=nvcc
CCFLAGS=
NVCCFLAGS=
TARGET=cpu gpgpu

.PHONY:
all:$(TARGET)

gpgpu:gpgpu.cu
	$(NVCC) -o $@ $^ $(NVCCFLAGS)

cpu:cpu.c
	$(CC) -o $@ $^ $(CCFLAGS)

.PHONY:
clean:
	rm $(TARGET) *.log *.err
