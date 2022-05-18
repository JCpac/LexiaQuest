extends PanelContainer


# PRELOADS & CONSTS
const MIN_NUM_ANSWERS = 2
const MAX_NUM_ANSWERS = 10

# SIGNALS
signal correct
signal wrong
signal completed

# EXPORTS
export(int) var minNumColumns = 1
export(int) var maxNumColumns = 4
export(String) var debugTarget = "ball"
export(int, 0, 10) var debugHintChars = 1
export(int, 2, 10) var debugNumAnswers = 6

# VARS
onready var targetImage: TextureRect = $QuizArea/HBoxContainer/LeftSide/Image/TextureRect
onready var targetLabel: Label = $QuizArea/HBoxContainer/RightSide/VBoxContainer/Target
onready var answerGrid: GridContainer = $QuizArea/HBoxContainer/RightSide/VBoxContainer/Answers
onready var answerButton: Button = $QuizArea/HBoxContainer/RightSide/VBoxContainer/Answers/Answer1
var target: String
var rng: RandomNumberGenerator

func _ready():
	rng = RandomNumberGenerator.new()
	rng.randomize()
	if OS.is_debug_build() and get_parent() == get_tree().root:
		prepareQuiz(debugTarget, debugHintChars, debugNumAnswers)

func _gui_input(event):
	if event is InputEventKey:
		if event.is_action_pressed("ui_accept"):
			if _validateAnswer():
				emit_signal("correct")

				print_debug("Quiz Write Prompt was correct")
			else:
				emit_signal("wrong")

				print_debug("Quiz Write Prompt was wrong")

func prepareQuiz(targetWord: String, numOfHintChars: int, numOfAnswerButtons: int) -> void:
	self.target = targetWord

	# Set target image
	targetImage.texture = load("res://assets/Database/Images/%s.jpg" % targetWord)

	# Restrict `numOfHintChars` and set target word display with random hint characters
	var targetHalfLength: int = target.length() >> 1
	if numOfHintChars < 0:
		numOfHintChars = 0
	elif numOfHintChars > targetHalfLength:
		numOfHintChars = targetHalfLength
	targetLabel.text = _generateTargetWithHintLetters(targetWord, numOfHintChars)

	# Restrict `numOfAnswerButtons` to their assigned range and to even numbers
	if numOfAnswerButtons & 1:
		numOfAnswerButtons += 1
	if numOfAnswerButtons < MIN_NUM_ANSWERS:
		numOfAnswerButtons = MIN_NUM_ANSWERS
	elif numOfAnswerButtons > MAX_NUM_ANSWERS:
		numOfAnswerButtons = MAX_NUM_ANSWERS

	# Get hint character indexes
	var hintCharIndexes: Array = []
	for i in targetWord.length():
		if not targetLabel.text[i] == '_':
			hintCharIndexes.append(i)

	# Generate answer buttons and place them on the tree, while also removing the placeholder button
	var buttonsArray: Array = _generateAnswerButtons(targetWord, numOfAnswerButtons, hintCharIndexes)
	answerGrid.remove_child(answerButton)
	answerButton.queue_free()
	for node in buttonsArray:
		answerGrid.add_child(node)

	# Calculate new appropriate grid size (floored half of the number of answers)
	var newNumOfColumns: int = numOfAnswerButtons >> 1
	if newNumOfColumns < minNumColumns:
		newNumOfColumns = minNumColumns
	elif newNumOfColumns > maxNumColumns:
		newNumOfColumns = maxNumColumns
	answerGrid.columns = newNumOfColumns

func _generateTargetWithHintLetters(targetWord: String, numOfHintChars: int) -> String:
	var shownTargetWord: String = "_".repeat(targetWord.length())
	var chosenHintCharsIndexes: Array = []

	while chosenHintCharsIndexes.size() < numOfHintChars:
		# Choose character index that hasn't been chosen yet
		var charIndex: int = rng.randi_range(0, targetWord.length()-1)
		while chosenHintCharsIndexes.has(charIndex):
			charIndex = rng.randi_range(0, targetWord.length()-1)

		# Display target word's character at the chosen index
		shownTargetWord[charIndex] = targetWord[charIndex]
		chosenHintCharsIndexes.append(charIndex)

	return shownTargetWord

func _generateAnswerButtons(targetWord: String, numOfAnswerButtons: int, hintCharIndexes: Array) -> Array:
	var answerChars: Array = []	# Holds the possible answers
	var answerButtons: Array = []	# Holds the buttons with the possible answers

	# Add target word's characters to possible answers, except for the hint characters
	var tempTargetWord: Array = []
	for i in range(0, targetWord.length()):
		if not i in hintCharIndexes:
			tempTargetWord.append(targetWord[i])
	answerChars = tempTargetWord

	# Randomize and add extra characters
	var numOfExtraChars = numOfAnswerButtons - len(answerChars)
	while numOfExtraChars:
		var randomASCII: int = rng.randi_range(97, 122)	# ASCII values for range a-z
		answerChars.append(char(randomASCII))
		numOfExtraChars -= 1

	# Shuffle answer characters array and create buttons
	answerChars.shuffle()
	for i in answerChars:
		# Generate duplicate buttons and assign them values
		var newButton: Button = answerButton.duplicate()
		newButton.text = i
		answerButtons.append(newButton)

	return answerButtons

func _validateAnswer() -> bool:
	return true
