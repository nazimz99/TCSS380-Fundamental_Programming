#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include "fileDirectory.h"

/** 
* This program implements the functions necessary to 
* create a directory to add/remove files and a block table to store/delete
* the memory of files that are found in contiguous blocks.
*
* @author Nazim Zerrouki
* @version 1.0
* @since 11/12/19
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

/** 
* Frees all dynamically allocated memory.
* @Return void 
*/
 
void destroy(directory directory_table, int **block_table, int block_count) {
	free(directory_table->entries);
	free(directory_table);
	for (int i = 0; i < block_count; i++) {
		free(block_table[i]);
	}
	free(block_table);
}

/** 
* Dynamically allocates the block table as a double
* int pointer with rows depending on storage size and block size
* and 2 rows to store used memory and fragmented memory for each
* file. 
* @Return int** 
*/

int** createBlockTable(int **block_table, int block_count) {
	block_table = (int**)malloc(block_count * sizeof(int*));
	for (int i = 0; i < block_count; i++) {
		block_table[i] = (int*)calloc(2, sizeof(int));
	}
	return block_table;
}

/** 
* Determines whether there is enough memory left to store the file.
* This is used for error handling.
* @Return bool 
*/

bool canAddMemory(directory directory_table, entry file, int storage_size, int block_count) {
	if (file.file_size > (storage_size - directory_table->storage)) {
		directory_table->can_add = false;
		return false;
	}
	if (directory_table->space >= block_count) {
		directory_table->can_add = false;
		return false;
	}
	return true;
}

/**
* Adds memory to contiguous blocks within the
* block table and keeps track of the starting block
* of the next file.
* @Return void 
*/

void addBlockTable(directory directory_table, int **block_table, entry file, int block_size, int block_count) {	
	int i,j, k;
	i = file.start;
	j = i + file.length;
	k = i;
	while (i < j) {
		if (i >= block_count) {
			break;
		}
		if (block_table[i][0] != 0) {
			k = i + 1;
			j = i + file.length + 1;
		}
		i++;
	}
	if (k + file.length <= block_count) {
		while (file.file_size > block_size) {
			block_table[k++][0] = block_size;
			file.file_size -= block_size;
		}
		if (file.file_size > 0) {
			block_table[k][0] = file.file_size;
			block_table[k++][1] = block_size- file.file_size;		
		}
		directory_table->file_start = k;
	}
	else {
		i = 0;
		j = i + file.length;
		k = i;
		while (i < j) {
			if (i >= block_count) {
				break;
			}
			if (block_table[i][0] != 0) {
				k = i + 1;
				j = i + file.length + 1;
			}
			i++;
		}
		if (k-1 + file.length > file.start) {
			directory_table->file_start = file.start;
			directory_table->can_add = false;
		}
		else if (k-1 + file.length <= file.start) {
			while (file.file_size > block_size) {
				block_table[k++][0] = block_size;
				file.file_size -= block_size;
			}
			if (file.file_size > 0) {
				block_table[k][0] = file.file_size;
				block_table[k++][1] = block_size - file.file_size;
			}
		}
		directory_table->file_start = k;

	}

	if (k >= block_count) {
		for (i = 0; i < block_count; i++) {
			if (block_table[i][0] == 0) {
				directory_table->file_start = i;
				break;
			}
		}
	}

}

/**
* Removes memory occupied by selected
* file that is chosen to remove.
* @Return void
*/

void removeBlockTable(directory directory_table, int **block_table, entry file) {
	for (int i = file.start; i < file.start + file.length; i++) {
		block_table[i][0] = 0;
		block_table[i][1] = 0;
	}
	directory_table->file_start = file.start;
	directory_table->space-=file.length;
}

/**
* Allocates memory to directory and the structure
* containing a pointer to each file structure. All
* attributes related to size, capacity, starting block, 
* and storage are all initialized.
* @Return directory
*/

directory createDirectoryTable() {
	directory directory_table = malloc(sizeof(struct entries));
	directory_table->size = 0;
	directory_table->capacity = 1;
	directory_table->file_start = 0;
	directory_table->storage = 0;
	directory_table->space = 0;
	directory_table->entries = malloc(directory_table->capacity * sizeof(entry));
	return directory_table;
}

/**
* Adds a file to the directory and reallocates
* more memory once the current size will exceed
* the capacity of the directory. 
* @Return void
*/

void addDirectory(directory directory_table, entry file) {
	if (directory_table->size == directory_table->capacity) {
		entry* helper = realloc(directory_table->entries, directory_table->capacity*2 * sizeof(entry));
		if (helper != NULL) {
			directory_table->entries = helper;
			directory_table->capacity*=2;	
		}
	}
	directory_table->entries[directory_table->size] = file;
	strcpy(directory_table->entries[directory_table->size].filename, file.filename);
	directory_table->size++;
	directory_table->space+=file.length;
}

/**
* Removes a file from the directory if the file
* can be located within the directory and removes
* the file, moves the memory of each file below up
* by one unit (size of a file) and decreases the size
* accordingly.
* @Return void
*/

void removeDirectory(directory directory_table, entry file, char *file_name) {
	int i, j;
	for (i = 0; i < directory_table->size; i++) {
		if (strcmp(directory_table->entries[i].filename, file_name) == 0)  {
			j = i;
			directory_table->in_directory = true;
			break;
		}
		
	}
	if (directory_table->in_directory) {
		memmove(&(directory_table->entries[j]), &(directory_table->entries[j+1]), (directory_table->size - j-1) * sizeof(entry));	
		directory_table->size--;
	}
}

/**
* Displays the directory table with each file structure
* and their corresponding attributes as well as the block table
* with the used and fragmented memory displayed correctly to the
* user without seeing the implementation of this system.
* @Return void
*/

void printTables(directory directory_table, int **block_table, int block_count) {
	printf("Printing -\n");
	printf("---------------------------------------\n");
	printf("Directory Table:\n");
	printf("Filename\t\t");
	printf("Size\t");
	printf("Start\t");
	printf("Length\n");
	for (int i = 0; i < directory_table->size; i++) {
		entry file = directory_table->entries[i];
		printf("%s\t\t", file.filename);
		printf("%d\t", file.file_size);
		printf("%d\t", file.start);
		printf("%d\n", file.length);
	}
	printf("---------------------------------------\n");
	printf("Block Table: \n");
	printf("Block number\t");
	printf("Size used\t");
	printf("Fragmented\n");
	for(int i = 0; i < block_count; i++) {
		printf("%d\t\t", i);
		printf("%d\t\t", block_table[i][0]);
		printf("%d\n", block_table[i][1]);
	}
	printf("----------------------------------------\n");
}
