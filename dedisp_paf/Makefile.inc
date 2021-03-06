# The definitions in this file should be changed to match your system

# CUDA_PATH ?= /usr/local/cuda
CUDA_PATH ?= /Developer/NVIDIA/CUDA-7.5

CUDA_DIR   ?= $(CUDA_PATH)
THRUST_DIR ?= $(CUDA_DIR)/include

# LIB_ARCH   = lib
LIB_ARCH   = lib
# GPU_ARCH   = sm_13
GPU_ARCH   = sm_52
# GPU_ARCH   = sm_30

GCC        = gcc
GXX        = g++
AR         = ar
NVCC       = $(CUDA_DIR)/bin/nvcc #-Xptxas -abi=no
DOXYGEN    = doxygen
RM         = rm
ECHO       = echo
MKFLAGS    = 

DEDISP_DEBUG = 0

#.SILENT :
