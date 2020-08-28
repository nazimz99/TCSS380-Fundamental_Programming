-module(pr2).
%-export([mymain/0, printMenu/0, userOptions/6, reverseList/1, reverseList/2, blockCount/2, fileLength/2, createBlockTable/1, createBlockTable/2, directoryTable/2, directoryTable/3, addDirectoryTable/4, addBlockTable/6, addBlockTable/8, contiguousBlocks/2, contiguousBlocks/4, searchFile/2, removeDirectory/4, removeBlockTable/2, removeBlockTable/4, printTables/2, blocksAsString/1, blocksAsString/2, directoryAsString/1, directoryAsString/2]).
-export([mymain/0]).
-import(string, [to_integer/1, concat/2]).
-import(lists, [split/2]).

% Initializes storage size, blocksize, tables, and any other variables needed
% for other functions and returns the recursive function userOptions which does
% all of the work.
mymain() ->
	S = io:get_line("Enter the size of your storage device: "),
	{StorageSize,_} = string:to_integer(S), 
	Str = io:get_line("Enter the size of each block: "),
	{BlockSize,_} = string:to_integer(Str),
	BlockCount = blockCount(StorageSize, BlockSize),
	BlockTable = createBlockTable(BlockCount),
	Size = 0,
	Capacity = 1,
	DirectoryStruct = directoryTable(Size, Capacity),
	DirectoryTable = element(1, DirectoryStruct),
	userOptions(DirectoryTable, Size, Capacity, BlockTable, BlockSize, BlockCount).



% Presents the user's options and returns a string.

printMenu() ->
	io:fwrite("\nDo you want to:\n"),
	S = io:get_line("Add a file? Enter 1\n Delete a file? Enter 2\n Print values? Enter 3\n Quit? Enter 4\n"),
	S.


% Presents all of the options the user makes and executes the functions
% for adding, removing, or printing a file according to the option selected.
% This is done recursively until the last option is selected.

userOptions(DirectoryTable, Size, Capacity, BlockTable, BlockSize, BlockCount) ->
	{UserChoice,_} = string:to_integer(printMenu()),
	case UserChoice of
		% Files will be added to the directory table and memory
		% will be added to the block table if user selects 
		% option 1.
		1 -> 
		S1 = io:get_line("Adding - enter filename: "), 
		{Filename,_} = lists:split(length(S1)-1, S1),
		S2 = io:get_line("Adding - enter file size: "),
		{Filesize,_} = string:to_integer(S2),
		Length = fileLength(Filesize, BlockSize),
		Contig = contiguousBlocks(BlockTable, {Filename, Filesize, 0, Length}),
		End = element(1, Contig),
		Acc = element(2, Contig),
		File = {Filename, Filesize, End - Length, Length},
		NewBlockTable = addBlockTable(BlockTable, File, Filesize, BlockSize, BlockCount, Acc),
		if 
			% Will only add file to the Directory if enough
			% contiguous space is available.
			Acc =:= Length ->
				DirectoryStruct = addDirectoryTable(File, DirectoryTable, Size, Capacity);
			
			% Otherwise, the directory table, size, and capacity
			% are not updated.
			true -> 
				DirectoryStruct = {DirectoryTable, Size, Capacity},
				io:fwrite("Sorry - file cannot be added to the system.\n")
		end,
		NewDirectory = element(1, DirectoryStruct),
		NewSize = element(2, DirectoryStruct),
		NewCapacity = element(3, DirectoryStruct),
		% Passes the new, updated tables and variables to use recursively. 
		userOptions(NewDirectory, NewSize, NewCapacity, NewBlockTable, BlockSize, BlockCount);
		% File and memory will be removed from the directory table
		% and block table respectively if user selects option 2.	
		2 -> 
		S = io:get_line("Deleting - enter filename: "), 
		{Filename,_} = lists:split(length(S)-1, S),
		% Searches through file to retrieve file with corresponding Filename.
		File = searchFile(DirectoryTable, Filename),
		DirectoryStruct = removeDirectory(DirectoryTable, Size, Capacity, Filename),
		NewDirectory = element(1, DirectoryStruct), 
		case string:equal(element(1, File), Filename) of
			% If file could be found in directory table,
			% memory will be removed from the block table.
			true ->
				NewBlockTable = removeBlockTable(BlockTable, File);
			% Else, block table remains unchanged. 
			false -> 
				NewBlockTable = BlockTable,
				io:fwrite("Sorry - file was not found in the system.\n")
		end,
		NewSize = element(2, DirectoryStruct),
		% Passes the new, updated tables and variables to use recursively.
		userOptions(NewDirectory, NewSize, Capacity, NewBlockTable, BlockSize, BlockCount);

		% Prints current directory table and block table.
		3 -> 
		HelperTable = reverseList(DirectoryTable),
		printTables(HelperTable, BlockTable),
		% Passes the tables and other variables like normal to use recursively.
		userOptions(DirectoryTable, Size, Capacity, BlockTable, BlockSize, BlockCount);
		
		% Terminates program when option 4 is selected.
		4 -> done
	end.


