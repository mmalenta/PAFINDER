SRC_DIR = ./src
INC_DIR = ./include
OBJ_DIR = ./obj
BIN_DIR = ./bin
DEDISP_DIR = ./dedisp_paf
CC=g++
NVCC=/usr/local/cuda-8.0/bin/nvcc
DEBUG=#-g -G
INCLUDE = -I${INC_DIR} -I/usr/local/cuda-8.0/include
LIBS = -L${DEDISP_DIR}/lib -L/usr/local/cuda-8.0/lib64 -lstdc++ -lboost_system -lpthread -lcudart -lcuda -lnuma

CFLAGS = -Wall -Wextra -std=c++11
NVCC_FLAG = --std=c++11 -lcufft -Xcompiler ${DEBUG} #--default-stream per-thread

CPPOBJECTS = ${OBJ_DIR}/DedispPlan.o

CUDAOBJECTS = ${OBJ_DIR}/pafinder.o ${OBJ_DIR}/gpu_pool.o ${OBJ_DIR}/main_pool.o ${OBJ_DIR}/kernels.o ${OBJ_DIR}/dedisp.o ${OBJ_DIR}/filterbank_buffer.o


all: pafinder

pafinder: ${CUDAOBJECTS} ${CPPOBJECTS}
	${NVCC} ${NVCC_FLAG} ${INCLUDE} ${LIBS} ${CUDAOBJECTS} ${CPPOBJECTS} -o ${BIN_DIR}/pafinder

${OBJ_DIR}/%.o: ${SRC_DIR}/%.cu
	${NVCC} -c ${NVCC_FLAG} ${INCLUDE} $< -o $@

${OBJ_DIR}/%.o: ${SRC_DIR}/%.cpp
	${CC} -c ${CFLAGS} ${INCLUDE} $< -o $@

.PHONY: clean

clean:
	rm -f ${OBJ_DIR}/*.o ${BIN_DIR}/*
