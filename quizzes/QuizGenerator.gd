extends Node


# VARS
var quizSet: Array = []
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

# METHODS
func _init():
	randomize()
	rng.randomize()

# Generate a random set of "Match Image" quizzes
# Each quiz can be retrieved be calling `getNextQuiz()`
# These quizzes are `Dictionaries` with the properties `target` (`String`) and `extraAnswers` (`Array` of `Strings`)
func generateMatchImageQuizSet() -> void:
	self.quizSet.clear()

	JsonLoader.matchImageWords.shuffle()
	for wordSet in JsonLoader.matchImageWords:
		var quizDictionary: Dictionary = {}
		var tempWordSet: Array = wordSet.duplicate()

		# Set first word as target
		quizDictionary.target = tempWordSet.pop_front()
		quizDictionary.extraAnswers = []

		# Shuffle remaining values and pick 3
		tempWordSet.shuffle()
		for i in range(3):
			quizDictionary.extraAnswers.append(tempWordSet[i])

		self.quizSet.append(quizDictionary)

# Generate a random set of "Starts With" quizzes
# Each quiz can be retrieved be calling `getNextQuiz()`
# These quizzes are `Dictionaries` with the properties `target` (`String`) and `answers` (`Array` of `Strings`)
# Each quiz has a total of `numOfCorrectAnswersPerQuiz + numOfWrongAnswersPerQuiz` answers
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
# Quiz sets can be generated with `generateMatchImageQuizSet()` and `generateStartsWithQuizSet()`
# Returns an empty `Dictionary` if no quizzes have been generated or the last set of quizzes has been exhausted
func getNextQuiz() -> Dictionary:
	if not len(quizSet):
		return {}
	
	return quizSet.pop_front()