% Reverse the contents of a list when updating block table or
% printing the directory table properly.
reverseList(Xs) -> reverseList(Xs, []).
reverseList([], Ys) -> Ys;
reverseList([X|Xs], Ys) ->
	reverseList(Xs, [X|Ys]).

	
% Sets the number of rows in block table
% based on total storage size and block size.
blockCount(StorageSize, BlockSize) ->
	if 
		StorageSize rem BlockSize == 0 -> StorageSize div BlockSize;
		true -> StorageSize div BlockSize + 1
	end.

% Calculates the length of the file relative
% to the size of the file and block size.
fileLength(Filesize, BlockSize) ->
	if 
		Filesize rem BlockSize == 0 ->
			Filesize div BlockSize;

		true -> Filesize div BlockSize + 1
	end.

% Initializes an empty block table where each row
% has its index and empty blocks.
createBlockTable(BlockCount) -> createBlockTable([], BlockCount).
createBlockTable(Xs, 0) -> Xs;
createBlockTable(Xs, BlockCount) ->
	createBlockTable([{BlockCount-1,0, 0}|Xs], BlockCount-1).

% Returns a tuple with directory table, size, and capacity
% to reference and update later.
directoryTable(Size, Capacity) -> directoryTable([], Size, Capacity).
directoryTable(Xs, Size, Capacity) -> 
	DirectoryTable = Xs,
	{DirectoryTable, Size, Capacity}.




% Adds file to the Directory and updates its size and capacity accordingly
% and returns the updated directory alongside the updated size and capacity.
addDirectoryTable(File, DirectoryTable, Size, Capacity) ->
	if 
		Size >= Capacity ->
			directoryTable([File|DirectoryTable], Size+1, Capacity*2);
		true -> 
			directoryTable([File|DirectoryTable], Size+1, Capacity)
	end.


% Adds appropriate memory to the BlockTable in the appropriate spaces
% and returns the updated block table.
addBlockTable(BlockTable, File, Filesize, BlockSize, BlockCount, Acc) -> 
	addBlockTable(BlockTable, [], File, Filesize, BlockSize, BlockCount, 0, Acc).

% Returns the newly updated block table.
addBlockTable([], Ys, _File, _Filesize, _BlockSize, _BlockCount, _Accumulator, _Acc) -> 
	NewBlockTable = reverseList(Ys),
	NewBlockTable;

% Updates the block table if there is contiguous space
% indicated by the Acc variable.
addBlockTable([X|BlockTable], Ys, File, Filesize, BlockSize, BlockCount, Accumulator, Acc) -> 
	if 
		% When the index indicated by Accumulator is referring to the
		% blocks within the file's start position and end position, then
		% the contents of the block table is updated with information of
		% the row's index, blocksize, and no fragmented memory if the current
		% memory that can be allocated exceeds the blocksize.
		Acc =:= element(4, File),
		Accumulator >= element(3, File),
		Accumulator <  element(3, File) + element(4, File),
		Filesize > BlockSize -> addBlockTable(BlockTable, [{Accumulator,BlockSize, 0}|Ys], File, Filesize-BlockSize, BlockSize, BlockCount, Accumulator+1, Acc);

		% When the index indicated by Accumulator is referring to the
		% blocks within the file's start position and end position, then
		% the contents of the block table is updated with information of
		% the row's index, remaining filesize, and fragmented memory if the current
		% memory that can be allocated from the file is above 0, but below the 	       	% blocksize.
		Acc =:= element(4, File),
		Accumulator >= element(3, File),
		Accumulator < element(3, File) + element(4, File),
		Filesize =< BlockSize,
		Filesize > 0  -> addBlockTable(BlockTable, [{Accumulator, Filesize, BlockSize - Filesize}|Ys], File, 0, BlockSize, BlockCount, Accumulator+1, Acc);
		
		% Otherwise, the current row of the block table is not updated.
		true -> addBlockTable(BlockTable, [X|Ys], File, Filesize, BlockSize, BlockCount, Accumulator+1, Acc)
	end.


% Contiguous Blocks returns the end position of the file as well
% as the Accumulator which dicates the number of contiguous spaces.
contiguousBlocks(BlockTable, File) -> 
	contiguousBlocks(BlockTable, File, 0, 0).

