class_name Word


# VARS
var word: String = ""
var syllables: Array = []

# METHODS
func _init(syllablesArray: Array, fullWord: String = ""):
	# Build the full word from the given syllables
	var wordFromSyllables: String = ""
	for syllable in syllablesArray:
		# Check if array elements are non-empty Strings
		if not syllable is String or syllable.empty():
			print_debug("Syllables %s are not all non-empty Strings" % [syllablesArray])
			return

		wordFromSyllables += syllable

	# If the given word is not empty, but it doesn't match the given syllables,
	# print a debug statement and return, keeping the instance invalid
	if not fullWord.empty() and not fullWord == wordFromSyllables:
		print_debug("Word '%s' doesn't match the syllables [%s]" % [fullWord, syllablesArray])
		return

	self.word = wordFromSyllables
	self.syllables = syllablesArray

func isValid() -> bool:
	return not self.word.empty() and not syllables == []
