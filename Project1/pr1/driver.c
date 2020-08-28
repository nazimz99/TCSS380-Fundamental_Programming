#include "fileDirectory.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

/**
* This is the driver file that client uses
* to run the Directory and the Block Table.
* This program is meant to be run throug the VM.
* @version 1.0
* @author Nazim Zerrouki
*/

/* A structure is created to store the name, size,
 starting block, and length of the file. */

struct file {
	char filename[30]; 
	int file_size;
	int start;
	int length;
};

/**
* A structure is created to store a pointer to
* each file and keep track of the size, capacity, starting 
* block of the file which each entry can refer to, total 
* storage used, and determines whether a file can be 
* add or removed. 
*/

struct entries {
	entry *entries;
	int size;
	int capacity; 
	int file_start;
	bool can_add;	
	bool in_directory;
	int storage;
	int space;
};

int main(void) {

	int **block_table;
	int block_count;
	directory directory_table;
	directory_table = createDirectoryTable(); // dynamically allocate directory
	int user_choice = 0;
	int storage_size;
	int block_size;
	char file_name[30];
	printf("Enter the size of your storage device: ");
	scanf("%d", &storage_size);
	printf("Enter the size of each block : ");
	scanf("%d", &block_size);
	printf("Do you want to: \n");
	if (storage_size % block_size == 0) {
		block_count = storage_size/block_size;
	}
	else {
		block_count = (storage_size/block_size) + 1;
	}
	block_table = createBlockTable(block_table, block_count); // dynamically allocate block table

	while (user_choice != 4) {
		printf("Add a file? Enter 1 \n Delete a file? Enter 2\n Print values? Enter 3\n Quit? Enter 4\n"); 
		scanf("%d", &user_choice);
		entry file;
		directory_table->can_add = true;
		directory_table->in_directory = false;
		if (user_choice == 1) {
			printf("%d\n", directory_table->file_start);
			printf("Adding - enter filename: ");
			scanf("%s", file.filename);
			printf("Adding - enter file size: ");
			scanf("%d", &file.file_size);
			if (file.file_size % block_size != 0) {
				file.length = (file.file_size / block_size) + 1;
			}
			else {
				file.length = file.file_size / block_size;
			}
			file.start = directory_table->file_start;
			directory_table->file_start += file.length;
			if (canAddMemory(directory_table, file, storage_size, block_count)) { // adds memory if there's enough storage or blocks unfilled
				addBlockTable(directory_table, block_table, file, block_size, block_count);
			}
			if (directory_table->can_add) { // adds to directory if there's available, contiguous space to store memory in the block table
				directory_table->storage += file.file_size;
				addDirectory(directory_table, file);
			}
			else {
				printf("Sorry - file could not be added.\n");
			}
		}
		if (user_choice == 2) {
			printf("Deleting - enter filename: \n");
			scanf("%s", file_name);
			int j;
			for (int i = 0; i < directory_table->size; i++) {
				if (strcmp(directory_table->entries[i].filename, file_name) == 0) { // iterates through directory to find file name
					file = directory_table->entries[i];
					strcpy(file.filename, file_name);
					j = i;
				}
			}
			removeDirectory(directory_table, file, file_name);
			if (directory_table->in_directory) { // removes file from directory and memory from block table only if file is found in system
				removeBlockTable(directory_table, block_table, file);
				directory_table->storage -= file.file_size;	
			}
			else {
				printf("Sorry - file was found not in our system.\n");
			}			
		}

		if (user_choice == 3) {
			printTables(directory_table, block_table, block_count); // displays directory table and block table
		}

	}
		destroy(directory_table, block_table, block_count); // frees all memory allocated in heap
		return 0;
}