% Returns the End block and Accumulator when there is enough
% contiguous spaces to add the file in.
contiguousBlocks(_BlockTable, File, End, Accumulator) when Accumulator =:= element(4, File) -> {End, Accumulator};

% Returns the End block and Accumulator after the entire
% block table has been traversed.
contiguousBlocks([], _File, End, Accumulator) -> {End, Accumulator};

% Updates the End and resets Accumulator if an empty spot was not spotted.
% Else, increment the Accumulator.
contiguousBlocks([X|BlockTable], File, End, _Accumulator) when X =/= {End, 0, 0} -> 
	contiguousBlocks(BlockTable, File, End+1, 0);
contiguousBlocks([X|BlockTable], File, End, Accumulator) when X =:= {End, 0, 0} -> 
	contiguousBlocks(BlockTable, File, End+1, Accumulator+1).




% Iterates through the file and tries to locate
% file with the corresponding string entered by the user.
% Returns a null file if file was not located after iterating
% through the entire directory.
searchFile([], _Filename) -> {"", 0, 0, 0};
searchFile([File|DirectoryTable],  Filename) ->
	if 
		element(1, File) =:= Filename ->
			File;
		true -> searchFile(DirectoryTable, Filename)
	end.
		


% Removes a file from the directory and returns the updated directory
% after traversing through the entire directory.
removeDirectory(DirectoryTable, Size, Capacity, Filename) -> removeDirectory(DirectoryTable, Size, Capacity, [], Filename).
removeDirectory([], Size, Capacity, Ys, _Filename) -> 
	NewDirectory = reverseList(Ys),
	directoryTable(NewDirectory, Size, Capacity);
removeDirectory([File|DirectoryTable], Size, Capacity, Ys, Filename) -> 
	case string:equal(element(1, File), Filename) of
		% if there is a file in the directory that matches
		% the filename entered that the user wants to remove,
		% then the file will not be added to the directory, the size 
		% will be decremented and the rest of the contents will be added
		% to the updated directory table.

		true -> 
			removeDirectory(DirectoryTable, Size-1, Capacity, Ys, Filename);

		% Else, the size will remain the same and the file will just be
		% added to the directory table.
		false -> 
			removeDirectory(DirectoryTable, Size, Capacity, [File|Ys], Filename)
	end. 

% Removes memory in the blocks occupied with the file selected
% by the user to remove.
removeBlockTable(BlockTable, File) -> removeBlockTable(BlockTable, [], File, 0).

% Returns the updated block table after entire table was
% traversed through.
removeBlockTable([], Ys, _File, _Accumulator) ->
	NewBlockTable = reverseList(Ys),
	NewBlockTable;

removeBlockTable([X|BlockTable], Ys, File, Accumulator) -> 
	if 
		% Removes the memory in the rows occupied by the file
		% and adds empty blocks in its place in the updated 
		% block table.
		Accumulator >= element(3, File),
		Accumulator < element(3, File) + element(4, File) ->
			removeBlockTable(BlockTable, [{Accumulator, 0, 0}|Ys], File, Accumulator+1);
		
		% Else, the memory of the table is not updated
		% and passed to the updated block table like normal.
		true -> removeBlockTable(BlockTable, [X|Ys], File, Accumulator+1)
	end.

% Prints out the directory table and block table.
printTables(DirectoryTable, BlockTable) ->
	io:fwrite("Printing -\n"),
	io:fwrite("-----------------------------------------------\n"),
	io:fwrite("DirectoryTable:\n"),
	io:fwrite("Filename\s\s"),
	io:fwrite("Size\s"),
	io:fwrite("Start\s"),
	io:fwrite("Length\n"),
	directoryAsString(DirectoryTable),
	io:fwrite("-----------------------------------------------\n"),
	io:fwrite("BlockTable: \n"),
	io:fwrite("BlockNumber\s"),
	io:fwrite("Used\s"),
	io:fwrite("Fragmented\n"),
	blocksAsString(BlockTable).

% Adds each row of the block table to the head of string
% and returns the string after each rows' elements have been
% added to the string.
blocksAsString(BlockTable) -> blocksAsString(BlockTable, "").
blocksAsString([], Str) -> reverseList(Str);
blocksAsString([X|BlockTable], Str) ->
	S = io:fwrite("~p~n", [X]),
	blocksAsString(BlockTable, [S|Str]).

% Adds each file's elements to the head of the string and returns
% the string after each file's contents have been added to the string.
directoryAsString(DirectoryTable) -> directoryAsString(DirectoryTable, "").
directoryAsString([], Str) -> reverseList(Str);
directoryAsString([File|DirectoryTable], Str) ->
	S = io:fwrite("~p~n", [File]),
	directoryAsString(DirectoryTable, [S|Str]).
