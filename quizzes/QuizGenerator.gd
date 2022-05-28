extends Node


# CONSTS
const HANGMAN_MAX_HINT_CHAR_RATIO = 0.5

# VARS
var quizSet: Array = []
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

# METHODS
func _init():
	randomize()
	rng.randomize()

# Generate a random set of "Match Image" quizzes
# Each quiz can be retrieved by calling `getNextQuiz()`
# These quizzes are `Dictionaries` with the properties:
# - `target` (`String`)
# - `extraAnswers` (`Array` of `Strings`)
func generateMatchImageQuizSet() -> void:
	self.quizSet.clear()

	JsonLoader.matchImageWords.shuffle()
	for wordSet in JsonLoader.matchImageWords:
		var quizDictionary: Dictionary = {}
		var tempWordSet: Array = wordSet.duplicate()

		# Set first word as target and remove it from the array
		quizDictionary.target = tempWordSet.pop_front()
		quizDictionary.extraAnswers = []

		# Shuffle remaining values and pick 3
		tempWordSet.shuffle()
		for i in range(3):
			quizDictionary.extraAnswers.append(tempWordSet[i])

		self.quizSet.append(quizDictionary)

# Generate a random set of "Starts With" quizzes
# Each quiz can be retrieved by calling `getNextQuiz()`
# These quizzes are `Dictionaries` with the properties:
# - `target` (`String`)
# - `answers` (`Array` of `Strings`)
# Each quiz generates with a total of `numOfCorrectAnswersPerQuiz + numOfWrongAnswersPerQuiz` answers
func generateStartsWithQuizSet(numOfCorrectAnswersPerQuiz: int, numOfWrongAnswersPerQuiz: int) -> void:
	self.quizSet.clear()

	JsonLoader.startsWithWords.shuffle()
	for wordSet in JsonLoader.startsWithWords:
		var quizDictionary: Dictionary = {}

		# Set target syllable and duplicate correct answers array
		quizDictionary.target = wordSet[JsonLoader.STARTS_WITH_SYLLABLE_PROP]
		quizDictionary.answers = []
		var correctAnswers: Array = wordSet[JsonLoader.STARTS_WITH_WORDS_PROP].duplicate()

		# Pick random correct answers
		var smallestNumOfCorrectAnswers: int = len(correctAnswers) if len(correctAnswers) < numOfCorrectAnswersPerQuiz else numOfCorrectAnswersPerQuiz
		correctAnswers.shuffle()
		for i in range(smallestNumOfCorrectAnswers):
			quizDictionary.answers.append(correctAnswers[i])

		# Pick random wrong answers
		quizDictionary.answers.append_array(_getExtraWords(numOfWrongAnswersPerQuiz, correctAnswers))

		quizDictionary.answers.shuffle()
		self.quizSet.append(quizDictionary)

# Generate a random set of "Rhymes" quizzes
# Each quiz can be retrieved by calling `getNextQuiz()`
# These quizzes are `Dictionaries` with the properties:
# - `target` (`String`)
# - `answers` (`Array` of `Strings`)
# Each quiz generates with a total of `numOfCorrectAnswersPerQuiz + numOfWrongAnswersPerQuiz` answers
func generateRhymesQuizSet(numOfCorrectAnswersPerQuiz: int, numOfWrongAnswersPerQuiz: int) -> void:
	self.quizSet.clear()

	JsonLoader.rhymesWords.shuffle()
	for wordSet in JsonLoader.rhymesWords:
		var quizDictionary: Dictionary = {}
		var correctAnswers: Array = wordSet.duplicate()

		# Set random correct word as target and remove it from the array
		correctAnswers.shuffle()
		quizDictionary.target = correctAnswers.pop_front()
		quizDictionary.answers = []

		# Pick random correct answers
		var smallestNumOfCorrectAnswers: int = len(correctAnswers) if len(correctAnswers) < numOfCorrectAnswersPerQuiz else numOfCorrectAnswersPerQuiz
		for i in range(smallestNumOfCorrectAnswers):
			quizDictionary.answers.append(correctAnswers[i])

		# Pick random wrong answers
		quizDictionary.answers.append_array(_getExtraWords(numOfWrongAnswersPerQuiz, correctAnswers))

		quizDictionary.answers.shuffle()
		self.quizSet.append(quizDictionary)

