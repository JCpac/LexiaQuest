extends PanelContainer


# PRELOADS & CONSTS

# SIGNALS
signal correct
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

	# Join target word and extra answers
	var allAnswers: Array = extraAnswersArray.duplicate()
	allAnswers.append(targetWord)

	# Prepare answer buttons
	allAnswers.shuffle()
	var answerButtons: Array = answerList.get_children()
	for i in range(4):
		(answerButtons[i] as Button).text = allAnswers[i]

	print_debug("Quiz Four Choices: Quiz prepared with target word/image '%s'" % targetWord)

func _validateAnswer(answer: String) -> bool:
	return self.target == answer

func _on_AnswerButton_pressed(target: Button) -> void:
	if _validateAnswer(target.text):
		target.setCorrect()
		_revealRemainingAnswers()
		emit_signal("correct")
		print_debug("Quiz Syllables: Answer '%s' was correct" % target.text)
	else:
		target.setWrong(true)
		emit_signal("wrong")
		print_debug("Quiz Syllables: Answer '%s' was wrong" % target.text)

# Reveals the unchosen wrong answers after quiz completion
func _revealRemainingAnswers() -> void:
	for buttonWord in answerList.get_children():
		if not buttonWord.disabled:
			buttonWord.setWrong(false)
