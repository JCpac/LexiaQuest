extends PanelContainer


# PRELOADS & CONSTS
const buttonLetterScene: PackedScene = preload("res://UI/Button/Letter/Button-Letter.tscn")

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
var target: String
var rng: RandomNumberGenerator

# METHODS
func _init():
	randomize()

func _ready():
	rng = RandomNumberGenerator.new()
	rng.randomize()

	# If the quiz scene itself is played, automatically use debug values
	if OS.is_debug_build() and get_parent() == get_tree().root:
		prepareQuiz(debugTarget, debugHintChars, debugNumAnswers)

# Assigns the quiz with a target word and several possible answer letters to complete the word
# Generates the quiz UI based on the provided values
# Assumes that all correct letters are provided
# `numOfHintChars` is, at most, half the length of the target word
# `numOfAnswerButtons` is restricted to even numbers and between [target word's length + 2] and [target word's length x 2]
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

	# Restrict `numOfAnswerButtons` to its assigned range and to even numbers
	if numOfAnswerButtons & 1:
		numOfAnswerButtons += 1
	if numOfAnswerButtons < targetWord.length() + 2:
		numOfAnswerButtons = targetWord.length() + 2
	elif numOfAnswerButtons > targetWord.length() << 1:
		numOfAnswerButtons = targetWord.length() << 1

	# Get hint character indexes
	var hintCharIndexes: Array = []
	for i in targetWord.length():
		if not targetLabel.text[i] == '_':
			hintCharIndexes.append(i)

	# Clear answer grid
	# (this quiz scene is instanced once per level and reused for each activity)
	for gridChild in answerGrid.get_children():
		gridChild.free()

	# Generate answer buttons and place them on the tree
	var buttonsArray: Array = _generateAnswerButtons(targetWord, numOfAnswerButtons, hintCharIndexes)
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
		var newButton: Button = buttonLetterScene.instance()
		newButton.text = i
		newButton.connect("pressed", self, "_on_AnswerButton_pressed", [newButton])
		answerButtons.append(newButton)

	return answerButtons

func _validateTargetIsComplete() -> bool:
	return self.target == targetLabel.text

func _on_AnswerButton_pressed(target: Button) -> void:
	var letterMatchIndex: int = _validateAnswer(target.text)
	if not letterMatchIndex == -1:
		targetLabel.text[letterMatchIndex] = target.text	# Reveal character in target word's label
		target.setCorrect()
		emit_signal("correct")
		print_debug("Quiz Hangman: Letter '%s' was correct" % target.text)

		if _validateTargetIsComplete():
			_revealRemainingAnswers()
			emit_signal("completed")
			print_debug("Quiz Hangman: Target '%s' completed" % self.target)
		return

	target.setWrong(true)
	emit_signal("wrong")
	print_debug("Quiz Hangman: Letter '%s' was wrong" % target.text)

# Check if chosen character exists in the target word and is hidden in the target word's label
# Return the index of the matching letter or `-1` if none match
func _validateAnswer(answer: String) -> int:
	for i in range(self.target.length()):
		if answer == self.target[i] and targetLabel.text[i] == "_":
			return i

	return -1

# Reveals the unchosen answers after quiz completion
func _revealRemainingAnswers() -> void:
	for buttonLetter in answerGrid.get_children():
		if not buttonLetter.disabled:
			if buttonLetter.text in self.target:
				buttonLetter.setPossible()
			else:
				buttonLetter.setWrong(false)
