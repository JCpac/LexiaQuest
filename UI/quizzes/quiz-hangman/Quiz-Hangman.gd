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
export(int, 2, 10) var debugNumAnswers = 8

# VARS
onready var targetImage: TextureRect = $QuizArea/HBoxContainer/LeftSide/Image/TextureRect
onready var targetLabel: Label = $QuizArea/HBoxContainer/RightSide/VBoxContainer/Target
onready var answerGrid: GridContainer = $QuizArea/HBoxContainer/RightSide/VBoxContainer/Answers
var target: String
var missingLetters: Array = []
var rng: RandomNumberGenerator

# METHODS
func _init():
	randomize()

func _ready():
	rng = RandomNumberGenerator.new()
	rng.randomize()

	# If the quiz scene itself is played, automatically use debug values
	if OS.is_debug_build() and get_parent() == get_tree().root:
		var debugHiddenTarget: String = _debugGenerateTargetWithHintLetters(debugTarget, debugHintChars)
		var debugAnswers: Array = _debugGenerateHangmanAnswers(debugTarget, debugHiddenTarget, debugNumAnswers)
		prepareQuiz(debugTarget, debugHiddenTarget, debugAnswers)

# Generates target word with hidden characters and some hint characters
# Only used when debugging the quiz's scene
func _debugGenerateTargetWithHintLetters(targetWord: String, numOfHintChars: int) -> String:
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

# Generates character answers for a "Hangman" quiz
# `targetWord` is the full target word (no hidden characters)
# `hiddenTargetWord` is the version of `targetWord` with hidden characters
# `numOfAnswers` is the total number of answers (necessary correct + random wrong) to be generated
# Only used when debugging the quiz's scene
func _debugGenerateHangmanAnswers(targetWord: String, hiddenTargetWord: String, numOfAnswers: int) -> Array:
	var answerChars: Array = []	# Holds the possible answers

	# Get hint character indexes
	var hintCharIndexes: Array = _getHintCharIndexes(targetWord, hiddenTargetWord)

	# Add target word's characters to possible answers, except for the hint characters
	for i in range(0, targetWord.length()):
		if not i in hintCharIndexes:
			answerChars.append(targetWord[i])

	# Randomize and add extra characters
	var numOfExtraChars = numOfAnswers - len(answerChars)
	while numOfExtraChars:
		var randomASCII: int = rng.randi_range(97, 122)	# ASCII values for range a-z
		answerChars.append(char(randomASCII))
		numOfExtraChars -= 1

	answerChars.shuffle()
	return answerChars

# Assigns the quiz with a target word and several possible answer letters to complete the word
# Generates the quiz UI based on the provided values
# Assumes that all correct letters are provided
# `hiddenTargetWord` is a version of `targetWord` with its characters replaced with underscores, with some exceptions (the hint characters)
# `answers` contains all the characters (necessary correct + random characters)
func prepareQuiz(targetWord: String, hiddenTargetWord: String, answers: Array) -> void:
	self.target = targetWord
	self.targetLabel.text = hiddenTargetWord
	self.targetImage.texture = load("res://assets/Database/Images/%s.jpg" % targetWord)

	var hintCharIndexes: Array = _getHintCharIndexes(targetWord, hiddenTargetWord)
	self.missingLetters = _getMissingLetters(targetWord, hintCharIndexes)

	# Clear answer grid
	# (this quiz scene is instanced once per level and reused for each activity)
	for gridChild in answerGrid.get_children():
		gridChild.free()

	# Generate answer buttons and place them on the tree
	var buttonsArray: Array = _generateAnswerButtons(answers)
	for node in buttonsArray:
		answerGrid.add_child(node)

	# Calculate new appropriate grid size (floored half of the number of answers)
	var newNumOfColumns: int = len(answers) >> 1
	if newNumOfColumns < minNumColumns:
		newNumOfColumns = minNumColumns
	elif newNumOfColumns > maxNumColumns:
		newNumOfColumns = maxNumColumns
	answerGrid.columns = newNumOfColumns

	print_debug("Quiz Hangman: Quiz prepared with target word '%s' and revealed label '%s'" % [targetWord, targetLabel.text])

# Creates an `Array` with the indexes of the `targetWord`'s characters that weren't hidden (the hint characters)
func _getHintCharIndexes(targetWord: String, hiddenTargetWord: String) -> Array:
	var hintCharIndexes: Array = []
	for i in targetWord.length():
		if not hiddenTargetWord[i] == '_':
			hintCharIndexes.append(i)
	return hintCharIndexes

# Creates an array with the unique letters that were *not* revealed in the target label
func _getMissingLetters(targetWord: String, hintCharIndexes: Array) -> Array:
	var missingLettersArray: Array = []
	for i in range(targetWord.length()):
		if not i in hintCharIndexes and not targetWord[i] in missingLetters:
			missingLettersArray.append(targetWord[i])

	return missingLettersArray

func _generateAnswerButtons(answers: Array) -> Array:
	var answerButtons: Array = []	# Holds the buttons with the possible answers

	for answer in answers:
		# Generate duplicate buttons and assign them values
		var newButton: ButtonLetter = buttonLetterScene.instance()
		newButton.setUp(answer)
		newButton.connect("pressed", self, "_on_AnswerButton_pressed", [newButton])
		answerButtons.append(newButton)

	return answerButtons

func _on_AnswerButton_pressed(target: ButtonLetter) -> void:
	var answerIndexInTarget: int = _getAnswerIndexInTarget(target.text)
	if not answerIndexInTarget == -1:
		target.setCorrect()
		targetLabel.text[answerIndexInTarget] = target.text	# Reveal it in target word's label
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
func _getAnswerIndexInTarget(answer: String) -> int:
	for i in range(self.target.length()):
		if answer == self.target[i] and targetLabel.text[i] == "_":
			return i

	return -1

func _validateTargetIsComplete() -> bool:
	return self.target == targetLabel.text

# Reveals the unchosen answers after quiz completion
func _revealRemainingAnswers() -> void:
	for button in answerGrid.get_children():
		if not button.disabled:
			if button.text in missingLetters:
				button.setPossible()
			else:
				button.setWrong(false)
