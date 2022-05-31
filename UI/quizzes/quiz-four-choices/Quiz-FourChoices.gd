extends PanelContainer


# PRELOADS & CONSTS

# SIGNALS
signal completed
signal wrong

# EXPORTS
export(String) var debugTarget = "ball"
export(Array, String) var debugExtraAnswers: Array = ["bull", "beach", "tall"]

# VARS
onready var targetImage: TextureRect = $QuizArea/VBoxContainer/HBoxContainer/Image/TextureRect
onready var answerList: VBoxContainer = $QuizArea/VBoxContainer/HBoxContainer/Answers
var target: String

# METHODS
func _init():
	randomize()

func _ready():
	_setButtonSignalConnections()

	# If the quiz scene itself is played, automatically use debug values
	if OS.is_debug_build() and get_parent() == get_tree().root:
		prepareQuiz(debugTarget, debugExtraAnswers)

func _setButtonSignalConnections() -> void:
	for button in answerList.get_children():
		button.connect("pressed", self, "_on_AnswerButton_pressed", [button])

# Assigns the quiz with a target word/image and several possible answers
# Generates the quiz UI based on the provided values
# Assumes that the provided target word has a matching image asset
# Expects the elements of `extraAnswersArray` to be of type `String`
func prepareQuiz(targetWord: String, extraAnswersArray: Array) -> void:
	self.target = targetWord
	self.targetImage.texture = load("res://assets/Database/Images/%s.jpg" % targetWord)

	# Join target word and extra answers
	var allAnswers: Array = extraAnswersArray.duplicate()
	allAnswers.append(targetWord)

	# Prepare answer buttons
	allAnswers.shuffle()
	var answerButtons: Array = answerList.get_children()
	for i in range(4):
		var answer: String = allAnswers[i]
		var buttonQuiz: ButtonQuiz = answerButtons[i]
		buttonQuiz.setUp(answer, answer == targetWord)

	print_debug("Quiz Four Choices: Quiz prepared with target word/image '%s'" % targetWord)

func _on_AnswerButton_pressed(target: ButtonQuiz) -> void:
	target.revealState(true)

	if _validateAnswer(target):
		_revealRemainingAnswers()
		emit_signal("completed")
		print_debug("Quiz Syllables: Answer '%s' was correct" % target.text)
	else:
		emit_signal("wrong")
		print_debug("Quiz Syllables: Answer '%s' was wrong" % target.text)

func _validateAnswer(target: ButtonQuiz) -> bool:
	return target.isCorrect

# Reveals the unchosen wrong answers after quiz completion
func _revealRemainingAnswers() -> void:
	for buttonQuiz in answerList.get_children():
		if not buttonQuiz.disabled:
			buttonQuiz.revealState(false)
