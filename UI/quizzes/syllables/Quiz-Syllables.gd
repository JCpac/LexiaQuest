extends PanelContainer


# PRELOADS & CONSTS
const buttonQuizScene: PackedScene = preload("res://UI/Button/Quiz/Button-Quiz.tscn")

# SIGNALS
signal correct
signal wrong
signal completed

# EXPORTS
export(String) var startsWithText = "Seleciona as palavras que comecem com:"
export(String) var rhymesWithText = "Seleciona as palavras que rimem com:"
export(int) var minNumColumns = 1
export(int) var maxNumColumns = 4
export(String) var debugTarget = "fa"
export(Array) var debugCorrectAnswers: Array = [
	"family",
	"favourite",
	"father"
]
export(Array) var debugWrongAnswers: Array = [
	"language",
	"feather",
	"football"
]

# ENUMS
enum SYLLABLES_QUIZ_TYPES {STARTS_WITH, RHYMES_WITH}

# VARS
onready var explanationLabel: RichTextLabel = $QuizArea/VBoxContainer/Exercise/Explanation
onready var targetLabel: RichTextLabel = $QuizArea/VBoxContainer/Exercise/Target
onready var answerGrid: GridContainer = $QuizArea/VBoxContainer/Answers
var numCorrectAnswersLeft: int
var quizType

func _init():
	randomize()

func _ready():
	# If the quiz scene itself is played, automatically use debug values
	if OS.is_debug_build() and get_parent() == get_tree().root:
		prepareQuiz(debugTarget, debugCorrectAnswers, debugWrongAnswers, SYLLABLES_QUIZ_TYPES.STARTS_WITH)

# Assigns the quiz with a target word part and several possible answers
# Generates the quiz UI based on the provided values
# Assumes that at least 1 of the provided answers is correct
# Expects the elements of `correctAnswers` and `wrongAnswers` to be of type `String`
# `quizType` must be one of the values in the `SYLLABLES_QUIZ_TYPES` enumeration
func prepareQuiz(targetWordPart: String, correctAnswers: Array, wrongAnswers: Array, quizType) -> void:
	self.quizType = quizType
	self.targetLabel.bbcode_text = "[center][b]%s[/b][/center]" % targetWordPart
	self.numCorrectAnswersLeft = len(correctAnswers)

	# Set explanation label's content
	match quizType:
		SYLLABLES_QUIZ_TYPES.STARTS_WITH:
			self.explanationLabel.bbcode_text = "[center]%s[/center]" % self.startsWithText

		SYLLABLES_QUIZ_TYPES.RHYMES_WITH:
			self.explanationLabel.bbcode_text = "[center]%s[/center]" % self.rhymesWithText

		_:
			self.explanationLabel.bbcode_text = "[center]Algo correu mal ao gerar esta atividade[/center]"

	# Clear answer grid
	# (this quiz scene is instanced once per level and reused for each activity)
	for gridChild in answerGrid.get_children():
		gridChild.free()

	# Generate answer buttons and place them on the tree
	var buttonsArray: Array = _generateAnswerButtons(correctAnswers, wrongAnswers)
	for node in buttonsArray:
		answerGrid.add_child(node)

	print_debug("Quiz Syllables: Quiz prepared with target syllable '%s'" % targetWordPart)

# Instance `Button-Quiz` scenes and assign them the provided answers
func _generateAnswerButtons(correctAnswers: Array, wrongAnswers: Array) -> Array:
	var answerButtons: Array = []

	for answer in correctAnswers:
		var newButton: ButtonQuiz = buttonQuizScene.instance()
		newButton.text = answer
		newButton.isCorrect = true
		newButton.connect("pressed", self, "_on_AnswerButton_pressed", [newButton])
		answerButtons.append(newButton)

	for answer in wrongAnswers:
		var newButton: ButtonQuiz = buttonQuizScene.instance()
		newButton.text = answer
		newButton.isCorrect = false
		newButton.connect("pressed", self, "_on_AnswerButton_pressed", [newButton])
		answerButtons.append(newButton)

	answerButtons.shuffle()
	return answerButtons

func _validateAnswer(target: ButtonQuiz) -> bool:
	return target.isCorrect

func _on_AnswerButton_pressed(target: ButtonQuiz) -> void:
	target.revealState(true)

	if _validateAnswer(target):
		$CorrectSFX.play()
		numCorrectAnswersLeft -= 1
		emit_signal("correct")
		print_debug("Quiz Syllables: Answer '%s' was correct" % target.text)

		if not numCorrectAnswersLeft:
			_revealRemainingAnswers()
			emit_signal("completed")
			print_debug("Quiz Syllables: Quiz complete")
	else:
		$WrongSFX.play()
		emit_signal("wrong")
		print_debug("Quiz Syllables: Answer '%s' was wrong" % target.text)

# Reveals the unchosen wrong answers after quiz completion
func _revealRemainingAnswers() -> void:
	for button in answerGrid.get_children():
		if not button.disabled:
			button.revealState(false)
