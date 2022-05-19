extends PanelContainer


# PRELOADS & CONSTS

# SIGNALS
signal correct
signal wrong

# EXPORTS
export(String) var debugTarget = "ball"
export(Array, String) var debugExtraAnswers: Array = ["bull", "beach", "bail"]

# VARS
onready var targetLabel: RichTextLabel = $QuizArea/VBoxContainer/Exercise/Target
onready var answerGrid: GridContainer = $QuizArea/VBoxContainer/Answers
onready var placeholderAnswerButton: Button = $QuizArea/VBoxContainer/Answers/Answer1
var target: String
var rng: RandomNumberGenerator

func _ready():
	rng = RandomNumberGenerator.new()
	rng.randomize()
	if OS.is_debug_build() and get_parent() == get_tree().root:
		prepareQuiz(debugTarget)

func prepareQuiz(targetWord: String) -> void:
	self.target = targetWord

	# Generate answer buttons and place them on the tree, while also removing the placeholder button
	var buttonsArray: Array = _generateAnswerButtons(targetWord)
	answerGrid.remove_child(placeholderAnswerButton)
	placeholderAnswerButton.queue_free()
	for node in buttonsArray:
		answerGrid.add_child(node)

func _generateAnswerButtons(targetWord: String) -> Array:
	var answerStrings: Array = []	# Holds the possible answers
	var answerButtons: Array = []	# Holds the buttons with the possible answers

	# Add target word to possible answers
	answerStrings.append(targetWord)

	# Randomize and add extra answers
	var numOfExtraStrings = 3
	if OS.is_debug_build():
		answerStrings.append_array(debugExtraAnswers)
	else:
		while numOfExtraStrings:
			# TODO: DO SOMETHING HERE AFTER MAKING WORD DB
			# answerChars.append(char(randomASCII))
			# numOfExtraChars -= 1
			pass

	# Shuffle answer strings array and create buttons
	answerStrings.shuffle()
	for i in answerStrings:
		# Generate duplicate buttons and assign them values
		var newButton: Button = placeholderAnswerButton.duplicate()
		newButton.text = i
		newButton.connect("pressed", self, "_on_AnswerButton_pressed", [i])
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
