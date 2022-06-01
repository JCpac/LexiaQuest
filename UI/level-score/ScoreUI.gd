class_name ScoreUI extends PanelContainer

# VARS
var maxScore: int = 0 setget _setMaxScore
var score: int = 0 setget _setScore

onready var _label: Label = $Label

# METHODS
func _setMaxScore(maxScoreValue: int) -> void:
	if maxScoreValue < 0:
		maxScoreValue = 0

	maxScore = maxScoreValue

	if score > maxScore:
		self.score = maxScore
	_label.text = _updateLabel()

func _setScore(scoreValue: int) -> void:
	if scoreValue < 0:
		scoreValue = 0
	elif scoreValue > maxScore:
		scoreValue = maxScore

	score = scoreValue

	_label.text = _updateLabel()

func _updateLabel() -> String:
	var result: String = "x "
	result += "0%s" % score if score < 10 else "%s" % score
	result += "/0%s" % maxScore if maxScore < 10 else "/%s" % maxScore
	return result
