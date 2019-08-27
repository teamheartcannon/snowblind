extends Node

func approach(from, to, amount):
	if from < to:
		from += amount
		
		if from > to:
			return to
	else:
		from -= amount
		
		if from < to:
			return to
	
	return from