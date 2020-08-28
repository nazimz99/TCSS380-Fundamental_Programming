#MakeFile for pr1.out

pr1.out: driver.o fileDirectory.o
	gcc -o pr1.out driver.o fileDirectory.o

driver.o: driver.c fileDirectory.h
	gcc -c driver.c

fileDirectory.o: fileDirectory.c fileDirectory.h
	gcc -c fileDirectory.c
