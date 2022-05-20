extends Level


# PRELOADS & CONSTS

# EXPORTS

# VARS
onready var quiz = $"CanvasLayer/Quiz-FourChoices-Syllables"

# METHODS
func onPresentCollected() -> void:
	# Open Syllables quiz
	quiz.prepareQuiz(quiz.debugTarget)
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
