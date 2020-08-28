#include <stdbool.h>
#ifndef FILEDIRECTORY_H
#define FILEDIRECTORY_H

/** 
* This is the header file for the driver and fileDirectory
* that contains all of the functions.
* @version 1.0
* @author Nazim Zerrouki
*/
typedef struct file entry;

/* The directory is a pointer to the array or
pointer of each file structure. */

typedef struct entries *directory;

void destroy(directory directory_table, int **block_table, int block_count);
directory createDirectoryTable();
int** createBlockTable(int **block_table, int block_count);
bool canAddMemory(directory directory_table, entry file, int storage_size, int block_count);
void addBlockTable(directory directory_table, int **block_table, entry file, int block_size, int block_count);
void removeBlockTable(directory directory_table, int **block_table, entry file);
void addDirectory(directory directory_table, entry file);
void removeDirectory(directory directory_table, entry file, char *file_name);
void printTables(directory directory_table, int **block_table, int block_count);

#endif
