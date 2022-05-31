extends Level


# METHODS
func _ready():
	#quizGenerator.generateRhymesQuizSet(3, 3)
	quizGenerator.generateHangmanQuizSet(0.15)

func onPresentOpened(target: Present) -> void:
	.onPresentOpened(target)
	var nextQuiz: Dictionary = quizGenerator.getNextQuiz()
	quiz.prepareQuiz(nextQuiz.target, nextQuiz.hiddenTarget, nextQuiz.answers)
