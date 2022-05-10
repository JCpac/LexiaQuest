class_name TimerUI extends PanelContainer


# SIGNALS
signal timeout

# VARS
onready var label: Label = $Label
onready var timer: Timer = $Timer

func _ready():
	pass

func _process(_delta):
	label.text = _toFormattedMinuteString(timer.time_left)

func start(timeInSeconds: int) -> void:
	timer.start(timeInSeconds)

func pause() -> void:
	timer.paused = true

func isRunning() -> bool:
	return bool(timer.time_left)

func _toFormattedMinuteString(timeInSeconds: int) -> String:
	var minutes: int = 0

	while(timeInSeconds >= 60):
		timeInSeconds -= 60
		minutes += 1

	var formattedSeconds: String = "0%s" % timeInSeconds if timeInSeconds < 10 else "%s" % timeInSeconds
	return "%s:%s" % [minutes, formattedSeconds]


func _on_Timer_timeout():
	emit_signal("timeout")
