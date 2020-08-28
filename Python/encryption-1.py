import random

# Generates and returns a random key
def key_gen(alpha):      
        key = ""
        for idx in range(len(alpha)):
            index = random.randint(0, 25-idx)
            key = key + alpha[index]
            alpha = alpha[:index] + alpha[index+1:]
        return key

# Encrypts plaintext using a random key and a Caeser cipher
# 1. __________________________
# header for function caesar that takes plainText as an argument
def caeser(plainText):
        alphabet = "abcdefghijklmnopqrstuvwxyz"
        key = key_gen(alphabet)
        print("Random key: ")
        print(alphabet)
        print(key)
        # 2. ___________________  convert plainText to all lowercase letters
	plainText = plainText.lower()
        cipherText = ""
        for ch in plainText:
            index = alphabet.find(ch)
            # 3. _______________
            # if index is positive
            # append to cipherText a character sitting in key[index]
            # else if index is negative but ch is a digit
            # append that digit to cipherText 
            # else if index is negative but ch is not a digit
            # append a blank to cipherText
	    if index > 0:
		cipherText += key[index]
	    elif index < 0 and ch.isdigit():
		cipherText += ch
	    elif index < 0 and not ch.isdigit():
		cipherText += " "
		
        return cipherText

# Encrypts plaintext using transposition cipher
def transp(plainText):
        
        # 4. _________________________
        # extract all chars sitting in even positions into evenChars string
	evenChars = ""
	for i in range(0, len(plainText), 2):
		evenChars += plainText[i]
        # extract all chars sitting in odd positions into oddChars string
	oddChars = ""
	for i in range(1, len(plainText), 2):
		oddChars += plainText[i]
        cipherText = oddChars + evenChars
        return cipherText

# Encrypts plaintext using ASCII shift
def ascii_shift(plainText):
        shift = random.randint(1, 20)
        print("Shift: ", shift)
        # 5. _____________
        # print each original character, its ASCII value, and its new ASCII value
        # construct and return cipherText as plainText in which 
        # each char is replaced with old char + shift (look up chr and ord functions)
	cipherText = ""
	for i in range(len(plainText)):
		ch = plainText[i]
		print("Original: ", ord(ch), " New: ", ord(ch) + shift)
		cipherText += chr(ord(ch) + shift)
	return cipherText

# Driver
def my_main():

        msg = input('Enter a message to encrypt: ')
        print('Which encryption do you want to use?')
        choice = input('Enter 1 for random Caeser cipher, 2 for transposition, 3 for an ASCII shift: ')
        if choice.isdigit():
                int_choice = int(choice)
        # 6. ___________________________
        # while statement that is entered if choice is not suitable for an int
        # or int_choice is not within the range [1, 3] 
        while int_choice not in range(1, 4):
                print('Invalid input - try again')
                choice = input('Enter 1 for random Caeser cipher, 2 for transposition, 3 for an ASCII shift: ')
                if choice.isdigit():
                        int_choice = int(choice)
        # 7. _______________________
        # store encryption functions in a list
	encryptions = [caeser, transp, ascii_shift]
        # 8. _______________________
        # based on the user's choice (1, 2 or 3)  call appropriate encryption function
        # from the list (do not use the if statement) and store the result into variable cipherText
	if int_choice == 1:
		cipherText = encryptions[int_choice-1](msg)
	elif int_choice == 2:
		cipherText = encryptions[int_choice-1](msg)
	elif int_choice == 3:
		cipherText = encryptions[int_choice-1](msg)
	
        print('The encrypted message is: ', cipherText)

   # 9. ____________________
   # once you are done, add a loop that allows the user to repeat the program
   # until 'q' is entered
	inpt= input('Do you want to continue encrypting messages? Say y for yes and q for no')
	while inpt != "q":
		my_main()
        
if __name__ == '__main__':
        my_main()

        
    
    


