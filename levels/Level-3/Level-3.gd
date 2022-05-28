extends Level


# PRELOADS & CONSTS

# EXPORTS

# VARS
onready var quiz = $"CanvasLayer/Quiz-Hangman"
onready var quizGenerator = $QuizGenerator

# METHODS
func _ready():
	#quizGenerator.generateRhymesQuizSet(3, 3)
	quizGenerator.generateHangmanQuizSet(0.15)

func onPresentCollected() -> void:
	# Open quiz
	quiz.prepareQuiz(quiz.debugTarget, quiz.debugHintChars, quiz.debugNumAnswers)
	quiz.visible = true
	player.paused = true

func _on_Quiz_completed():
	# Wait 2 seconds, add 1 to score and continue the game
	quizCompleteTimer.start()
	yield(quizCompleteTimer, "timeout")
	score += 1
	scoreCounter.setScore(score)
	quiz.visible = false
	player.paused = false
