class Money:
	money_counter = 0

	def __init__(self, dollars=0, cents=0):
		self.dollars = dollars
		self.cents = cents
		Money.money_counter+=1
	
	def getDollars(self):
		return self.__dollars

	def setDollars(self, newDollars):
		self.__dollars = newDollars

	def getCents(self):
		return self.__cents

	def setCents(self, newCents):
		self.__cents = newCents
	
	def __str__(self):
		"Dollars: " + self.dollars + " and Cents: " + self.cents

	def __add__self(self, money):
		newMoney = Money()
		newMoney._dollars = self.__dollars + money.__dollars
		newMoney._cents = self.__cents + money.__cents
		return newMoney

def mymain():
	object1 = Money()
	print(object1.getDollars())
	print(object1.getCents())
	setDollars(5)
	setCents(96)
	print(object1.getDollars())
	print(object1.getCents())
	print(object1)

	object2 = Money()
	print(object2.getDollars())
	print(object2.getCents())
	setDollars(8)
	setCents(16)
	print(object2.getDollars())
	print(object2.getCents())
	print(object2)

	object3 = object1.add(object2)
	print(object3)
			
	
