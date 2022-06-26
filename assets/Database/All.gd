extends Node


var words: Array = []

func _ready():
	words = _getAllUniqueWords()
	print_debug("Registered a total of %s unique words in the database files." % words.size())

func _getAllUniqueWords() -> Array:
	var result: Array = []

	for wordArray in MatchImageDB.words:
		for word in wordArray:
			if not word in result:
				result.append(word)

	for wordDictionary in StartsWithDB.words:
		for word in wordDictionary[StartsWithDB.WORDS_PROP]:
			if not word in result:
				result.append(word)

	for wordArray in RhymesWithDB.words:
		for word in wordArray:
			if not word in result:
				result.append(word)

	result.sort()
	return result
