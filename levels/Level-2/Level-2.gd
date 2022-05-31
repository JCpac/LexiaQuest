extends Level


# METHODS
func _ready():
	quizGenerator.generateStartsWithQuizSet(3, 3)

func onPresentOpened(target: Present) -> void:
	.onPresentOpened(target)
	var nextQuiz: Dictionary = quizGenerator.getNextQuiz()
	quiz.prepareQuiz(nextQuiz.target, nextQuiz.correctAnswers, nextQuiz.wrongAnswers, quiz.SYLLABLES_QUIZ_TYPES.STARTS_WITH)
