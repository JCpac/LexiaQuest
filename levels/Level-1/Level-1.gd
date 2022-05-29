extends Level


# PRELOADS & CONSTS

# EXPORTS

# VARS
onready var quiz = get_node("CanvasLayer/Quiz-FourChoices")
onready var quizGenerator = $QuizGenerator

# METHODS
func _ready():
	quizGenerator.generateMatchImageQuizSet()

func onPresentCollected() -> void:
	# Open quiz
	var nextQuiz: Dictionary = quizGenerator.getNextQuiz()
	quiz.prepareQuiz(nextQuiz.target, nextQuiz.extraAnswers)
	quiz.visible = true
	player.paused = true

func _on_Quiz_correct():
	# Wait 2 seconds, add 1 to score and continue the game
	quizCompleteTimer.start()
	yield(quizCompleteTimer, "timeout")
	score += 1
	scoreCounter.setScore(score)
	quiz.visible = false
	player.paused = false
