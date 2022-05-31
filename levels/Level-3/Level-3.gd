extends Level


# METHODS
func _ready():
	quizGenerator.clearQuizSets()
	quizGenerator.generateRhymesQuizSet(3, 3)
	quizGenerator.generateHangmanQuizSet(0.15)
	quizGenerator.randomizeQuizSets()
	setupPresentQuizzes()
