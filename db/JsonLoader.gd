extends Node


# CONSTS
const DB_PATH = "res://assets/Database/"
const MATCH_IMAGE_DB = "match-image.json"
const STARTS_WITH_DB = "start-syllable.json"
const RHYMES_DB = "rhymes.json"

# VARS
var allWords: Array = []	# `Array` of `Strings` with all unique words in the DB files
var matchImageWords: Array = []	# `Array` of `Arrays` of `Strings`. The first String is used as the quiz target and should have a matching image
var startsWithWords: Array = []	# `Array` of `Dictionaries` with properties `start` (`String`) and `words` (`Array` of `Strings`)
var rhymesWords: Array = []	# `Array` of `Arrays` of `Strings`

# METHODS
func _init():
	_loadDbContents()

func _loadDbContents() -> void:
	var dbFile: File = File.new()
	matchImageWords = _loadMatchImageWords(dbFile)
	startsWithWords = _loadStartsWithWords(dbFile)
	rhymesWords = _loadRhymesWords(dbFile)
	allWords = _getAllUniqueWords()
	dbFile.close()

	print_debug("DB: Match Image words (%s):\n" % len(matchImageWords), matchImageWords)
	print_debug("DB: Starts With words (%s):\n" % len(startsWithWords), startsWithWords)
	print_debug("DB: Rhymes words (%s):\n" % len(rhymesWords), rhymesWords)
	print_debug("DB: all unique words (%s):\n" % len(allWords), allWords)

func _loadMatchImageWords(dbFile: File) -> Array:
	dbFile.open(DB_PATH + MATCH_IMAGE_DB, File.READ)
	var parseResult: JSONParseResult = JSON.parse(dbFile.get_as_text())

	assert(parseResult.error == OK, _getFailedParseMessage("Match Image", parseResult))
	if not parseResult.error == OK:
		return []

	return parseResult.result

func _loadStartsWithWords(dbFile: File) -> Array:
	dbFile.open(DB_PATH + STARTS_WITH_DB, File.READ)
	var parseResult: JSONParseResult = JSON.parse(dbFile.get_as_text())

	assert(parseResult.error == OK, _getFailedParseMessage("Starts With", parseResult))
	if not parseResult.error == OK:
		return []

	return parseResult.result

func _loadRhymesWords(dbFile: File) -> Array:
	dbFile.open(DB_PATH + RHYMES_DB, File.READ)
	var parseResult: JSONParseResult = JSON.parse(dbFile.get_as_text())

	assert(parseResult.error == OK, _getFailedParseMessage("Rhymes", parseResult))
	if not parseResult.error == OK:
		return []

	return parseResult.result

func _getFailedParseMessage(name: String, parseResult: JSONParseResult) -> String:
	return "'%s' - %s (line %s): %s" % [name, parseResult.error, parseResult.error_line, parseResult.error_string]

func _getAllUniqueWords() -> Array:
	var result: Array = []

	for wordArray in matchImageWords:
		for word in wordArray:
			if not word in result:
				result.append(word)

	for wordDictionary in startsWithWords:
		for word in wordDictionary.words:
			if not word in result:
				result.append(word)

	for wordArray in rhymesWords:
		for word in wordArray:
			if not word in result:
				result.append(word)

	result.sort()
	return result
