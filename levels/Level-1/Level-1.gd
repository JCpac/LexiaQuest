extends Level


# METHODS
func _ready():
	QuizGenerator.clearQuizSets()
	QuizGenerator.generateMatchImageQuizSet()
	setupPresentQuizzes()