# Generate a set of random "Hangman" quizzes. Each quiz can be retrieved by calling `getNextQuiz()`
# Each quiz is a `Dictionary` with the properties:
# - `target` (`String`)
# - - taken from `match-image.json` DB file, as the first word of each set should have an image associated with it
# - `hiddenTarget` (`String`)
# - - a version of `target` with its characters replaced with underscores, with some exceptions (the hint characters)
# - - hint characters are calculated based on `ratioOfHintCharsPerQuiz`
# - `answers` (`Array` of `Strings`)
# - - the quiz answers (necessary correct + random wrong)
# - - array size is restricted to even numbers and between [target word's length + 2] and [target word's length x 2]
# `ratioOfHintCharsPerQuiz`:
# - represents the ratio of hint characters to the length of the target word
# - is a number restricted from 0 to `HANGMAN_MAX_HINT_CHAR_RATIO`
func generateHangmanQuizSet(ratioOfHintCharsPerQuiz: float) -> void:
	self.quizSet.clear()

	# Restrict `ratioOfHintCharsPerQuiz`
	ratioOfHintCharsPerQuiz = clamp(ratioOfHintCharsPerQuiz, 0, HANGMAN_MAX_HINT_CHAR_RATIO)

	JsonLoader.matchImageWords.shuffle()
	for wordSet in JsonLoader.matchImageWords:
		var quizDictionary: Dictionary = {}

		# Get integer number of hint characters
		var intNumOfHintChars: int = round(ratioOfHintCharsPerQuiz * wordSet[0].length()) as int

		# Set first word as target and create target with hidden characters
		quizDictionary.target = wordSet[0]
		quizDictionary.hiddenTarget = _generateTargetWithHintLetters(quizDictionary.target, intNumOfHintChars)

		# Randomize number of answers and restrict it to even numbers
		var numOfAnswers: int = rng.randi_range(quizDictionary.target.length() + 2, quizDictionary.target.length() * 2)
		if numOfAnswers & 1:
			numOfAnswers += 1

		# Create answers (missing correct characters + random characters)
		quizDictionary.answers = _generateHangmanAnswers(quizDictionary.target, quizDictionary.hiddenTarget, numOfAnswers)

		self.quizSet.append(quizDictionary)

# Generates a version of `targetWord` with `numOfHintChars` kept and with every other character replaced with underscores
func _generateTargetWithHintLetters(targetWord: String, numOfHintChars: int) -> String:
	var shownTargetWord: String = "_".repeat(targetWord.length())
	var chosenHintCharsIndexes: Array = []

	while chosenHintCharsIndexes.size() < numOfHintChars:
		# Choose character index that hasn't been chosen yet
		var charIndex: int = rng.randi_range(0, targetWord.length()-1)
		while chosenHintCharsIndexes.has(charIndex):
			charIndex = rng.randi_range(0, targetWord.length()-1)

		# Display target word's character at the chosen index
		shownTargetWord[charIndex] = targetWord[charIndex]
		chosenHintCharsIndexes.append(charIndex)

	return shownTargetWord

# Generates character answers for a "Hangman" quiz
# `targetWord` is the full target word (no hidden characters)
# `hiddenTargetWord` is the version of `targetWord` with hidden characters
# `numOfAnswers` is the total number of answers (necessary correct + random wrong) to be generated
func _generateHangmanAnswers(targetWord: String, hiddenTargetWord: String, numOfAnswers: int) -> Array:
	var answerChars: Array = []	# Holds the possible answers

	# Get hint character indexes
	var hintCharIndexes: Array = []
	for i in targetWord.length():
		if not hiddenTargetWord[i] == '_':
			hintCharIndexes.append(i)

	# Add target word's characters to possible answers, except for the hint characters
	for i in range(0, targetWord.length()):
		if not i in hintCharIndexes:
			answerChars.append(targetWord[i])

	# Randomize and add extra characters
	var numOfExtraChars = numOfAnswers - len(answerChars)
	while numOfExtraChars:
		var randomASCII: int = rng.randi_range(97, 122)	# ASCII values for range a-z
		answerChars.append(char(randomASCII))
		numOfExtraChars -= 1

	answerChars.shuffle()
	return answerChars

# Finds and returns `numOfExtraWords` random words from the DB files that do not exist in `excludedWords`
func _getExtraWords(numOfExtraWords: int, excludedWords: Array) -> Array:
	var extraAnswers: Array = []

	while len(extraAnswers) < numOfExtraWords:
		# Keep picking random words until the picked word does not exist in `excludedWords`
		var randomIndex: int = rng.randi_range(0, len(JsonLoader.allWords) - 1)
		while JsonLoader.allWords[randomIndex] in excludedWords:
			randomIndex = rng.randi_range(0, len(JsonLoader.allWords) - 1)

		extraAnswers.append(JsonLoader.allWords[randomIndex])

	return extraAnswers

# Gets the next quiz in the last generated set of quizzes
# Quiz sets can be generated with `generateMatchImageQuizSet()`, `generateStartsWithQuizSet()` and `generateHangmanQuizSet()`
# Returns an empty `Dictionary` if no quizzes have been generated or the last set of quizzes has been exhausted
func getNextQuiz() -> Dictionary:
	if not len(quizSet):
		return {}

	return quizSet.pop_front()
