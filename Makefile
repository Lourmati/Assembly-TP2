ASFLAGS= -f elf32 -g dwarf2


all:
	make clean
	make med
	make ut_chaines
	make ut_fichiers

clean:
	rm -f *.o
	rm -f med 2
	rm -f ut_chaines 2
	rm -f ut_fichiers 2


med:
	yasm $(ASFLAGS) -o med.o med.asm
	ld -o med med.o
	yasm $(ASFLAGS) -o ut_chaines.o ut_chaines.asm
	ld -o ut_chaines ut_chaines.o
	yasm $(ASFLAGS) -o ut_fichiers.o ut_fichiers.asm
	ld -o ut_fichiers ut_fichiers.o


