extends Level


# METHODS
func _ready():
	quizGenerator.clearQuizSets()
	quizGenerator.generateStartsWithQuizSet(3, 3)
	setupPresentQuizzes()
