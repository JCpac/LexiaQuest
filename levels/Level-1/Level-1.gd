extends Level


# PRELOADS & CONSTS

# EXPORTS

# VARS
onready var quiz = $"CanvasLayer/Quiz-FourChoices-Syllables"
onready var quizGenerator = $QuizGenerator

# METHODS
func _ready():
	quizGenerator.generateMatchImageQuizSet()

func onPresentCollected() -> void:
	# Open Syllables quiz
	quiz.prepareQuiz(quiz.debugTarget, quiz.debugAnswers)
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
