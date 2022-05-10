class_name ScoreUI extends PanelContainer

# VARS
onready var label: Label = $Label
var maxScore: int = 0

func _ready():
	pass

func setMaxScore(maximumScore: int) -> void:
	maxScore = maximumScore
	label.text = _formatScoreLabel(0, maxScore)

func setScore(score: int) -> void:
	if score > maxScore:
		push_error("Setting overflowed score (%s/%s) in ScoreUI")
		print_stack()
	else:
		label.text = _formatScoreLabel(score, maxScore)

func _formatScoreLabel(score: int, maximumScore) -> String:
	var result: String = "x "
	result += "0%s" % score if score < 10 else "%s" % score
	result += "/0%s" % maximumScore if maximumScore < 10 else "/%s" % maximumScore
	return result
