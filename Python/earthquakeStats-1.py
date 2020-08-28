# takes the dictionary and prints its contents to the screen and to the file
# sorted by the key
def frequency_table(countdict):
    
    print("ITEM", "\t", "FREQUENCY")
	
    ## 5. __________________
    ## print the dictionary parameter sorted by the key to the screen
    for i in sorted (countdict.keys()):
	print(i, "\t", countdict[i])
    
# takes a list of numbers and an empty dictionary
# builds the dictionary with earthquake frequencies
# where the key is the magnitude and the value is the frequency with which such an earthquake occurred
# returns a list of modes 
def my_mode(alist, countdict):
    for magnitude in alist:
	frequency = 0
	for i in range(len(alist)):
	    if alist[i] == magnitude:
		frequency += 1
	    countdict[magnitude] = frequency

    ## 3. _____________________________
    ## iterate over alist and build a dictionary called countdict
    ## to store the frequency of each value in alist parameter
           
    maxcount = countdict.get(alist[0])
    for i in range(1, len(countdict)):
	if maxcount < countdict.get(alist[i]):
	    maxcount = countdict.get(alist[i])

 ## 4. _______________find the highest value in a value componet of the dictionary
    
    modelist = [ ]      ## creates a list of modes since there may be more than one mode
    for item in countdict:
        if countdict[item] == maxcount:
            modelist.append(item)
    
    return modelist

# takes a list of numbers and retuorns a median value - write your own code, do NOT use a built-in method median
def my_median(alist):
    newList = []
    ## 2. _________________________
    ## deep copy of a list and then sort the copy 
    ## find the median value - middle value if the length odd
    ## average of 2 middle values otherwise 
    for magnitudes in alist:
	newList.append(magnitudes)
    newList.sort()
    size = len(newList)
    if len(newList) % 2 != 0:
	med = newList[size/2 + 1]
    else:
	med = (newList[size/2] + newList[size/2 + 1])/2
		
    return med

# opens a file and extracts all earthquake magnitudes
# into a list of floats and returns that list
def make_magnitude_list():
        quakefile = open("earthquakes.txt","r")
        headers = quakefile.readline()
        
        maglist = [ ]
        for aline in quakefile:
            vlist = aline.split()
            print(vlist)
            maglist.append(float(vlist[1]))
        return maglist
    
def my_main():
    magList = make_magnitude_list()
    print(magList)
    ## 1. ______________________________
    ## print mean (use built in functions sum and len) 
    print(sum(magList)/len(magList))
    frequencyDict = {}
    med = my_median(magList)
    print("median: ", med)
    mod = my_mode(magList, frequencyDict)
    print("mode: ", mod)
    frequency_table(frequencyDict)

my_main()
