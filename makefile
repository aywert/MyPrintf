all: compile link

compile:
	nasm  -f elf64  MyPrintf.asm -o MyPrintf.o 
link:
	gcc  MyPrintf.o main.c -static -o MyPrintf.exe 
run:
	./MyPrintf.exe 
