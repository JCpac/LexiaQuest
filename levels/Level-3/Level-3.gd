extends Level


# METHODS
func _ready():
	QuizGenerator.clearQuizSets()
	QuizGenerator.generateRhymesWithQuizSet(3, 3)
	QuizGenerator.generateHangmanQuizSet(0.15)
	QuizGenerator.randomizeQuizSets()
	setupPresentQuizzes()
