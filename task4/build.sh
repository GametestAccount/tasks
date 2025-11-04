#!/bin/bash

TARGET="task4"

nasm -f elf64 $TARGET.asm -l $TARGET.lst
ld $TARGET.o -o $TARGET
rm $TARGET.o
strace ./$TARGET 2> strace_output.txt
