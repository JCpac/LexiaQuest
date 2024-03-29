extends Node


# CONSTS
const HANGMAN_MAX_HINT_CHAR_RATIO = 0.5

# ENUMS
enum QUIZ_TYPES { MATCH_IMAGE, STARTS_WITH, RHYMES_WITH, HANGMAN }

# VARS
var _quizSet: Array = []
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()

# METHODS
func _init():
	randomize()
	_rng.randomize()

# Clear generated quiz sets
func clearQuizSets() -> void:
	_quizSet.clear()

# Randomize generated quiz sets
func randomizeQuizSets() -> void:
	_quizSet.shuffle()

# Gets the next quiz in the last generated set of quizzes
# Quiz sets can be generated with `generateMatchImageQuizSet()`, `generateStartsWithQuizSet()`, `generateRhymesWithQuizSet()` and `generateHangmanQuizSet()`
# Returns an empty `Dictionary` if no quizzes have been generated or the last set of quizzes has been exhausted
# If quizzes of multiple types have been generated, they can be distinguished with the property `quizType` (`QuizGenerator.QUIZ_TYPES`)
func getNextQuiz() -> Dictionary:
	if not len(_quizSet):
		return {}

	return _quizSet.pop_front()

# Generate a random set of "Match Image" quizzes. Each quiz can be retrieved by calling `getNextQuiz()`
# These quizzes are `Dictionaries` with the properties:
# - `quizType` (`QuizGenerator.QUIZ_TYPES.MATCH_IMAGE`)
# - `target` (`String`)
# - `extraAnswers` (`Array` of `Strings`)
func generateMatchImageQuizSet() -> void:
	MatchImageDB.words.shuffle()
	for wordSet in MatchImageDB.words:
		# Setup dictionary structure
		var quizDictionary: Dictionary = {}
		quizDictionary.quizType = QUIZ_TYPES.MATCH_IMAGE
		quizDictionary.target = ""
		quizDictionary.extraAnswers = []

		# Set first word as target and remove it from the array
		var tempWordSet: Array = wordSet.duplicate()
		quizDictionary.target = tempWordSet.pop_front()

		# Shuffle remaining values and pick 3
		tempWordSet.shuffle()
		for i in range(3):
			quizDictionary.extraAnswers.append(tempWordSet[i])

		_quizSet.append(quizDictionary)

# Generate a random set of "Starts With" quizzes. Each quiz can be retrieved by calling `getNextQuiz()`
# These quizzes are `Dictionaries` with the properties:
# - `quizType` (`QuizGenerator.QUIZ_TYPES.STARTS_WITH`)
# - `target` (`String`)
# - `correctAnswers` (`Array` of `Strings`)
# - `wrongAnswers` (`Array` of `Strings`)
# Each quiz generates with a total of `numOfCorrectAnswersPerQuiz + numOfWrongAnswersPerQuiz` answers
func generateStartsWithQuizSet(numOfCorrectAnswersPerQuiz: int, numOfWrongAnswersPerQuiz: int) -> void:
	StartsWithDB.words.shuffle()
	for wordSet in StartsWithDB.words:
		# Setup dictionary structure
		var quizDictionary: Dictionary = {}
		quizDictionary.quizType = QUIZ_TYPES.STARTS_WITH
		quizDictionary.target = ""
		quizDictionary.correctAnswers = []
		quizDictionary.wrongAnswers = []

		# Set target word part
		quizDictionary.target = wordSet[StartsWithDB.TARGET_PROP]

		# Duplicate correct answers array and pick random correct answers
		var correctAnswers: Array = wordSet[StartsWithDB.WORDS_PROP].duplicate()
		var smallestNumOfCorrectAnswers: int = len(correctAnswers) if len(correctAnswers) < numOfCorrectAnswersPerQuiz else numOfCorrectAnswersPerQuiz
		correctAnswers.shuffle()
		for i in range(smallestNumOfCorrectAnswers):
			quizDictionary.correctAnswers.append(correctAnswers[i])

		# Pick random extra answers and check if they're wrong,
		# until `numOfWrongAnswersPerQuiz` is met
		var wordsToExclude: Array = correctAnswers.duplicate()
		var aquiredExtraAnswers: Array = []
		while quizDictionary.wrongAnswers.size() < numOfWrongAnswersPerQuiz:
			aquiredExtraAnswers = _getExtraRandomWords(numOfWrongAnswersPerQuiz - quizDictionary.wrongAnswers.size(), wordsToExclude, QUIZ_TYPES.STARTS_WITH)

			# Find indexes of the random extra answers that aren't actually wrong
			var indexesToExclude: Array = []
			for i in range(aquiredExtraAnswers.size()):
				if (aquiredExtraAnswers[i] as String).begins_with(quizDictionary.target):
					indexesToExclude.append(i)

			# Exclude accidental correct answers
			for i in indexesToExclude:
				wordsToExclude.append(aquiredExtraAnswers.pop_at(i))

			# Place actually wrong answers into quiz dictionary
			quizDictionary.wrongAnswers.append_array(aquiredExtraAnswers)
			aquiredExtraAnswers.clear()

		_quizSet.append(quizDictionary)

