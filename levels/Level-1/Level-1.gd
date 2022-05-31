extends Level


# METHODS
func _ready():
	quizGenerator.generateMatchImageQuizSet()

func onPresentOpened(target: Present) -> void:
	.onPresentOpened(target)
	var nextQuiz: Dictionary = quizGenerator.getNextQuiz()
	quiz.prepareQuiz(nextQuiz.target, nextQuiz.extraAnswers)
