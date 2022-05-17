extends PanelContainer


# PRELOADS & CONSTS

# SIGNALS
signal correct
signal wrong

# EXPORTS
export(String) var debugTarget = "ball"
export(int, 0, 10) var debugHintChars = 1

# VARS
onready var targetImage: TextureRect = $QuizArea/HBoxContainer/LeftSide/Image/TextureRect
onready var targetLabel: Label = $QuizArea/HBoxContainer/RightSide/VBoxContainer/Target
onready var answerLine: LineEdit = $QuizArea/HBoxContainer/RightSide/VBoxContainer/Answer
var target: String

func _ready():
	_setFocus()

	if OS.is_debug_build() and get_parent() == get_tree().root:
		prepareQuiz(debugTarget, debugHintChars)

func _gui_input(event):
	if event is InputEventKey:
		if event.is_action_pressed("ui_accept"):
			if _validateAnswer():
				emit_signal("correct")

				print_debug("Quiz Write Prompt was correct")
			else:
				emit_signal("wrong")

				print_debug("Quiz Write Prompt was wrong")

func prepareQuiz(targetWord: String, numOfHintChars: int) -> void:
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

func _generateTargetWithHintLetters(targetWord: String, numOfHintChars: int) -> String:
	var shownTargetWord: String = "_".repeat(targetWord.length())
	var chosenHintCharsIndexes: Array = []
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.randomize()

	while chosenHintCharsIndexes.size() < numOfHintChars:
		# Choose character index that hasn't been chosen yet
		var charIndex: int = rng.randi_range(0, targetWord.length()-1)
		while chosenHintCharsIndexes.has(charIndex):
			charIndex = rng.randi_range(0, targetWord.length()-1)

		# Display target word's character at the chosen index
		shownTargetWord[charIndex] = targetWord[charIndex]
		chosenHintCharsIndexes.append(charIndex)

	return shownTargetWord

func _setFocus() -> void:
	answerLine.grab_focus()

func _validateAnswer() -> bool:
	return answerLine.text == target
