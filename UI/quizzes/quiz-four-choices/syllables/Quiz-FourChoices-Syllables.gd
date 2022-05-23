extends PanelContainer


# PRELOADS & CONSTS
const buttonWordScene: PackedScene = preload("res://UI/Button/Word/Button-Word.tscn")

# SIGNALS
signal correct
signal wrong
signal complete

# EXPORTS
export(int) var minNumColumns = 1
export(int) var maxNumColumns = 4
export(String) var debugTarget = "fa"
export(Array) var debugAnswers: Array = [
	Word.new(["fa", "mi", "ly"], "family"),
	Word.new(["fa", "vo", "rite"], "favorite"),
	Word.new(["fa", "ther"], "father"),
	Word.new(["lan", "guage"], "language"),
	Word.new(["fea", "ther"], "feather"),
	Word.new(["foot", "ball"], "football")
]

# VARS
onready var targetLabel: RichTextLabel = $QuizArea/VBoxContainer/Exercise/Target
onready var answerGrid: GridContainer = $QuizArea/VBoxContainer/Answers
var target: String
var numCorrectAnswersLeft: int

func _init():
	randomize()

func _ready():
	# If the quiz scene itself is played, automatically use debug values
	if OS.is_debug_build() and get_parent() == get_tree().root:
		prepareQuiz(debugTarget, debugAnswers)

# Assigns the quiz with a target syllable and several possible answers
# Generates the quiz UI based on the provided values
# Assumes that at least 1 of the provided answers is correct
# Expects the elements of `answersArray` to be of type `Word`
func prepareQuiz(targetSyllable: String, answersArray: Array) -> void:
	answersArray.shuffle()

	self.target = targetSyllable
	self.numCorrectAnswersLeft = _countCorrectAnswers(targetSyllable, answersArray)

	# Clear answer grid
	# (this quiz scene is instanced once per level and reused for each activity)
	for gridChild in answerGrid.get_children():
		gridChild.free()

	# Generate answer buttons and place them on the tree
	var buttonsArray: Array = _generateAnswerButtons(answersArray)
	for node in buttonsArray:
		answerGrid.add_child(node)

# Count how many of the provided answers match the provided target syllable
func _countCorrectAnswers(targetSyllable: String, answersArray: Array) -> int:
	var count: int = 0
	for answer in answersArray:
		if targetSyllable == (answer as Word).syllables[0]:
			count += 1
	return count

# Instance `Button-Word` scenes and assign them the provided `Word` instances
func _generateAnswerButtons(answersArray: Array) -> Array:
	var answerButtons: Array = []

	for answer in answersArray:
		var newButton: Button = buttonWordScene.instance()
		newButton.word = answer
		newButton.text = newButton.word.word
		newButton.connect("pressed", self, "_on_AnswerButton_pressed")
		answerButtons.append(newButton)

	return answerButtons

func _validateAnswer(answer: String) -> bool:
	return answer == target

func _on_AnswerButton_pressed(value: String) -> void:
	if _validateAnswer(value):
		emit_signal("correct")
		print_debug("Quiz 4 Choices Syllables: Answer '%s' was correct" % value)
	else:
		emit_signal("wrong")
		print_debug("Quiz 4 Choices Syllables: Answer '%s' was wrong" % value)
