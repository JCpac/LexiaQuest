extends Level


# METHODS
func _ready():
	quizGenerator.clearQuizSets()
	quizGenerator.generateMatchImageQuizSet()
	setupPresentQuizzes()
