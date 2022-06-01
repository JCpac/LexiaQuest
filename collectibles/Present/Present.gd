class_name Present extends Node2D


# SIGNALS
signal opened
signal collected

# EXPORTS
export(int, 0, 64) var _spriteHoverLimit: int = 20
export(float, 0, 10) var _spriteHoverSpeed: float = 0.5

# CONSTS
const _quizPaths: Dictionary = {
	matchImage = "res://UI/quizzes/quiz-four-choices/Quiz-FourChoices.tscn",
	matchWord = "res://UI/quizzes/syllables/Quiz-Syllables.tscn",
	hangman = "res://UI/quizzes/quiz-hangman/Quiz-Hangman.tscn"
}

# VARS
var quiz: Dictionary = {} setget _setQuiz

onready var _sprite: Sprite = $Sprite
onready var _quizNodes: Dictionary = {}
var _spriteHoverDirection: int = 1

# METHODS
func _process(_delta):
	_spriteHoverProcess()

func _spriteHoverProcess() -> void:
	if not is_instance_valid(_sprite):
		return

	_sprite.offset.y += _spriteHoverSpeed if _spriteHoverDirection == 1 else -_spriteHoverSpeed

	if ((_spriteHoverDirection == 1 and _spriteHoverLimit <= _sprite.offset.y)
	or (_spriteHoverDirection == -1 and -_spriteHoverLimit >= _sprite.offset.y)):
		_spriteHoverDirection = -_spriteHoverDirection

func _setQuiz(quizValue: Dictionary) -> void:
	quiz = quizValue

	var quizNode
	match quiz.quizType:
		QuizGenerator.QUIZ_TYPES.MATCH_IMAGE:
			quizNode = load(_quizPaths.matchImage).instance()
			_quizNodes.matchImage = quizNode

		QuizGenerator.QUIZ_TYPES.STARTS_WITH, QuizGenerator.QUIZ_TYPES.RHYMES_WITH:
			quizNode = load(_quizPaths.matchWord).instance()
			_quizNodes.matchWord = quizNode

		QuizGenerator.QUIZ_TYPES.HANGMAN:
			quizNode = load(_quizPaths.hangman).instance()
			_quizNodes.hangman = quizNode

		_:
			assert(false, "The value '%s' does not exist in 'QuizGenerator.QUIZ_TYPES'" % quiz.quizType)

	quizNode.visible = false
	quizNode.connect("correct", self, "_onQuizCorrectAnswer")
	quizNode.connect("wrong", self, "_onQuizWrongAnswer")
	quizNode.connect("completed", self, "_onQuizCompleted", [quizNode])
	$CanvasLayer.add_child(quizNode)

# SIGNAL CALLBACKS
func _onPlayerTouched(_body: Node):
	$OpenSFX.play()

	match quiz.quizType:
		QuizGenerator.QUIZ_TYPES.MATCH_IMAGE:
			_quizNodes.matchImage.prepareQuiz(quiz.target, quiz.extraAnswers)
			_quizNodes.matchImage.visible = true

		QuizGenerator.QUIZ_TYPES.STARTS_WITH:
			_quizNodes.matchWord.prepareQuiz(quiz.target, quiz.correctAnswers, quiz.wrongAnswers, quiz.quizType)
			_quizNodes.matchWord.visible = true

		QuizGenerator.QUIZ_TYPES.RHYMES_WITH:
			_quizNodes.matchWord.prepareQuiz(quiz.target, quiz.correctAnswers, quiz.wrongAnswers, quiz.quizType)
			_quizNodes.matchWord.visible = true

		QuizGenerator.QUIZ_TYPES.HANGMAN:
			_quizNodes.hangman.prepareQuiz(quiz.target, quiz.hiddenTarget, quiz.answers)
			_quizNodes.hangman.visible = true

		_:
			assert(false, "The value '%s' does not exist in 'QuizGenerator.QUIZ_TYPES'" % quiz.quizType)

	emit_signal("opened")

func _onQuizCorrectAnswer():
	$CorrectSFX.play()

func _onQuizWrongAnswer():
	$WrongSFX.play()

func _onQuizCompleted(quizNode):
	var timer: Timer = $QuizCompleteTimer
	timer.start()
	yield(timer, "timeout")

	$CollectedSFX.play()
	$Area2D.queue_free()
	$Sprite.texture = load("res://assets/Sprites/presents/Present-Open.png")
	quizNode.queue_free()
	emit_signal("collected")
