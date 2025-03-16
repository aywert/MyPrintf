all: compile link

compile:
	nasm MyPrintf.asm -o MyPrintf.o -f elf64 

link: 
	ld -o MyPrintf.exe MyPrintf.o

run:
	./MyPrintf.exe
