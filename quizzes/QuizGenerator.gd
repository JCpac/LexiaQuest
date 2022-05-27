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
		var tempWordSet: Array = wordSet.duplicate(true)

		# Set first word as target
		quizDictionary.target = tempWordSet.pop_front()
		quizDictionary.extraAnswers = []

		# Shuffle remaining values and pick 3
		tempWordSet.shuffle()
		for i in range(3):
			quizDictionary.extraAnswers.append(tempWordSet[i])

		self.quizSet.append(quizDictionary)

# Gets the next quiz in the last set of generated quizzes
# Quiz sets can be generated with `generateMatchImageQuizSet()`
# Returns an empty array if no quizzes have been generated
func getNextQuiz() -> Array:
	return []