# Generate a random set of "Rhymes With" quizzes. Each quiz can be retrieved by calling `getNextQuiz()`
# These quizzes are `Dictionaries` with the properties:
# - `quizType` (`QuizGenerator.QUIZ_TYPES.RHYMES_WITH`)
# - `target` (`String`)
# - `correctAnswers` (`Array` of `Strings`)
# - `wrongAnswers` (`Array` of `Strings`)
# Each quiz generates with a total of `numOfCorrectAnswersPerQuiz + numOfWrongAnswersPerQuiz` answers
func generateRhymesWithQuizSet(numOfCorrectAnswersPerQuiz: int, numOfWrongAnswersPerQuiz: int) -> void:
	RhymesWithDB.words.shuffle()
	for wordSet in RhymesWithDB.words:
		# Setup dictionary structure
		var quizDictionary: Dictionary = {}
		quizDictionary.quizType = QUIZ_TYPES.RHYMES_WITH
		quizDictionary.target = ""
		quizDictionary.correctAnswers = []
		quizDictionary.wrongAnswers = []

		# Duplicate correct answers array,
		# set random correct word as target and remove it from the array
		var correctAnswers: Array = wordSet.duplicate()
		var wordsToExclude: Array = correctAnswers.duplicate()
		correctAnswers.shuffle()
		quizDictionary.target = correctAnswers.pop_front()

		# Pick random correct answers
		var smallestNumOfCorrectAnswers: int = len(correctAnswers) if len(correctAnswers) < numOfCorrectAnswersPerQuiz else numOfCorrectAnswersPerQuiz
		for i in range(smallestNumOfCorrectAnswers):
			quizDictionary.correctAnswers.append(correctAnswers[i])

		# Pick random wrong answers
		quizDictionary.wrongAnswers = _getExtraRandomWords(numOfWrongAnswersPerQuiz, wordsToExclude, QUIZ_TYPES.RHYMES_WITH)

		_quizSet.append(quizDictionary)

# Generate a set of random "Hangman" quizzes. Each quiz can be retrieved by calling `getNextQuiz()`
# Each quiz is a `Dictionary` with the properties:
# - `quizType` (`QuizGenerator.QUIZ_TYPES.HANGMAN`)
# - `target` (`String`)
# - - taken from `match-image.json` DB file, as the first word of each set should have an image associated with it
# - `hiddenTarget` (`String`)
# - - a version of `target` with its characters replaced with underscores, with some exceptions (the hint characters)
# - - hint characters are calculated based on `ratioOfHintCharsPerQuiz`
# - `answers` (`Array` of `Strings`)
# - - the quiz answers (necessary missing characters + random characters)
# - - array size is restricted to even numbers and between [target word's length + 2] and [target word's length x 2]
# `ratioOfHintCharsPerQuiz`:
# - represents the ratio of hint characters to the length of the target word
# - is a number restricted from 0 to `HANGMAN_MAX_HINT_CHAR_RATIO`
func generateHangmanQuizSet(ratioOfHintCharsPerQuiz: float) -> void:
	# Restrict `ratioOfHintCharsPerQuiz`
	ratioOfHintCharsPerQuiz = clamp(ratioOfHintCharsPerQuiz, 0, HANGMAN_MAX_HINT_CHAR_RATIO)

	MatchImageDB.words.shuffle()
	for wordSet in MatchImageDB.words:
		# Setup dictionary structure
		var quizDictionary: Dictionary = {}
		quizDictionary.quizType = QUIZ_TYPES.HANGMAN
		quizDictionary.target = ""
		quizDictionary.hiddenTarget = ""
		quizDictionary.answers = []

		# Set first word as target
		quizDictionary.target = wordSet[0]

		# Create target with hidden characters
		var intNumOfHintChars: int = round(ratioOfHintCharsPerQuiz * wordSet[0].length()) as int
		quizDictionary.hiddenTarget = _generateTargetWithHintLetters(quizDictionary.target, intNumOfHintChars)

		# Randomize number of answers and restrict it to even numbers
		var numOfAnswers: int = _rng.randi_range(quizDictionary.target.length() + 2, quizDictionary.target.length() * 2)
		if numOfAnswers & 1:
			numOfAnswers += 1

		# Create answers (necessary missing characters + random characters)
		quizDictionary.answers = _generateHangmanAnswers(quizDictionary.target, quizDictionary.hiddenTarget, numOfAnswers)

		_quizSet.append(quizDictionary)

# Generates a version of `targetWord` with `numOfHintChars` kept and with every other character replaced with underscores
func _generateTargetWithHintLetters(targetWord: String, numOfHintChars: int) -> String:
	var shownTargetWord: String = "_".repeat(targetWord.length())
	var chosenHintCharsIndexes: Array = []

	while chosenHintCharsIndexes.size() < numOfHintChars:
		# Choose character index that hasn't been chosen yet
		var charIndex: int = _rng.randi_range(0, targetWord.length()-1)
		while chosenHintCharsIndexes.has(charIndex):
			charIndex = _rng.randi_range(0, targetWord.length()-1)

		# Display target word's character at the chosen index
		shownTargetWord[charIndex] = targetWord[charIndex]
		chosenHintCharsIndexes.append(charIndex)

	return shownTargetWord

# Generates character answers for a "Hangman" quiz
# `targetWord` is the full target word (no hidden characters)
# `hiddenTargetWord` is the version of `targetWord` with hidden characters
# `numOfAnswers` is the total number of answers (necessary missing characters + random characters) to be generated
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
		var randomASCII: int = _rng.randi_range(97, 122)	# ASCII values for range a-z
		answerChars.append(char(randomASCII))
		numOfExtraChars -= 1

	answerChars.shuffle()
	return answerChars

# Finds and returns `numOfExtraWords` random words from the DB files that do not exist in `wordsToExclude`
func _getExtraRandomWords(numOfExtraWords: int, wordsToExclude: Array, quizType) -> Array:
	var extraAnswers: Array = []

	match quizType:
		QUIZ_TYPES.STARTS_WITH:
			while len(extraAnswers) < numOfExtraWords:
				# Keep picking random words until the picked word does not exist in `wordsToExclude`
				var randomIndex: int = _rng.randi_range(0, len(AllDB.words) - 1)
				while AllDB.words[randomIndex] in wordsToExclude:
					randomIndex = _rng.randi_range(0, len(AllDB.words) - 1)

				extraAnswers.append(AllDB.words[randomIndex])

		# Prevent "Rhymes With" quizzes from retrieving wrong answers from all files,
		# so that rhyme maintenance is restricted to the `Rhymes-With.gd` file, instead of all DB files
		QUIZ_TYPES.RHYMES_WITH:
			# Duplicate rhymes DB and remove set of words that correspond to the words in `wordsToExclude`
			var rhymeWordSets: Array = RhymesWithDB.words.duplicate(true)
			var breakOutOfOuterLoop: bool = false
			for wordSet in rhymeWordSets:
				if breakOutOfOuterLoop:
					break;

				for word in wordSet:
					if word in wordsToExclude:
						rhymeWordSets.erase(wordSet)
						breakOutOfOuterLoop = true
						break;

			while len(extraAnswers) < numOfExtraWords:
				# Pick a random word from a random word set
				var randomSetIndex: int = _rng.randi_range(0, len(rhymeWordSets) - 1)
				var randomSet: Array = rhymeWordSets[randomSetIndex]
				var randomWordIndex: int = _rng.randi_range(0, len(randomSet) - 1)
				var randomWord: String = randomSet[randomWordIndex]

				extraAnswers.append(randomWord)

		_:
			assert(false, "Other quiz types are not meant to call this method")

	return extraAnswers
